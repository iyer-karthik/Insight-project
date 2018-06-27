library(data.table)
library(zoo)
library(dplyr)

# This script takes in the raw csv data for 2012-2015 from Lending Club's website, cleans and aggregates, 
# and then writes the cleaned data frame to a csv file, which is later used for running 
# classification models

# For the Machine Learning part, only choose data from 2012-2015
lc_12_13 <- fread(input="raw_data/2013.csv", header=TRUE)

lc_14 <- fread(input="raw_data/2014.csv", header=TRUE)

lc_15 <- fread(input="raw_data/2015.csv", header=TRUE)


# Combine the data
combined_data = rbind(lc_12_13, lc_14, lc_15)


# Clean the data
combined_data$int_rate = as.numeric(gsub('%','',combined_data$int_rate))
combined_data$term = as.numeric(gsub('months','',combined_data$term))

# These columns are not needed
combined_data$id <- NULL
combined_data$member_id <- NULL
combined_data$emp_title <- NULL
combined_data$url <- NULL
combined_data$desc <- NULL

# Change the employment length

combined_data$emp_length <- gsub('years','',combined_data$emp_length)
combined_data$emp_length <- gsub('[[:punct:]]','',combined_data$emp_length)
combined_data$emp_length <- gsub('<','',combined_data$emp_length)
combined_data$emp_length <- gsub(' 1 year','0',combined_data$emp_length)
combined_data$emp_length <- gsub('1 year','1',combined_data$emp_length)
combined_data$emp_length <- gsub('n/a',NA,combined_data$emp_length)
combined_data$emp_length = as.numeric(combined_data$emp_length)

combined_data$annual_inc <- round(as.numeric(combined_data$annual_inc),0)


combined_data <- combined_data[substr(combined_data$zip_code,4,5) != "",]
combined_data$dti <- as.numeric(combined_data$dti)
combined_data$delinq_2yrs <- as.numeric(combined_data$delinq_2yrs)

combined_data$earliest_cr_line <-  as.Date(paste("01-", 
                                              combined_data$earliest_cr_line, sep=""), 
                                           format = "%d-%b-%Y")
# Change the credit age
combined_data$credit_age <- as.numeric((as.Date("2015-12-31") - combined_data$earliest_cr_line)/365)


# Set this to null
combined_data$earliest_cr_line <- NULL
combined_data <- combined_data[combined_data$inq_last_6mths != "",]

# Write CSV in R and use this for classification
write.csv(combined_data, file="agg_data/combined_data_classification.csv")

#----------------------------------------------------------------------------------------

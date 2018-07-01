library(data.table)
library(ggplot2)
library(RColorBrewer)
library(SnowballC)
library(tm)
library(wordcloud)
library(zoo)

# Initial data aggregation and basic cleaning
# Load data
#--------------------------------------------------------------------
# Data from 2007-2011
lending_club_11 <- fread(input="raw_data/2011.csv", header=TRUE)

# Data from 2012-13
lending_club_13 <- fread(input="raw_data/2013.csv", header=TRUE)

# Data from 2014
lending_club_14 <- fread(input="raw_data/2014.csv", header=TRUE)

# Data from 2015
lending_club_15 <- fread(input="raw_data/2015.csv", header=TRUE)

# Data from 2016
lending_club_16q1 <- fread(input="raw_data/2016Q1.csv", header=TRUE)

lending_club_16q2 <- fread(input="raw_data/2016Q2.csv", header=TRUE)

lending_club_16q3 <- fread(input="raw_data/2016Q3.csv", header=TRUE)

lending_club_16q4 <- fread(input="raw_data/2016Q4.csv", header=TRUE)

# Data from 2017
lending_club_17q1 <- fread(input="raw_data/2017Q1.csv", header=TRUE)

lending_club_17q2 <- fread(input="raw_data/2017Q2.csv", header=TRUE)

lending_club_17q3 <- fread(input="raw_data/2017Q3.csv", header=TRUE)

lending_club_17q4 <- fread(input="raw_data/2017Q4.csv", header = TRUE)

# Combine the data
#--------------------------------------------------------------
combined_data = rbind(lending_club_11,
                      lending_club_13,
                      lending_club_14,
                      lending_club_15,
                      lending_club_16q1, 
                      lending_club_16q2, 
                      lending_club_16q3, 
                      lending_club_16q4, 
                      lending_club_17q1, 
                      lending_club_17q2, 
                      lending_club_17q3, 
                      lending_club_17q4)

# View(combined_data) Get a snapshot of the dataframe

# Clean the data
#----------------------------------------------------------------------
combined_data$int_rate = as.numeric(gsub('%','',combined_data$int_rate))
combined_data$term = as.numeric(gsub('months','',combined_data$term))


# These columns are not needed
combined_data$id <- NULL
combined_data$member_id <- NULL
combined_data$url <- NULL
combined_data$desc <- NULL

# Get employment length in years
combined_data$emp_length <- gsub('years','',combined_data$emp_length)
combined_data$emp_length <- gsub('[[:punct:]]','',combined_data$emp_length)
combined_data$emp_length <- gsub('<','',combined_data$emp_length)
combined_data$emp_length <- gsub(' 1 year','0',combined_data$emp_length)
combined_data$emp_length <- gsub('1 year','1',combined_data$emp_length)
combined_data$emp_length <- gsub('n/a',NA,combined_data$emp_length)
combined_data$emp_length = as.numeric(combined_data$emp_length)

# Convert these columns to numeric
combined_data$annual_inc <- round(as.numeric(combined_data$annual_inc),0)
combined_data$loan_amnt <- as.numeric(combined_data$loan_amnt)
combined_data$dti <- as.numeric(combined_data$dti)
combined_data$delinq_2yrs <- as.numeric(combined_data$delinq_2yrs)

# Extract the issued month and year of the loan
combined_data$issued_month <- substr(combined_data$issue_d,1,3)
combined_data$issued_yr <- substr(combined_data$issue_d,5,8)
combined_data$issue_d <-  NULL # No longer needed!

combined_data <- combined_data[substr(combined_data$zip_code,4,5) != "",]

# Get credit age in years
combined_data$earliest_cr_line <-  as.Date(paste("01-", 
                                                 combined_data$earliest_cr_line, sep = ""), 
                                                 format = "%d-%b-%Y")
combined_data$credit_age <- as.numeric((as.Date("2017-12-31") - combined_data$earliest_cr_line)/365)
combined_data$earliest_cr_line <- NULL
combined_data <-  combined_data[combined_data$inq_last_6mths != "",]

View(combined_data)

# Write CSV in R
write.csv(combined_data, file="agg_data/combined_data.csv")

# A simple visualization of the word cloud for loan titles

docs <- Corpus(VectorSource(combined_data$title))

# Convert the text to lower case
docs <- tm_map(docs, content_transformer(tolower))

# Remove english common stopwords
docs <- tm_map(docs, removeWords, stopwords("english"))

# Remove your own stop word. Specify your stopwords as a character vector
docs <- tm_map(docs, removeWords, c("loan", "loans")) 

# Visualize
wordcloud(combined_data$title,
          scale = c(3,.5),
          max.words = 100,
          random.order=T, 
          rot.per=0.15, 
          use.r.layout=F, 
          colors=brewer.pal(7,"Dark2"))






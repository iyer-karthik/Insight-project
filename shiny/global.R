library(data.table)
library(dplyr)
library(dygraphs)
library(ggplot2)
library(googleVis)
library(plotly)
library(readr)
library(shiny)
library(shinydashboard)
library(shinythemes)
library(stats)
library(xts)



# Load the combined data and only look at individual applications
lending_club_data <- fread(input="./agg_data/combined_data.csv", header=TRUE)

lending_club_data <- select(lending_club_data, 
                            loan_amnt, funded_amnt, 
                            term, int_rate, grade, 
                            sub_grade, emp_length, 
                            annual_inc, 
                            loan_status,
                            purpose, addr_state, 
                            dti, 
                            delinq_2yrs, 
                            inq_last_6mths,
                            collections_12_mths_ex_med,
                            policy_code, application_type, 
                            open_il_24m, avg_cur_bal, 
                            delinq_amnt, 
                            num_tl_op_past_12m, 
                            pub_rec_bankruptcies, 
                            tot_hi_cred_lim, 
                            issued_month, 
                            issued_yr, 
                            credit_age) %>%
  filter(application_type == "Individual")

# Remove unnecessary columns 
lending_club_data <- select(lending_club_data,
                            -funded_amnt, 
                            -policy_code, 
                            -application_type)

# Average interest rate by sub group
subgrade_int <- group_by(lending_club_data, grade, 
                         sub_grade) %>% 
                summarise(avg_int = mean(int_rate))

# Total amount and total number of loans grouped by year and month
#scandal_table1 <- group_by(lending_club_data, issued_month, issued_yr) %>% summarise(total_loan_amount = sum(loan_amnt), count = n()) %>% arrange(desc(count))

grade_facet <- select(lending_club_data, grade, int_rate) 

group_by_status <- group_by(lending_club_data, 
                            issued_yr, 
                            loan_status, 
                            grade, 
                            term) %>% 
                   summarise(count=n())

group_by_total_status <- group_by(lending_club_data, 
                                  issued_yr, 
                                  grade, 
                                  term) %>% 
                         summarise(total_count=n())

default_rate <- left_join(group_by_status,
                          group_by_total_status,
                          by=c("issued_yr","grade","term")) %>%
                mutate(prop=count/total_count) %>% 
                filter(loan_status=="Charged Off")

lending_club_data$issue_d <- paste0(lending_club_data$issued_month, "-", lending_club_data$issued_yr)
lending_club_data$issue_d <- as.Date(gsub("^", "01-", lending_club_data$issue_d), format="%d-%b-%Y")
evolving_amnt <- group_by(lending_club_data, 
                          issue_d) %>% 
                 summarise(total_amount=sum(loan_amnt))


temp1 <- group_by(lending_club_data, grade, issued_yr) %>% 
         summarise(total_loan = sum(as.numeric(loan_amnt))/1000000)

ggplot(temp1, aes(x=issued_yr, y=total_loan)) + geom_bar(stat="identity", aes(fill=grade)) +
  xlab('Issued Year') + 
  ylab('Total funded loan amount in millions')

temp2 <- group_by(lending_club_data, issued_yr) %>% 
         summarise(annual_loan=sum(as.numeric(loan_amnt))/1000000)

final_temp <- left_join(temp1, temp2, by = "issued_yr") %>%  
  mutate(prop=total_loan/annual_loan) %>% 
  select(grade, issued_yr, prop)

ggplot(final_temp, aes(x=issued_yr, y=prop)) + geom_bar(stat="identity", aes(fill=grade)) +
  theme(plot.background=element_rect(fill='lightgrey', colour = 'red')) + 
  xlab("Issued Year") +
  ylab("Proportion of Loan Amount by grade")

dytest2 <- group_by(lending_club_data, issue_d) %>% 
           summarise(total_loan=sum(as.numeric(loan_amnt))/1000000)

time_series <- xts(dytest2, order.by = dytest2$issue_d)
dygraph(time_series, main = "Total amount of funded loans in millions") %>%
  dyEvent("2014-8-07", "IPO", labelLoc = "bottom") %>%
  dyEvent("2016-5-01", "Resignation of CEO", labelLoc = "bottom") %>%
  dyOptions(maxNumberWidth = 20) # Grouped by issue_date. This plot is fascinating




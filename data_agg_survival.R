library(data.table)
library(zoo)
library(dplyr)

# This script takes in the raw csv data for 2012-2015 from Lending Club's website, cleans and aggregates, 
# using only 3 year loans and then writes the cleaned data frame to a csv file, which is later used for running 
# survival analysis models

# Load the aggregated data frm 2012-2015
combined_data <- fread(input="agg_data/combined_data_classification.csv", header=TRUE)

# Process the data for survival analysis. Use only 3 year loans
combined_data_36 <- combined_data %>% 
                    filter(term == 36)

# This function, at its core, vectorizes the closed form solution
# of the first order difference equation relating the remaining
# principal, given the terms of a loan and the current time.
loan.duration = function(df)
{
  loan_status = df$loan_status
  total_pymnt = df$total_pymnt
  installment = df$installment
  funded_amnt = df$funded_amnt
  period_int_rate = df$int_rate/100/12
  
  k = 0:36
  tk = matrix(rep(total_pymnt, length(k)), nc=length(k))
  
  
  # Two possible cash flows: pay fixed coupons until time k (Xk) [default case]
  #                          pay fixed coupons and then a lump sum at time k (Tk)[prepay case]
  Yk = installment %o% k
  Tk = Yk +  
    installment / period_int_rate + 
    exp(log(1+period_int_rate) %o% k) * (funded_amnt - installment/period_int_rate)
  
  # Find the time at which the total paid amount is closest to the cash flow at time tk
  dYk = abs(Yk - tk)
  dTk = abs(Tk - tk)
  mYk = apply(dYk, 1, function(x) min(36, k[which.min(x)]+1))  # Default occurs after last pymnt
  mTk = apply(dTk, 1, function(x) k[which.min(x)])
  
  # Mix the two duration metrics & mark the death events
  fp_ind = (loan_status == 'Fully Paid')
  time   = ifelse(fp_ind, mTk, mYk)
  status = (loan_status %in% c('Default', 'Charged Off', 'Late (16-30 days)', 'Late (31-120 days)'))
  
  rval = list(time=time, status=status)
  return(rval)
}

# Create two new columns for survival analysis
dur <- loan.duration(combined_data_36)
combined_data_36$time =  dur$time
combined_data_36$status = dur$status

write.csv(combined_data_36, file="agg_data/combined_data_survival.csv")

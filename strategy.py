# -*- coding: utf-8 -*-
"""
"""
import pandas as pd
import numpy as np 
import math
from plotly.offline import download_plotlyjs, init_notebook_mode,  plot
init_notebook_mode()

## Code for computing expected returns and comparing the performance of the 
## investment strategy

MAX_LOG_RATE = 1e3
BASE_TOL = 1e-12

def better_irr_newton(my_list, tol=BASE_TOL):
    
    ''' Compute the internal rate of return. This is the “average” periodically 
    compounded rate of return that gives a net present value of 0.0; Uses
    Newton Raphson. 
    
    Parameters:	
    my_list : array_like, shape(N,)

    Input cash flows per time period. By convention, net “deposits” are 
    negative and net “withdrawals” are positive. Thus, for example, at least 
    the first element of values, which represents the initial investment, 
    will typically be negative.

    Returns:	
    out : float
    
    Examples

    1. round(better_irr_newton([-100, 39, 59, 55, 20]), 5)
           0.28095
    2. round(better_irr_newton([-100, 0, 0, 74]), 5)
          -0.0955 
          ''' 
          
    rate = 0.0
    for steps in range(50):
        r = np.arange(len(my_list))
        # Factor exp(m) out of the numerator & denominator for numerical stability
        m = max(-rate * r)
        f = np.exp(-rate * r - m)
        t = np.dot(f, my_list)
        if abs(t) < tol * math.exp(-m):
            break
        u = np.dot(f * r, my_list)
        # Clip the update to prevent jumping into region of numerical instability
        rate = rate + np.clip(t / u, -1.0, 1.0)

    return math.exp(rate) - 1

def compute_expected_return(df):
    
    ''' Compute the annual expected return.
    
    Parameters:	
    df : dataframe
    
    Use expected number of payments, monthly installments and funded amount 
    information from the dataaframe to compute the expected returns

    Returns:	
    annual_exp_return : numpy array'''
    
    monthly_return = np.zeros(len(df))
    for i in range(len(df)):
        installment_array = df.iloc[i]['installment']*np.ones(df.iloc[i]['expected_number_of_payments'])
        xx = np.insert(installment_array, 0, -df.iloc[i]['funded_amnt'], 
                       axis=0)
        monthly_return[i] = better_irr_newton(xx)
    annual_return = (1 + monthly_return)**12 - 1
    return annual_return
    
def plot_results(df):
    
     ''' Plot the top expected returns vs observed returns. 
     
     Parameters:	
     df : dataframe
     
     Sort the dataframe by expected returns, bin in to top 20 %, 20-40 % and 
     so on. Compare the mean expected return in each bin to mean observed 
     return. Also compute the mean default rate for each bin, and plot 
     the results.'''
     
     # First compute the annual observed returns
     df['returns'] = (df['total_pymnt'] - df['funded_amnt'])/df['funded_amnt']
     df['observed_returns'] = (1 + df['returns'])**(12/df.time) - 1
     
     # Compare returns
     df_sorted = df.sort_values(by='expected_returns', ascending=False)
     df_sorted_split = np.array_split(df_sorted, 5) # 5 bins
     
     # Create arrays to hold the average expected return for each bin
     avg_expected_return = []
     avg_observed_return = []
     avg_default_rate = []
     
     for i in range(len(df_sorted_split)):
         avg_expected_return.append(df_sorted_split[i]["expected_returns"].median())
         avg_observed_return.append(df_sorted_split[i]["observed_returns"].median())
         # Mean gives infinity values. An issue with numpy. Lets replace it by median.
         #avg_observed_return.append(df_sorted_split[i]['observed_returns'].mean())
         avg_default_rate.append(df_sorted_split[i]["status"].mean())
         
     print(avg_expected_return)
     print("\n")
     print(avg_observed_return)
     print("\n")
     print(avg_default_rate)
    
     # Plotting
     # First Create a dataframe of avg expected return and avg observed return
     col_names =  ['Average Expected Return']
     my_df  = pd.DataFrame(columns = col_names)
     my_df['Average Expected Return'] = avg_expected_return
     my_df['Average Observed Return'] = avg_observed_return
     my_df['Average Default Rate'] = avg_default_rate
     my_df = my_df*100
     
     
     trace0 = Bar(
             x=['Top 20 %', '20-40 ', '40-60 ', '60-80 ', 'Bottom 20 %'],
             y=my_df['Average Expected Return'].values,
             name='Average Expected Return',
             marker=dict(
                     color='rgb(49,130,189)'))
     
     trace1 = Bar(
            x=['Top 20 %', '20-40 ', '40-60 ', '60-80 ', 'Bottom 20 %'],
            y=my_df['Average Observed Return'].values,
            name='Average Observed Return',
            marker=dict(
        #color='rgb(204,204,204)',
        color='rgb(191, 13, 13)'))
    

     data = [trace0, trace1]
     layout = Layout(
            xaxis=dict(tickangle=-20),
            yaxis=dict(
            title='% rate of return'),
                    font=dict(family='Courier New, monospace', size=18, color='#060000'),
                              barmode='group',
                              )

     fig = Figure(data=data, layout=layout)
     plot(fig, filename='angled-text-bar.html')
     return None
    
    
if __name__ == '__main__':
    df = pd.read_pickle('agg_data/df_survival.pkl')
    df['expected_returns'] = compute_expected_return(df)
    plot_results(df)

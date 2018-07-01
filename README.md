## Introduction

This page contains a brief description of my Insight Data Science project completed in 3 weeks. For this project, I considered peer-to-peer lending, which is method of financing that allows people to borrow or lend money without a bank. As a part of the project, I looked at approved loan data from [Lending Club](https://www.lendingclub.com/info/download-data.action), one of the biggest online lending platforms. The goal of my project was to improve returns for Lending club investors. 

### Overview
One way to improve returns is by reliably predicting loan default. I approached the problem of prediciting loan default in two ways. One was to look at it as a supervised classfication problem that predicts whether a given loan will default. The aim here was to filter 
out as many bad loans as possible. With that in mind, I used a few parameteric and non-parametric classfiers and optimized for *recall*. 

This binary approach does not bode particularly well for maximizing returns and such analysis has been done before for Lending Club's data. For example, a high interest loan defaulting near the end of the term and a low interest loan defaulting near the beginning of the term will have different returns, and will be binned in the same category by the binary classifer. A more satisfactory approach is to predict the time to default. This was done using survival analysis. 

Using the predicted time to default, an investment strategy was constructed to select optimal loans and was tested with unseen data. I used a combination of R and Python for my analysis. 

### Workflow

The project comprised of four parts:

1. Exploratory analysis of historical data from Lending Club from 2007-2017. I deployed a R Shiny [dashboard](https://puzzle-toad.shinyapps.io/peer_to_peer_lending/) for a visual exploration of Lending Club data. One thing stood out: The growth of the platform itself, measured in terms of amount of money disbursed. 

![LC growth](images/LC_growth.png)


2. Supervised binary classification:
With the aim of improving returns, the first technique I used was a supervised binary classification; predict whether a given loan will default or not. The idea was to improve returns by avoiding bad loans. I used a few parametric and non-parametric classifiers and optimized for recall. Logistic regression with L2 penalty had the best roc-auc. Here is the roc curve for different classifiers 

![ROC](images/roc_final.png)

3. Survival analysis:
A disadvantage of classification techniques is that they do not take the timing of default into account. When using survival analysis, we are able to predict when customers are likely to default. When using traditional classification techniques, it is not possible to include the information regarding a current loan as an input in the model. Focusing on the time aspect of default, information such as “borrower X with characteristics Y has at least been repaying for Z months” can be taken into account. The advantage of not being forced to leave out these censored cases is straightforward: as more information can be included when building a model, one is able to make more accurate predictions when using survival analysis models as opposed to standard classification techniques. 

I used Cox proportional Hazard Model to predict probability of survival for loans. Here is the output for a randm loan whose maturity period is 36 months.

![Survival](images/survival_curve_random_loan.png)

4. Investment strategy
Using the probability of survival allows us to compute expected lifetime which can be used to compute expected returns. Here is a code snippet which computes internal rate of return, which can then be used to compute the annual expected return. 

```markdown
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
```

We then rank all loans by their expected return, bin them in to top 20 %, 20-40 % and so on, and then compare the results 
to observed returns. 

Here is a comparison of the average expected return and average observed return in each bin. As we can see, 
this strategy performs well and picks out the top performing loans. 

![performance](images/newplot%20(2).png)

### Summary 
 Here is a summary of work accomplished over the last 3 weeks
- Deployed a R Shiny dashboard visualizing the analysis
- Used classfication techniques to predict whether a loan will default
- Used survival analysis techniques to predict time to default and constructed an investment strategy off that
- Provided actionable insights that will help in optimal loan selection


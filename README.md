## Introduction

This page contains the code and analysis for my Insight Data Science project. For this project, I looked at peer-to-peer lending, which is method of financing that allows people to borrow or lend money without a bank. As a part of the project, I looked at approved loan data from [Lending Club](https://www.lendingclub.com/info/download-data.action), one of the biggest online lending platforms. The goal of my project was to improve returns for Lending club investors. 

### Overview
One way to improve returns is by reliably predicting loan default. I approached the problem of prediciting loan default in two ways. One was to look at it as a supervised classfication problem that predicts whether a given loan will default. The aim here was to filter 
out as many bad loans as possible. With that in mind, I used a few parameteric and non-parametric classfiers and optimized for *recall*. 

This binary approach does not bode particularly well for maximizing returns and such analysis has been done before for Lending Club's data. For example, a high interest loan defaulting near the end of the term and a low interest loan defaulting near the beginning of the term will have different returns, and will be binned in the same category by the binary classifer. A more satisfactory approach is to predict the time to default. This was done using survival analysis. 

Using the predicted time to default, an investment strategy was constructed to select optimal loans and was tested with unseen data. 

### Workflow

The project comprised of three parts:

1. Exploratory analysis of historical data from Lending Club from 2007-2017. I deployed a R Shiny [dashboard](https://puzzle-toad.shinyapps.io/peer_to_peer_lending/) for a visual exploration of Lending Club data. One thing stood out: The growth of the platform itself, measured in terms of amount of money disbursed. 

![LC growth](images/LC_growth.png)



2. Supervised binary classification


You can use the [editor on GitHub](https://github.com/iyer-karthik/Insight-project/edit/master/README.md) to maintain and preview the content for your website in Markdown files.

Whenever you commit to this repository, GitHub Pages will run [Jekyll](https://jekyllrb.com/) to rebuild the pages in your site, from the content in your Markdown files.

### Markdown

Markdown is a lightweight and easy-to-use syntax for styling your writing. It includes conventions for

```markdown
Syntax highlighted code block

# Header 1
## Header 2
### Header 3

- Bulleted
- List

1. Numbered
2. List

**Bold** and _Italic_ and `Code` text

[Link](url) and ![Image](src)
```

For more details see [GitHub Flavored Markdown](https://guides.github.com/features/mastering-markdown/).

### Jekyll Themes

Your Pages site will use the layout and styles from the Jekyll theme you have selected in your [repository settings](https://github.com/iyer-karthik/Insight-project/settings). The name of this theme is saved in the Jekyll `_config.yml` configuration file.

### Support or Contact

Having trouble with Pages? Check out our [documentation](https://help.github.com/categories/github-pages-basics/) or [contact support](https://github.com/contact) and we’ll help you sort it out.

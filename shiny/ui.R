library(shiny)
library(shinydashboard)
library(plotly)

dashboardPage(
  skin = "red",
  dashboardHeader(title = "Lending Club Exploratoration"),
  dashboardSidebar(
    sidebarUserPanel('Karthik Iyer'),
    #Sidebar content
    sidebarMenu(
      menuItem("Introduction", tabName = "tab1", icon = icon("tasks")),
      menuItem("Analyzing features", tabName = "tab2", icon = icon("tasks"),
               menuSubItem("Feature interactions", tabName = "sub1"), 
               menuSubItem("Grade Analysis", tabName = "sub2")),
      menuItem("Evolution with Time",tabName ="tab3",icon = icon("tasks"),
               menuSubItem("Geographic distribution", tabName = "geographical"),
               menuSubItem("Growth", tabName = "evolution")),
      menuItem("Default Analysis",tabName ="tab7", icon = icon("tasks"),
               menuSubItem("Default Rate Trends", tabName = "default"))
    ) #closes sidebar menu
  ), # closes dashboard - sidebar
  
  dashboardBody(
     #tags$head(
       #tags$style(HTML("
                       #@import url('//fonts.googleapis.com/css?family=Cantarell:i|Droid+Serif:700');
                      # "))
       #),
    tags$head(
    (tags$style(HTML('
        .skin-blue .main-header .logo {
                     background-color: #3c7ebc;
                     }
                     ')))),
    tabItems(
      # First tab content
      tabItem(tabName = "tab1", 
              h3(class = 'text-muted','What is Lending Club?', 
                 style = "font-family: 'Lobster', cursive;"),
              h4("An online p2p lending platform that connects borrowers to lenders.
                 
                 ",
                 style = "font-family: 'Lobster', cursive;"),
              
              h4(""),
              h4(""),
              h4("Enables borrowers to get loans between $1,000 and $40,000. Investors can browse the loan listings on the website and select loans to invest in.", 
                 style = "font-family: 'Lobster', cursive;"),
              
              h4("Offers lower interest rates for borrowers compared to banks, and good returns for investors.", 
                 style = "font-family: 'Lobster', cursive;")
      ), #ends first tab
      
      # Loan-Grade Analysis Sub-tab1
      tabItem(tabName = "sub2", 
              fluidRow(
                column(width = 6, plotOutput("dens_grade")),
                column(width = 6, plotOutput("int_subgrade"))
              ),
              h4("Loan grade is an indicator of risk . 
                 Grade A loans are considered the safest and Grade G the riskiest.",
                 style = "font-family: 'Lobster', cursive;")#ends fluidRow
      ), #ends tab (subtab1)
      
      #Variable Interaction SubTab - 2 (how does lc work?)
      tabItem(tabName = "sub1",
              h3(class = 'text-muted',"Credit features"),
              selectInput(inputId = "xinput", label = strong("Select Feature (x-axis): "),
                          choices = c("Annual Income" = "annual_inc",
                                      "Employment length (years)" = "emp_length",
                                      "Debt to Ratio Income" = "dti",
                                      "Delinquencies over past 2 years" = "delinq_2yrs",
                                      "Average current balance of all accounts" = "avg_cur_bal",
                                      "Number of public record bankruptcies" = "pub_rec_bankruptcies",
                                      "Credit Age (earliest reported credit line)" = "credit_age"),
                          selected = "annual_inc"),
              fluidRow(
                plotlyOutput(outputId = "var_inter")
              ),
              verbatimTextOutput("corr")
      ), #ends tabItem (subtab2)
      
      #Geographic Distribution SubTab1 (evolution over time)
      tabItem(tabName = "geographical",
              h3(class = 'text-muted', "Geographic Distribution?"),
              sliderInput(inputId = "year", label = strong("Please select year"),
                          min = 2007, max = 2017, value = 2013, step=1, sep = '',
                          pre="", post="", animate=animationOptions(interval=3000)),
                          #animate=animationOptions(interval=3000)),
              fluidRow(
                box(h2(textOutput("year")), htmlOutput("gvis")
                ),# ends box
                box(h2(textOutput("year2")), htmlOutput("map2"))
              ), #ends fluidRow
              h4("California consistently has the highest loaned amount. Texas has seen a good growth in recent years.", 
                 style = "font-family: 'Lobster', cursive;"),
              h4("Idaho consistently has among the lowest interest rates.",
                 style = "font-family: 'Lobster', cursive;")
      ), #ends tabItem (subtab1)
      
      #Growth Subtab2 (evolution over time)
      tabItem(tabName = "evolution",
              h3(class = 'text-muted', "Changes as the company grows"),
              selectInput(inputId = "grade2", label = strong("Select grade"),
                          choices = sort(unique(lending_club_data$grade)),
                          selected = "A"),
              dygraphOutput("dygraph"),
              dygraphOutput("loanGrowth")
      ), #ends tab (subtab2)
      
      
      #Default Rate trends
      tabItem(tabName = "default",
              h3(class = 'text-muted',"Default rate by grade and loan term"),
              sliderInput("defaultYear", label = "Highlight specific years:", 
                          min = 2007, max = 2017, value = c(2012,2014), step=1, sep = '')
              #ends box1
              , #ends fluidRow
              hr(),
              fluidRow(
                width = 12, title = "Default Rate Analysis",
                plotOutput("defaultBar", height = 600)
                #ends box2
              ) #ends fluidRow2
      ) 
      
      
       
    ) #ends TabItemS
  ) #ends Dashboard Body
) #ends dashboard page
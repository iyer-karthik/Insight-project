library(shiny)
library(shinydashboard)
library(plotly)


server <- function(input, output) { 
  
  dyPlot1 <- reactive({
    dytest1 <- filter(lending_club_data, 
                      grade == input$grade2) %>% 
              group_by(issue_d) %>% 
              summarise(avg_int = mean(int_rate))
              time_series <- xts(dytest1, order.by = dytest1$issue_d)
  })
  
  # Subset data for variable correlation graoh
  x_int_plot <- reactive ({
                        filter(lending_club_data,annual_inc < 6000000) %>% 
                        group_by_(input$xinput) %>% 
                        summarise(avg_int = mean(int_rate))
  })
  
  
  
  # Subset data for time evolution 
  selected_grades <- reactive ({
    filter(lending_club_data, grade == input$grade) %>% 
    select(issued_yr, grade, int_rate)
  })
  
  
  # Subset data for Map: Includes state, year, loan amount
  selected_year <- reactive({
    filter(lending_club_data, as.numeric(issued_yr) == myYear()) %>% 
    group_by(., addr_state, issued_yr) %>%
    summarise(total_loan = sum(loan_amnt), avg_int = median(int_rate))
  }) #ends reactive statement 1
  
  myYear <- reactive({
    input$year
  })#ends reactive statement 2
  
  myMetric <- reactive({
    input$xinput
  })
  
  output$plot1 <- renderPlot({
    data <- histdata[seq_len(input$slider)]
    hist(data)
  }) # ends renderPlot1
  
  # Subset data by sub-grade
  output$int_subgrade <- renderPlot({
    ggplot(subgrade_int, aes(x = reorder(sub_grade, avg_int), y = avg_int)) + 
    geom_bar(stat = "identity", aes(fill = grade)) + xlab("Subgrade") + ylab("Average Interest Rate") +
    theme(plot.background = element_rect(fill = 'lightgrey', colour = 'blue'),
            panel.background = element_rect(fill = 'white', colour = 'black'),
            panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
            axis.text=element_text(size=12), axis.title=element_text(size=14,face="bold"))
  }) #ends renderPlot2
  
  output$dens_grade <- renderPlot ({
    ggplot(grade_facet, aes(x = int_rate)) + geom_density(aes(fill = grade)) + facet_grid(grade ~ .) + 
      xlab("Interest Rate") + ylab("Density") +
      theme(plot.background = element_rect(fill = 'lightgrey', colour = 'blue'),
            panel.background = element_rect(fill = 'white', colour = 'black'),
            panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
            axis.text=element_text(size=12), axis.title=element_text(size=14,face="bold"))
  })
  
  output$defaultBar <- renderPlot({
    ggplot(default_rate, aes(x = issued_yr, y = prop))+ geom_bar(stat = "identity", aes(fill = (issued_yr <= input$defaultYear[2] & issued_yr >= input$defaultYear[1]))) + 
      facet_grid(term ~ grade) + 
      scale_fill_manual(values = c('white', 'red')) + theme(legend.position = "none") + ylab("default rate") +
      theme(plot.background = element_rect(fill = 'lightgrey', colour = 'black'),
            panel.background = element_rect(fill = 'lightgrey', colour = 'black'),
            panel.grid.minor = element_blank())
    
  })
  
  output$year <- renderText({
    paste("Total Loan Amount issued in", myYear())
  }) #ends renderText1
  
  output$year2 <- renderText({
    paste("Average Interest Rate in", myYear())
  }) #ends renderText2
  
  output$gvis <- renderGvis({
    
    gvisGeoChart(selected_year(), 
                locationvar="addr_state", 
                colorvar="total_loan",
                options=list(region="US", displayMode="regions", 
                              resolution="provinces",
                              colorAxis="{colors:['blue']}",
                              width=500, height=400, animate = TRUE
                              
                 ) #ends list in options
    ) #ends gvisGeoChart
  })
  
  output$map2 <- renderGvis({
    
    gvisGeoChart(selected_year(), 
                 locationvar="addr_state", 
                 colorvar="avg_int",
                 options=list(region="US", displayMode="regions", 
                              resolution="provinces",
                              colorAxis="{colors:['yellow']}",
                              width=500, height=400, animate = TRUE
                 ) #ends list in options
    ) #ends gvisGeoChart
  })
  
  output$monthlyTable <- renderGvis({
    gvisTable(scandal_table1, 
              formats = list(issued_yr="####"),
              options=list(page='enable', height='300', width='automatic'))
  })
  
  output$monthlyLoans <- renderPlotly({
    ggplot(scandal_plot1(), aes(x = issued_month, y = loanMetric)) + geom_bar(stat = "identity", aes(fill = loanMetric)) + 
      facet_grid(issued_yr ~ .) + scale_x_discrete(limits=c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")) +
      scale_y_continuous(name=input$loanType, labels = scales::comma) +
      theme(axis.title.x=element_blank(),axis.title.y=element_blank(), legend.position="none",
            plot.background = element_rect(fill = 'lightgrey', colour = 'black'),
            panel.background = element_rect(fill = 'white', colour = 'black'),
            axis.text.y=element_blank(),
            axis.ticks.y=element_blank()) +
      ggtitle("Monthly loan distribution (2012 - 2017)")
    
    ggplotly()
  })
  
  
  output$evol <- renderPlot ({
    print(
      ggplot(selected_grades(), aes(x = issued_yr, y = int_rate)) + geom_smooth() + xlab("Date issued") + ylab("Interest Rate")
    )
  })
  
  output$loanGrowth <- renderDygraph ({
    dygraph(time_series, main = "Growth in Loans funded") %>%
      dyEvent("2014-8-07", "IPO", labelLoc = "bottom") %>%
      dyEvent("2016-5-01", "Resignation of CEO", labelLoc = "bottom") %>%
      dySeries("total_loan", label = "Total Loan Amount") %>%
      dySeries("issue_d", label = "Issued Year") %>%
      dyOptions(drawGrid = T, maxNumberWidth = 20) %>%
      dyRangeSelector()
  })
  
  
  output$var_inter <- renderPlotly({
    #gvisLineChart(x_int_plot(), xvar=myMetric(), yvar="avg_int")
    ggplot(x_int_plot(), aes_string(x = input$xinput, y = "avg_int")) + 
      geom_smooth() + 
      scale_x_continuous(labels = scales::comma) +
      labs(title = "Feature Interaction", x = myMetric(), y = "Interest Rate") + 
      theme(plot.background = element_rect(fill = 'lightgrey', colour = 'blue'),
            panel.background = element_rect(fill = 'grey', colour = 'black'))
    ggplotly()
  })
  
  output$corr <- renderPrint(
    paste("Correlation: ", cor(lending_club_data[[input$xinput]],lending_club_data[['int_rate']]))
  )
  
  
  output$dygraph <- renderDygraph({
    dygraph(dyPlot1(), main = "Change in average interest rate") %>%
      dySeries("avg_int", label = "Interest Rate") %>%
      dySeries("issue_d", label = "Issued Year") %>%
      dyOptions(drawGrid = T) %>%
      dyRangeSelector()
  })
  
  
}

# Thanks to Shubh Verma for providing the template to create the shiny app
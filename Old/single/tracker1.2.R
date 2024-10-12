### Load Libraries
library(readxl)
library(tidyverse)
library(shiny)
library(shinydashboard)
library(DT)
library(ggplot2)

### Loading Data
adam_study <- read_excel("C:/Users/Owner/OneDrive/Documents/Excels/adam_study.xlsx") |>
  select(1:11) |>
  select(-hours) |>
  filter(minutes > 0) |>
  as.data.frame()




### UI - DASHBOARD
ui <- dashboardPage(
  dashboardHeader(title = "Adam Tracker"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Study", tabName = "Study", icon = icon("tree"))
    )
  ),
  
  ### DASHBOARD BODY HERE!
  dashboardBody(
    tabItems(

      ### TAB FOR STUDY
      tabItem(
        tabName = "Study",
        box(plotOutput("minutes_chart"), 
            width = 12, 
            title = "Last 100 Study Sessions (Minutes")
      )
    )
  )
)


### Server Stuff
server <- function(input, output) {
  output$minutes_chart <- renderPlot({
    ### LAST 100
    last_100 <- tail(adam_study$minutes, 300)
    
    
    
    ### Create DataFrame for ggplot
    minutes_linechart_data <- data.frame(
      session = seq_along(last_100),
      minutes = last_100
    )
    
    
    ### Plot
    ggplot(minutes_linechart_data, 
           aes(x = session, 
               y = minutes/60)) +
      geom_line(color = "blue") +
      theme_minimal() +
      labs(x = "Session", y = "Hours",
           title = "Last 100 Study Sessions") +
      theme(plot.title = element_text(hjust = 0.5))
  })
}

shinyApp(ui, server)
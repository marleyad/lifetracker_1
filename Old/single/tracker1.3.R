
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


### Variables to extract

    ### Last Anki Count
    last_anki_count <- adam_study |>
      select(anki) |>
      filter(!is.na(anki)) |>
      tail(n = 1) |>
      as.numeric()
    
    ### Current Program
    program_im_in <- adam_study |>
      select(program) |>
      tail(1) |>
      as.character()


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
        fluidRow(
          valueBoxOutput("total_minutes_box", width = 4),
          valueBoxOutput("anki_count", width = 4),
          valueBoxOutput("current_program", width = 4)
        ),
        fluidRow(
         box(plotOutput("minutes_chart"), width = 12, title = "Last 100 Study Sessions (Hours)") 
        )
      )
    )
  )
)


### Server Stuff
server <- function(input, output) {
  
  ### KPI - Total Minutes
  output$total_minutes_box <- renderValueBox({
    total_minutes_box <- sum(adam_study$minutes, na.rm = T)
    valueBox(
      value = formatC(total_minutes_box, format="f", big.mark=",", digits=0),
      subtitle = "Total Study Minutes",
      icon = icon("clock"),
      color = "blue"
    )
  })
  
  
  ### KPI - Anki Cards
  output$anki_count <- renderValueBox({
    valueBox(
      value = formatC(last_anki_count, format="f", big.mark=",", digits=0),
      subtitle = "Anki Cards",
      icon = icon("clock"),
      color = "blue"
    )
  })
  
  ### Current Program
  output$current_program <- renderValueBox({
    valueBox(
      value = formatC(program_im_in, format="f", big.mark=",", digits=0),
      subtitle = "Current Program",
      icon = icon("clock"),
      color = "blue"
    )
  })
  
  
  ### LINE CHART
  output$minutes_chart <- renderPlot({
    
    ### LAST 100
    last_100 <- tail(adam_study$minutes, 100)
    
    
    ### Create DataFrame for ggplot
    minutes_linechart_data <- data.frame(
      session = seq_along(last_100),
      minutes = last_100
    )
    
    
    ### Plot
    ggplot(minutes_linechart_data, 
           aes(x = session, 
               y = minutes/60)) +
      geom_line(color = "blue", size = .9) +
      theme_minimal() +
      labs(x = "Session", y = "Hours") +
      theme(plot.title = element_text(hjust = 0.5))
  })
}

shinyApp(ui, server)
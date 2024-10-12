
### Load Libraries
library(readxl)
library(tidyverse)
library(shiny)
library(shinydashboard)
library(DT)
library(ggplot2)



### Loading Data

  ### Study Data
  adam_study <- read_excel("C:/Users/Owner/OneDrive/Documents/Excels/adam_study.xlsx") |>
    select(1:11) |>
    select(-hours) |>
    filter(minutes > 0) |>
    as.data.frame()
  
  ### Strength Data
  strength_data <- read_excel("C:/Users/Owner/OneDrive/Documents/Excels/strength.xlsx") |>
    select(1:2)


### Variables to extract
  
    ### STUDY
  
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
      
    ### STRENGTH
      pushup_total <- strength_data |>
        select(pushups) |>
        sum()


### UI - DASHBOARD
ui <- dashboardPage(
  dashboardHeader(title = "Life Tracker"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Study", tabName = "Study"),
      menuItem("Strength", tabName = "Strength")
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
         box(plotOutput("minutes_chart"), width = 12, title = "Last 30 Study Sessions (Hours)") 
        )
      ),
      tabItem(
        tabName = "Strength",
        fluidRow(
          valueBoxOutput("total_pushups", width = 2)
        ),
        fluidRow(
          box(
            title = "update Strength Data",
            width = 12,
            textInput("exercise_type", "Type of Exercise", placeholder = "e.g., Pushups"),
            numericInput("exercise_count", "Number of Reps", value = 10, min = 1),
            actionButton("submit_strength", "Submit")
          )
        )
      )
    )
  )
)


### Server Stuff
server <- function(input, output) {
  ### STUDY
  
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
    last_100 <- tail(adam_study$minutes, 30)
    
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
  
  
  
  ### STRENGTH
  
  ### Total Count
  output$total_pushups <- renderValueBox({
    valueBox(
      value = formatC(pushup_total, format="f", big.mark=",", digits=0),
      subtitle = "Total Pushups",
      icon = icon("clock"),
      color = "blue"
    )
  })
  
}

shinyApp(ui, server)

### Load Libraries
library(readxl)
library(tidyverse)
library(shiny)
library(shinydashboard)
library(DT)
library(ggplot2)
library(writexl)



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
  dashboardHeader(title = "Adam Tracker"),
  dashboardSidebar(
    sidebarMenu(
      ### STUDY DATA 
      menuItem("Study", 
               tabName = "Study",
               menuSubItem("View Data", tabName = "view_data"),
               menuSubItem("Enter Data", tabName = "study_entry")),
      ### STRENGTH DATA
      menuItem("Strength", 
               tabName = "Strength",
               menuSubItem("View Data", tabName = "Strength"),
               menuSubItem("Enter Data", tabName = "strength_entry"))
    )
  ),
  
  ### DASHBOARD BODY HERE!
  dashboardBody(
    tabItems(

      ### TAB FOR STUDY
      tabItem(
        tabName = "view_data",
        fluidRow(
          valueBoxOutput("total_minutes_box", width = 4),
          valueBoxOutput("anki_count", width = 4),
          valueBoxOutput("current_program", width = 4)
        ),
        fluidRow(
         box(plotOutput("minutes_chart"), width = 12, title = "Last 100 Study Sessions (Hours)") 
        )
      ),
      
      ### TAB FOR STRENGTH ENTRY
      tabItem(
        tabName = "strength_entry",
        fluidRow(
          valueBoxOutput("total_pushups", width = 2)
        ),
        fluidRow(
          box(
            title = "Update Strength Data",
            width = 2,
            dateInput("exercise_date", "Date", value = Sys.Date()),
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
    last_100 <- tail(adam_study$minutes, 28)
    
    ### Create DataFrame for ggplot
    minutes_linechart_data <- data.frame(
      session = seq_along(last_100),
      minutes = last_100
    )
    
    ### Plot
    ggplot(minutes_linechart_data, 
           aes(x = session, 
               y = minutes/60)) +
      geom_line(color = "blue", linewidth = .9) +
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
  
  ### UPDATE FORM *** STILL WORKING ON IT
  observeEvent(input$submit_strength, {
    
    ### Create new entry
    new_entry <- data.frame(date = input$exercise_date, 
                            pushups = input$exercise_count)
    
    ### Connect it to dataframe here
    strength_data <<- rbind(strength_data, new_entry)
    
    ### Write the updated strength_data to the excel file
    write_xlsx(strength_data, 
               "C:/Users/Owner/OneDrive/Documents/Excels/strength.xlsx")
    
  })
  
}

shinyApp(ui, server)
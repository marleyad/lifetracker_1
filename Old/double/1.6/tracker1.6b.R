### Load Libraries
library(readxl)
library(tidyverse)
library(shiny)
library(shinydashboard)
library(DT)
library(ggplot2)
library(DBI)
library(RSQLite)
library(readxl)
library(shinyWidgets)
library(writexl)


### UI - DASHBOARD
ui <- dashboardPage(
  dashboardHeader(title = "Life Tracker"),
  dashboardSidebar(
    sidebarMenu(
      
      ### Faith Data
      menuItem("Faith",
        tabName = "Faith",
        menuSubItem("View Data", tabName = "view_faith"),
        menuSubItem("Enter Data", tabName = "faith_entry")
      ),
      
      ### RELATIONSHIP DATA
      menuItem("Relationships",
               tabName = "Relationships",
               menuSubItem("View Data", tabName = "view_Rdata"),
               menuSubItem("Enter Data", tabName = "study_Rentry")
      ),      
      ### STUDY DATA
      menuItem("Study",
        tabName = "Study",
        menuSubItem("View Data", tabName = "view_data"),
        menuSubItem("Enter Data", tabName = "study_entry")
      ),

      ### STRENGTH DATA
      menuItem("Strength",
        tabName = "Strength",
        menuSubItem("View Data", tabName = "view_strength"),
        menuSubItem("Enter Data", tabName = "strength_entry")
      )
    )
  ),

  ### DASHBOARD BODY HERE!
  dashboardBody(
    tabItems(
      
      ### TAB FOR VIEW DATA
      
      
      tabItem(
        tabName = "view_data",
        fluidRow(
          valueBoxOutput("total_minutes_box", 
                         width = 4),
          valueBoxOutput("total_hours_box", 
                         width = 4),
          valueBoxOutput("current_program_box", 
                         width = 4)
        ),
        fluidRow(
          box(plotOutput("study_minutes_linechart"), 
              width = 12, 
              title = "Study Sessions") 
        )
      ),

      
      
      
      
      
      
      ### TAB FOR STUDY DATA ENTRY ***********************
      
      tabItem(
        tabName = "study_entry",
        
        # Progress bar at the top (full width, green, no stripes, starts at 0%)
        div(
          style = "width: 100%;",  # Use CSS to make it full width
          shinyWidgets::progressBar(
            id = "study_progress", 
            value = 0, 
            status = "success",  # Green color
            display_pct = TRUE
          )
        ),
        
        # Two side-by-side boxes (width 6 each)
        fluidRow(
          
          # Box 1 (on the left)
          box(
            width = 6,
            title = "Box 1: Study Input",
            height = "300px",  # Set height for box 1 to match box 2
            
            # Part 1: Numeric input and action button
            fluidRow(
              column(6,
                     numericInput(inputId = "study_minutes", label = "Enter minutes studied", value = 0, min = 0),
                     actionButton(inputId = "submit_minutes", label = "Submit")
              ),
              
              # Part 2: Total minutes today (moved to the right side)
              column(6,
                     h4("Total Minutes Today:"),
                     textOutput("total_minutes_today", inline = TRUE)
              )
            )
          ),
          
          # Box 2 (on the right)
          box(
            width = 6,
            title = "Box 2: Study Details",
            height = "300px",  # Set height for box 2 to match box 1
            
            # Date input, numeric input for minutes, and text area for notes
            dateInput(inputId = "study_date", label = "Select Date", value = Sys.Date()),
            numericInput(inputId = "study_duration", label = "Study Duration (minutes)", value = 0, min = 0),
            textAreaInput(inputId = "study_notes", label = "Notes", placeholder = "Enter any study notes here", width = "100%")
          )
        )
      ),
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      

      ### TAB FOR STRENGTH Data view
      tabItem(
        tabName = "view_strength",
        fluidRow(
          column(width = 6,
                 valueBoxOutput("total_pushup_box_view", width = NULL)
          ),
          column(width = 6,
                 valueBoxOutput("total_situp_box_view", width = NULL)
          )
        ),
        fluidRow(
          box(plotOutput("pushup_line_chart"),
              width = 6,
              title = "Pushup Chart"),
          box(plotOutput("situp_line_chart"),
              width = 6,
              title = "Situp Chart")
        )
        
      ),
      
      
      ### TAB FOR STRENGTH ENTRY
      tabItem(
        tabName = "strength_entry",
        fluidRow(
          valueBoxOutput("today_pushup_box", width = 3),
          valueBoxOutput("today_situp_box", width = 3)
        ),
        fluidRow(
          box(
            title = "Pushups",
            width = 3,
            dateInput("exercise_date", "Date",
              value = Sys.Date()
            ),
            numericInput("exercise_count",
              "Number of Reps",
              value = 10, min = 0
            ),
            actionButton("submit_pushups", "Submit")
          ),
          box(
            title = "Situps",
            width = 3,
            dateInput("exercise_date", "Date",
                      value = Sys.Date()
            ),
            numericInput("exercise_count",
                         "Number of Reps",
                         value = 10, min = 0
            ),
            actionButton("submit_situps", "Submit")
          )
        )
      )
    )
  )
)

source("server.R")

shinyApp(ui, server)
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
        menuSubItem("See data", tabName = "see_data"),
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
        tabName = "see_data",
        fluidPage(
          h1("see data")
        )
      ),
      
      
      
      tabItem(
        tabName = "view_data",
        fluidRow(
          valueBoxOutput("total_minutes_box", 
                         width = 2),
          valueBoxOutput("total_hour_box",
                         width = 2),
          valueBoxOutput("anki_count", 
                         width = 4),
          valueBoxOutput("current_program", 
                         width = 4)
        ),
        fluidRow(
          box(plotOutput("study_minutes_linechart"), 
              width = 12, 
              title = "Study Sessions") 
        )
      ),

      ### TAB FOR STUDY DATA ENTRY
      
      tabItem(
        tabName = "study_entry",
        fluidPage(
          h1("study entry here")
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
          valueBoxOutput("total_pushup_box", width = 3),
          valueBoxOutput("total_situp_box", width = 3)
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
              value = 10, min = 1
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
                         value = 10, min = 1
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
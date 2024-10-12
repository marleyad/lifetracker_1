### Load Libraries
library(readxl)
library(tidyverse)
library(shiny)
library(semantic.dashboard)
library(DT)

### Loading Data
adam_study <- read_excel("C:/Users/Owner/OneDrive/Documents/Excels/adam_study.xlsx") |>
  select(1:11) |>
  select(-hours) |>
  filter(minutes > 0)

ui <- dashboardPage(
  theme = "slate",
  dashboardHeader(title = "Adam Tracker"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Iris", tabName = "iris", icon = icon("tree"))
    )
  ),
  dashboardBody(
    tabItems(

      ### TAB FOR IRIS
      tabItem(
        tabName = "iris",
        box(plotOutput("correlation_plot"), width = 8),
        box(
          selectInput(
            "features", "Features:",
            c("Sepal.Width", "Petal.Length", "Petal.Width")
          ),
          width = 4
        )
      )
    )
  )
)


### Server Stuff
server <- function(input, output) {
  output$correlation_plot <- renderPlot({
    plot(iris$Sepal.Length, iris[[input$features]],
      xlab = "Sepal length", ylab = "Feature"
    )
  })

  output$carstable <- renderDataTable(mtcars)
}

shinyApp(ui, server)
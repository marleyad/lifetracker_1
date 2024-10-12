server <- function(input, output) {
  
  # Initialize reactive data - STUDY
  react_study_data <- reactiveVal(read_excel("C:/Users/Owner/OneDrive/Documents/Excels/adam_study.xlsx"))
  
  # Initialize reactive data - STRENGTH
  react_strength_data <- reactiveVal(read_excel("C:/Users/Owner/OneDrive/Documents/Excels/strength.xlsx"))

  ### UPDATE FORM - STRENGTH (PUSHUPS)
  observeEvent(input$submit_strength, {
    
    ### Create new entry
    new_entry_pushup <- data.frame(
      date = input$exercise_date, 
      pushups = input$exercise_count
    )
    
    ### Append new data to the current strength data
    current_strg_data <- react_strength_data()  # Use react_strength_data() to access the reactive value
    updated_strg_data <- rbind(current_strg_data, new_entry_pushup)
    
    ### Update the reactive strength data
    react_strength_data(updated_strg_data)  # Update the reactive value with the new data
    
    ### Write the updated strength_data to the Excel file
    write_xlsx(updated_strg_data, "C:/Users/Owner/OneDrive/Documents/Excels/strength.xlsx")
  })
  
  # Reactive calculation for total pushups
  total_pushups <- reactive({
    sum(react_strength_data()$pushups, na.rm = TRUE)  # Use react_strength_data() to access the data
  })
  
  ### STRENGTH - Total Count
  output$total_pushup_box <- renderValueBox({
    valueBox(
      value = formatC(total_pushups(), format = "f", big.mark = ",", digits = 0),  # total_pushups is a reactive function
      subtitle = "Total Pushups",
      icon = icon("dumbbell"),
      color = "blue"
    )
  })
  
  ### STRENGTH - LINE CHART
output$pushup_line_chart <- renderPlot({
  line_strength_data <- react_strength_data()

  # Plot
  ggplot(
    line_strength_data,
    aes(
      x = date,
      y = pushups
    )
  ) +
    geom_line(color = "blue") +
    labs(
      x = "",
      y = "Push Ups"
    ) +
    theme_minimal() +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank()
    )
})
  
}

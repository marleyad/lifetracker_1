server <- function(input, output) {
  
  
  # Initialize connection to SQLite database
  con <- dbConnect(SQLite(), "C:/Users/Owner/OneDrive/Documents/ADAM TRACKER/pushup_data_file.sqlite")
  
  
  # Initialize reactive data - STRENGTH
  react_strength_data <- reactiveVal({
    data <- dbReadTable(con, "pushups")
    
    # convert to readable dates
    data$date <- as_date(data$date)
    
    # return all data
    data
  })
  
  print(react_strength_data)
  
  
  
  ### UPDATE FORM - STRENGTH (PUSHUPS)
  observeEvent(input$submit_strength, {
    
    ### Create new entry
    new_entry_pushup <- data.frame(
      date = as.Date(input$exercise_date),
      pushups = as.numeric(input$exercise_count)
    )
    
    ### Get current strength data
    current_data <- react_strength_data()
    
    ### Check if the new entry date matches the most recent record
    
    if (nrow(current_data) > 0 && 
        new_entry_pushup$date == max(current_data$date)) {
      
      # Update the most recent record
      current_data$pushups[which.max(current_data$date)] <- 
        current_data$pushups[which.max(current_data$date)] + new_entry_pushup$pushups
      updated_strg_data <- current_data
      
      #Update the record directly in the database
      dbExecute(con, 
                "UPDATE pushups SET pushups = ? WHERE id = ?", 
                params = list(current_data$pushups[which.max(current_data$date)], 
                              current_data$id[which.max(current_data$date)]))
      
    } else {
      ### Append the new entry to the database without overwriting the table
      dbExecute(con, 
                "INSERT INTO pushups (date, pushups) VALUES (?, ?)", 
                params = list(new_entry_pushup$date, new_entry_pushup$pushups))
    
      
    }
    
    ### Read the updated data
    updated_strg_data <- dbReadTable(con, "pushups")
    
    ### Update the reactive strength data
    react_strength_data(updated_strg_data)
    
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
  onStop(function() {
    dbDisconnect(con)
  })
}

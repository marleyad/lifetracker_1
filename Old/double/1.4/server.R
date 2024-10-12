server <- function(input, output) {
  
  
  # Initialize connection to SQLite database
  con_str <- dbConnect(SQLite(), "C:/Users/Owner/OneDrive/Documents/ADAM TRACKER/pushup_data_file.sqlite")
  
  
  # Initialize reactive data - pushups
  react_pushup_data <- reactiveVal({
    data <- dbReadTable(con_str, "pushups")
    
    # convert to readable dates
    data$date <- as_date(data$date)
    
    # return all data
    data
  })
  
  # Initialize reactive data - situps
  react_situp_data <- reactiveVal({
    data1 <- dbReadTable(con_str, "situps")

    # convert to readable dates
    data1$date <- as_date(data1$date)

    # return all data
    data1
  })
  
  # Initialize reactive data - study
  react_study_data <- reactiveVal({
    data2 <- dbReadTable(con_str, "study")
    
    # convert to readable dates
    data2$date <- as_date(data2$date)
    
    # return all data
    data2
  })
  
  # print(react_pushup_data)
  # print(react_situp_data)
  print(react_study_data)
  
  
  
  
  
  ### STRENGTH - PUSHUP LINE CHART
  output$study_minutes_linechart <- renderPlot({
    all_data <- react_study_data()
    
    line_minutes_data <- all_data |>
      tail(124)
    
    # Plot
    ggplot(
      line_minutes_data,
      aes(
        x = as.Date(date),
        y = minutes/60
      )
    ) +
      geom_line(color = "red") +
      labs(
        x = "",
        y = "Hours"
      ) +
      theme_minimal() +
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()
      )
  })
  
  
  
  
  
  
  
  
  
  
  ### UPDATE FORM - STRENGTH (PUSHUPS)
  observeEvent(input$submit_pushups, {
    
    ### Create new entry
    new_entry_pushup <- data.frame(
      date = as.Date(input$exercise_date),
      pushups = as.numeric(input$exercise_count)
    )
    
    ### Get current strength data
    current_data <- react_pushup_data()
    
    ### Check if the new entry date matches the most recent record
    
    if (nrow(current_data) > 0 && 
        new_entry_pushup$date == max(current_data$date)) {
      
      # Update the most recent record
      current_data$pushups[which.max(current_data$date)] <- 
        current_data$pushups[which.max(current_data$date)] + new_entry_pushup$pushups
      updated_strg_data <- current_data
      
      #Update the record directly in the database
      dbExecute(con_str, 
                "UPDATE pushups SET pushups = ? WHERE id = ?", 
                params = list(current_data$pushups[which.max(current_data$date)], 
                              current_data$id[which.max(current_data$date)]))
      
    } else {
      ### Append the new entry to the database without overwriting the table
      dbExecute(con_str, 
                "INSERT INTO pushups (date, pushups) VALUES (?, ?)", 
                params = list(new_entry_pushup$date, new_entry_pushup$pushups))
    }
    
    ### Read the updated data
    updated_strg_data <- dbReadTable(con_str, "pushups")
    
    ### Update the reactive strength data
    react_pushup_data(updated_strg_data)
    
  })
  
  ### UPDATE FORM - SITUPS (SITUPS)
  observeEvent(input$submit_situps, {

    ### Create new entry
    new_entry_situp <- data.frame(
      date = as.Date(input$exercise_date),
      situps = as.numeric(input$exercise_count)
    )
    
    ### Get current strength data
    current_data <- react_situp_data()
    
    ### Check if the new entry date matches the most recent record

    if (nrow(current_data) > 0 &&
        new_entry_situp$date == max(current_data$date)) {

      # Update the most recent record
      current_data$situps[which.max(current_data$date)] <-
        current_data$situps[which.max(current_data$date)] + new_entry_situp$situps
      updated_strg_data <- current_data

      #Update the record directly in the database
      dbExecute(con_str,
                "UPDATE situps SET situps = ? WHERE id = ?",
                params = list(current_data$situps[which.max(current_data$date)],
                              current_data$id[which.max(current_data$date)]))

    } else {
      ### Append the new entry to the database without overwriting the table
      dbExecute(con_str,
                "INSERT INTO situps (date, situps) VALUES (?, ?)",
                params = list(new_entry_situp$date, new_entry_situp$situps))
    }

    ### Read the updated data
    updated_strg_data <- dbReadTable(con_str, "situps")

    ### Update the reactive strength data
    react_situp_data(updated_strg_data)

  })
  
  
  
  
  
  # Reactive calculation for total pushups
  total_pushups <- reactive({
    sum(react_pushup_data()$pushups, na.rm = TRUE)
  })
  
  # Reactive calculation for total situps
  total_situps <- reactive({
    sum(react_situp_data()$situps, na.rm = TRUE)
  })
  
  
  
  
  
  ### STRENGTH - PUSHUPS - BOX(Total Count) (VIEW)
  output$total_pushup_box_view <- renderValueBox({
    valueBox(
      value = formatC(total_pushups(), format="f", big.mark=",", digits=0),
      subtitle = "Total Pushups",
      icon = icon("dumbbell"),
      color = "blue"
    )
  })
  
  
  ### STRENGTH PUSHUPS - BOX(Total Count) (ENTRY)
  output$total_pushup_box <- renderValueBox({
    valueBox(
      value = formatC(total_pushups(), format = "f", big.mark = ",", digits = 0),  # total_pushups is a reactive function
      subtitle = "Total Pushups",
      icon = icon("dumbbell"),
      color = "blue"
    )
  })
  
  ## STRENGTH SITUPS - BOX(Total Count) (VIEW)
  output$total_situp_box_view <- renderValueBox({
    valueBox(
      value = formatC(total_situps(), format = "f", big.mark = ",", digits = 0),
      subtitle = "Total Situps",
      icon = icon("dumbbell"),
      color = "blue"
    )
  })
  
  ## STRENGTH SITUPS - BOX(Total Count) (ENTRY)
  output$total_situp_box <- renderValueBox({
    valueBox(
      value = formatC(total_situps(), format = "f", big.mark = ",", digits = 0),
      subtitle = "Total Situps",
      icon = icon("dumbbell"),
      color = "blue"
    )
  })
  
  ### STRENGTH - PUSHUP LINE CHART
  output$pushup_line_chart <- renderPlot({
    line_strength_data <- react_pushup_data()
  
    # Plot
    ggplot(
      line_strength_data,
      aes(
        x = as.Date(date),
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
  
  ### STRENGTH - SITUP LINE CHART
  output$situp_line_chart <- renderPlot({
    line_situp_data <- react_situp_data()
    
    # Plot
    ggplot(
      line_situp_data,
      aes(
        x = as.Date(date),
        y = situps
      )
    ) +
      geom_line(color = "blue") +
      labs(
        x = "",
        y = "Sit Ups"
      ) +
      theme_minimal() +
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()
      )
  })
  
  
  
  
  onStop(function() {
    dbDisconnect(con_str)
  })
}

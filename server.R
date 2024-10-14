server <- function(input, output, session) {
  
  
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
  
  # Intialize reactive variable to hold minutes studied today: ******************************* BEST
  total_minutes_studied_today <- reactiveVal(0)

   # Observe and update the total_minutes_studied_today based on the last record *************** BEST!!!
  observe({
    # Get the reactive study data
    study_data <- react_study_data()
    
    # Check if there is any data
    if (nrow(study_data) > 0) {
      # Get the last record's date
      last_record_date <- as.Date(study_data$date[nrow(study_data)])
      
      # Check if the last record is for today's date
      if (last_record_date == Sys.Date()) {
        # If yes, set total_minutes_studied_today to the 'minutes' value for today's date
        total_minutes_studied_today(study_data$minutes[nrow(study_data)])
      } else {
        # If no, set total_minutes_studied_today to 0
        total_minutes_studied_today(0)
      }
    } else {
      # If there's no data, set total_minutes_studied_today to 0
      total_minutes_studied_today(0)
    }
  })

  # print(react_pushup_data)
  # print(react_situp_data)
  # print(react_study_data)
  
  # Reactive calculation for total minutes in study table
  total_minutes <- reactive({
    sum(react_study_data()$minutes, na.rm = TRUE)
  })

  # Reactive calculation for total minutes in study table
  current_program <- reactive({
    react_study_data()$program |>
      tail(1)
  })
  
  ### STUDY - MINUTES - BOX(Total Count) (VIEW)
  output$current_program_box <- renderValueBox({
    valueBox(
      value = formatC(current_program(), format="f", big.mark=",", digits=0),
      subtitle = "Current Program",
      icon = icon("school"),
      color = "blue"
    )
  })
  
  ### STUDY - MINUTES - BOX(Total Count) (VIEW)
  output$total_minutes_box <- renderValueBox({
    valueBox(
      value = formatC(total_minutes(), format="f", big.mark=",", digits=0),
      subtitle = "Total Minutes",
      icon = icon("clock"),
      color = "blue"
    )
  })
  
  ### STUDY - HOURS - BOX(Total Count) (VIEW)
  output$total_hours_box <- renderValueBox({
    valueBox(
      value = formatC(total_minutes()/60, format="f", big.mark=",", digits=0),
      subtitle = "Total Hours",
      icon = icon("clock"),
      color = "blue"
    )
  })




# Define the goal minutes
goal_minutes <- 200  # You can adjust this value or make it dynamic if needed


# Observe when the submit button is clicked
observeEvent(input$submit_minutes, {

  # Get the value from the numeric input
  new_minutes <- input$study_minutes

  # update total_minutes_studied today with input
  total_minutes_studied_today(total_minutes_studied_today() + new_minutes)
})

# Render total minutes for today in Box 1
output$total_minutes_today <- renderText({
  paste(total_minutes_studied_today(), "minutes")
})


  





output$dynamic_study_duration <- renderUI({
  numericInput("study_duration", "Study Duration (minutes):", 
               value = total_minutes_studied_today(), 
               min = 0)
})














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
  
  # Reactive calculation for total pushups for day
  total_pushups_today <- reactive({
    # Get today's date
    today_date <- as_date(Sys.Date())
    
    # Filter the data for today's date
    today_data <- react_pushup_data()[react_pushup_data()$date == today_date, ]
    
    # Check if there is any data for today, if not return 0
    if (nrow(today_data) == 0) {
      return(0)
    } else {
      return(sum(today_data$pushups, na.rm = TRUE))
    }
  })

  # Reactive calculation for total situps
  total_situps <- reactive({
    sum(react_situp_data()$situps, na.rm = TRUE)
  })
  
  # Reactive calculation for total pushups for day 
  total_situps_today <- reactive({
    # Get today's date
    today_date <- as_date(Sys.Date())
    
    # Filter the data for today's date
    today_data <- react_situp_data()[react_situp_data()$date == today_date, ]
    
    # Check if there is any data for today, if not return 0
    if (nrow(today_data) == 0) {
      return(0)
    } else {
      return(sum(today_data$situps, na.rm = TRUE))
    }
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
  
  ### STRENGTH PUSHUPS - BOX(Today Count) (ENTRY) *************
  output$today_pushup_box <- renderValueBox({
    valueBox(
      value = formatC(total_pushups_today(), format = "f", big.mark = ",", digits = 0),  # total_pushups is a reactive function
      subtitle = "Today's Pushups",
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
  
  ## STRENGTH SITUPS - BOX(Today Count) (ENTRY) ***************
  output$today_situp_box <- renderValueBox({
    valueBox(
      value = formatC(total_situps_today(), format = "f", big.mark = ",", digits = 0),
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

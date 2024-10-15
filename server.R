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
  
  # Intialize reactive variable to hold minutes studied today:
  total_minutes_studied_today <- reactiveVal(0)

   # Observe and update the total_minutes_studied_today based on the last record
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

  # Creating a goal for minutes each day
  day_goal <- reactiveVal(240)

  observe({
    # Calculate progress percentage
    progress_percent <- (total_minutes_studied_today() / day_goal()) * 100
    progress_percent <- min(progress_percent, 100)  # Ensure it doesn't exceed 100%

    # Dynamically update the progress bar on page load
    shinyWidgets::updateProgressBar(
      session = session, 
      id = "study_progress", 
      value = progress_percent
    )
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

  observeEvent(input$submit_goal, {
    new_goal <- input$enter_goal
    if (new_goal >= 0) {  # Basic validation
      day_goal(new_goal*60)

      # After updating the goal, recalculate the progress percentage
      progress_percent <- (total_minutes_studied_today() / day_goal()) * 100
      progress_percent <- min(progress_percent, 100)  # Ensure it doesn't exceed 100%
      
      # Dynamically update the progress bar
      shinyWidgets::updateProgressBar(
        session = session, 
        id = "study_progress", 
        value = progress_percent
      )
    }
  })







  ### Submit Minutes when clicked
  observeEvent(input$submit_minutes, {
  
    # Get the value from the numeric input
    new_minutes <- as.numeric(input$study_minutes)
    
    ### Create a new entry for today's study session
    new_entry_study <- data.frame(
      date = Sys.Date(),  # Use today's date
      minutes = new_minutes  # Minutes entered by the user
    )
    
    ### Get current study data from the reactive data
    current_data <- react_study_data()
    
    ### Check if there is an entry for today
    if (nrow(current_data) > 0 && new_entry_study$date == max(current_data$date)) {
      
      # Update the minutes for today's date
      current_data$minutes[which.max(current_data$date)] <- 
        current_data$minutes[which.max(current_data$date)] + new_entry_study$minutes
      
      # Update the record directly in the SQLite database
      dbExecute(con_str, 
                "UPDATE study SET minutes = ? WHERE date = ?", 
                params = list(current_data$minutes[which.max(current_data$date)], 
                              new_entry_study$date))
      
    } else {
      ### Insert a new record if today's entry does not exist
      dbExecute(con_str, 
                "INSERT INTO study (date, minutes) VALUES (?, ?)", 
                params = list(new_entry_study$date, new_entry_study$minutes))
    }
    
    ### Read the updated data from the database
    updated_study_data <- dbReadTable(con_str, "study")
    
    ### Update the reactive study data with the new data
    react_study_data(updated_study_data)
    
    ### Update the total minutes studied today
    total_minutes_studied_today(total_minutes_studied_today() + new_minutes)
    
    ### Calculate the progress percentage
    progress_percent <- (total_minutes_studied_today() / day_goal()) * 100
    progress_percent <- min(progress_percent, 100)  # Ensure it doesn't exceed 100%
    
    ### Dynamically update the progress bar
    shinyWidgets::updateProgressBar(
      session = session, 
      id = "study_progress", 
      value = progress_percent
    )
  })




observeEvent(input$submit_full_entry, {
  # Create new entry for study data
  new_study_entry <- data.frame(
    date = as.Date(input$study_date),
    minutes = total_minutes_studied_today(),  # assuming you're using this as the minutes studied for the day
    notes = input$study_notes,
    anki_cards = input$anki_card_number,
    github_updated = as.logical(input$github_check),
    linkedin_updated = as.logical(input$linkedin_check),
    program = input$program_input,
    status = input$status_input
  )
  
  # Get current reactive study data
  current_data <- react_study_data()
  
  # Check if there's an entry for today's date in the current data
  if (nrow(current_data) > 0 && new_study_entry$date == max(current_data$date)) {
    # Update the most recent record
    current_data$minutes[which.max(current_data$date)] <- new_study_entry$minutes
    current_data$notes[which.max(current_data$date)] <- new_study_entry$notes
    current_data$anki_cards[which.max(current_data$date)] <- new_study_entry$anki_cards
    current_data$github_updated[which.max(current_data$date)] <- new_study_entry$github_updated
    current_data$linkedin_updated[which.max(current_data$date)] <- new_study_entry$linkedin_updated
    current_data$program[which.max(current_data$date)] <- new_study_entry$program
    current_data$status[which.max(current_data$date)] <- new_study_entry$status

    # Update the record directly in the database
    dbExecute(con_str, 
              "UPDATE study SET 
                 minutes = ?, notes = ?, anki = ?, github = ?, linkedin = ?, 
                 program = ?, status = ? 
               WHERE date = ?", 
              params = list(new_study_entry$minutes, new_study_entry$notes, new_study_entry$anki_cards, 
                            new_study_entry$github_updated, new_study_entry$linkedin_updated, 
                            new_study_entry$program, new_study_entry$status, new_study_entry$date))
  } else {
    # Insert the new entry into the database
    dbExecute(con_str, 
              "INSERT INTO study 
               (date, minutes, notes, anki, github, linkedin, program, status) 
               VALUES (?, ?, ?, ?, ?, ?, ?, ?)", 
              params = list(new_study_entry$date, new_study_entry$minutes, new_study_entry$notes, 
                            new_study_entry$anki_cards, new_study_entry$github_updated, 
                            new_study_entry$linkedin_updated, new_study_entry$program, new_study_entry$status))
  }

  # Read the updated study data from the database
  updated_study_data <- dbReadTable(con_str, "study")
  
  # Update the reactive variable with the new data
  react_study_data(updated_study_data)
})


























  # Show Hours of Day Goal
  output$day_goal_display <- renderText({
      paste(day_goal()/60, "hours")
  })

  # Dynamically update value for numeric input
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
  
  ## STRENGTH SITUPS - BOX(Today Count) (ENTRY)
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

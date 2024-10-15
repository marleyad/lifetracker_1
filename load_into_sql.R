library(readxl)
library(RSQLite)
library(DBI)
library(tidyverse)


# # Replace 'your_file.xlsx' with the path to your Excel file
# excel_data <- read_excel("C:/Users/Owner/OneDrive/Documents/Excels/adam_study.xlsx") |>
#   select(1:11) |>
#   select(-days, -hours, -week) |>
#   filter(minutes > 0) |>
#   mutate(
#     date = as.Date(date)
#   )
# head(excel_data)  # Check the data


# con <- dbConnect(RSQLite::SQLite(), "C:/Users/Owner/OneDrive/Documents/ADAM TRACKER/pushup_data_file.sqlite")

# # Loop in data
# for (i in 1:nrow(excel_data)) {
#   dbExecute(con,
#             "INSERT INTO study (date, minutes, notes, anki, github,linkedin, program, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
#             params = list(excel_data$date[i], excel_data$minutes[i], excel_data$notes[i],
#                             excel_data$anki[i], excel_data$Github[i], excel_data$LinkedIn[i],
#                           excel_data$program[i], excel_data$status[i]))
# }

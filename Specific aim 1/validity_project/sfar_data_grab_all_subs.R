#install.packages('readtext')
library(readtext)
library(tidyverse)
library(here)

# Set the file path of the .txt file

file_path <- "C:/Users/Brahma/Desktop/sfar code/data/3086_99_SFAR.txt" # change to just path and it will load multiple .txt 


sfar_single = readtext('3086_99_SFAR.txt')


df = sfar_single$text


split =  strsplit(df, "\n")[[1]]

out = data.frame(split)

# Define the number of rows per column
rows_per_column <- 14

# Calculate the number of columns needed
num_columns <- ceiling(length(split) / rows_per_column)

# Pad 'split' with NA values to ensure even length
split_padded <- c(split, rep(NA, num_columns * rows_per_column - length(split)))

# Reshape 'split_padded' into a matrix with desired dimensions
df3 <- data.frame(matrix(split_padded, nrow = rows_per_column, ncol = num_columns, byrow = FALSE))

# Print the resulting dataframe
df4 = t(df3)


new_rows <- sfar_single[1, ]  # Extract row 1
sfar <- rbind(sfar_single, new_rows, new_rows)  # Append the new rows to the "sfar" object
sfar[2, 1] <- "3086_100"  # Assign the new value to column 2, row 3
sfar[3, 1] <- "3086_101"  # Assign the new value to column 2, row 3

sfars = readtext(here('data'))


df_long <- sfars %>%
  mutate(text = strsplit(text, "\n")) %>%
  unnest(text) %>%
  mutate(variable = ifelse(grepl("_", text), str_extract(text, "^(.*?)_"), 
                           ifelse(grepl(":", text), str_extract(text, ":(.*)"), ""))) %>%
  mutate(variable=  str_replace_all(variable, ": ", "")) %>%
  mutate(variable=  str_replace_all(variable, "_", ""))


 df_long2 = df_long 

 # Define the sequence of identifying info to repeat
 values <- c("target", "accuracy_1", "group", "description", "function", "context", "personal", "free_text", NA, "sentence", "accuracy_2", "patient_generated_features", "time_of_trial_seconds", NA)
 
 # Repeat the values and assign them to a new column
 df_long2$info <- rep(values, length.out = nrow(df_long))  
  

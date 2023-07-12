#install.packages('readtext')
library(readtext)
library(tidyverse)
library(here)
####CODING NOTES WITHIN SFAR FILES#########
#So, if the participant is given a forced choice, and they choose correctly,
#the feature has quotation marks around it – “xx”. If they choose incorrectly, it’s ‘xx’.
#The period means they generated an extra feature.
#The underscore means the clinician exposed them to a feature.



###########CHANGES################
#Fix variable name column to be correct going into next person. - done
#Make value one unique item per row and make sure variable is correct - done
# ---- Figure out what unique characters mean in the value column. e.g. "", . , 
#lack of PG after a word - email sent
#Add trial number , i think this will be easiest once all other steps are done. - done
#change variable to value - done
#change info to variable - done
#Add group  - can't be done yet
#add session - can't be done yet
#add time of day (am/pm) can't be done yet
##################################

###########TO DO##########
#ADD AM VS PM VARIABLE
#######################################
sfars = readtext(here('data')) 

df_long <- sfars %>%
  mutate(text = strsplit(text, "\n")) %>%
  unnest(text) %>%
  mutate(value = ifelse(grepl("_", text), str_extract(text, "^(.*?)_"), 
                           ifelse(grepl(":", text), str_extract(text, ":(.*)"), ""))) %>%
  mutate(value=  str_replace_all(value, ": ", "")) %>%
  mutate(value=  str_replace_all(value, "_", ""))
 
df_long1 = df_long %>%
  mutate(value = ifelse(value == "", NA, value)) %>%
  na.omit()

 df_long2 = df_long1 %>%
   mutate(
     variable = case_when(
       grepl("large", text, ignore.case = TRUE) ~ "target",
       grepl("Naming:", text) ~ "accuracy_1",
       grepl("Group:", text) ~ "group",
       grepl("Description:", text) ~ "description",
       grepl("Function:", text) ~ "function",
       grepl("Context:", text) ~ "context",
       grepl("Other/Personal:", text) ~ "personal",
       grepl("Free Text:", text) ~ "free_text",
       is.na(text) ~ NA_character_,
       grepl("\\*", text) ~ "sentence",
       grepl("PG:", text) ~ "4",
       grepl("Time:", text) ~ "time_of_trial_seconds",
       TRUE ~ NA_character_
     )
   )

#create target column
 df_long2.1 = df_long2 %>%
   mutate(target = if_else(variable == "target", value, NA_character_)) %>%
   fill(target, .direction = "down")
 
 #create trial column
 df_long2.2 = df_long2.1 %>%
   mutate(trial = cumsum((!is.na(target) & target != lag(target, default = "")) | doc_id != lag(doc_id, default = "") | row_number() == 1)) %>%
   group_by(doc_id) %>%
   mutate(trial = trial - first(trial) + 1) %>%
   ungroup()
 
 
 
 
#expand value column by separating character = ","
 df_long3 = df_long2.2 %>%
   separate_rows(value, sep = ",\\s*")
 #change every other value of accuracy_1 to accuracy_2
 df_long4 = df_long3  %>%
   group_by(variable) %>%
   mutate(counter = cumsum(variable == "accuracy_1" & !is.na(variable))) %>%
   ungroup() %>%
   mutate(variable = if_else(variable == "accuracy_1" & counter %% 2 == 0, "accuracy_2", variable)) %>%
   select(-counter)

 df_long5 = df_long4 %>%
   mutate(participant = sub("^(.*?)_.*$", "\\1", doc_id),
          tx_day = sub("^.*?_(.*?)_.*$", "\\1", doc_id),
          time = sub("^.*?_(.*?)_(.*?)_.*$", "\\2", doc_id),
          clinician = sub("^.*?_(.*?)_(.*?)_(.*?)_.*$", "\\3", doc_id),
          group = sub("^.*?_(.*?)_(.*?)_(.*?)_(.*?)_.*$", "\\4", doc_id))
 
library(readxl)
test_data_manipulation <- read_excel("C:/Users/alexa/OneDrive/Desktop/test data manipulation.xlsx")

df = test_data_manipulation

library(tidyverse)

df2 = df %>%
  gather(fixation_location, gaze, aoi1:aoi4) %>%
  mutate(fixation_location = as.numeric(substr(fixation_location, 4,4))) %>%
  mutate(fixation_name = 
           ifelse(fixation_location == target_location, 'Target',
                  ifelse(fixation_location == phonemic_location, "Phonemic",
                         ifelse(fixation_location == semantic_location, "Semantic",
                                ifelse(fixation_location == unrelated_location, "unrelated", 'Error')      
                         ))))

df2 %>% ggplot(aes(x = bin, y = gaze)) +
  geom_bar(stat = 'summary') +
  facet_wrap(~fixation_name)

df2 %>%
  group_by(participant, fixation_name, session) %>%
  summarise(sum(gaze))

df3 = df2 %>%
  mutate(gaze = ifelse(gaze != 0, TRUE, FALSE))
         
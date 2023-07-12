library(readxl)
library(dplyr)
library(here)
library(purrr)
library(tidyr)

here()
#create list of all files within the data folder
file_list = list.files(path = here("data"), pattern = "^3086", full.names = TRUE)

df <- file_list %>%
  map_df(~ read_excel(.))

#split recording session label to two columns, participant and session
df = df %>%
  separate(RECORDING_SESSION_LABEL, into = c("participant", "session"), sep = "_", convert = TRUE) 
  

#remove practice
df2 = df %>%
  filter(condition != 'practice') %>%
  rename(aoi1 = RIGHT_IA_1_SAMPLE_COUNT) %>%
  rename(aoi2 = RIGHT_IA_2_SAMPLE_COUNT) %>%
  rename(aoi3 = RIGHT_IA_3_SAMPLE_COUNT) %>%
  rename(aoi4 = RIGHT_IA_4_SAMPLE_COUNT)


#0 = all aoi valued = 0
#1 = aoi1 is greater than 0 etc
df2$aoi_all = ifelse(df2$aoi1 + df2$aoi2 + df2$aoi3 + df2$aoi4 == 0, 0,
                     ifelse(df2$aoi1 > 0, 1,
                       ifelse(df2$aoi2 > 0, 2, 
                              ifelse(df2$aoi3 > 0, 3, 4))))



df2$y_5 = ifelse(df2$aoi_all == 0, NA,
  ifelse(df2$aoi_all == df2$unrelated_location, 0, 
                   ifelse(df2$aoi_all == df2$phonemic_location, 1,
                          ifelse(df2$aoi_all == df2$semantic_location, 2,
                                 ifelse(df2$aoi_all == df2$target_location, 3, 4)))))



df3 = df2 %>%
  filter(participant == 308630,
         TRIAL_INDEX < 15) %>%
  group_by(session, participant, TRIAL_INDEX) %>%
  # Create max_bin variable as the highest value within BIN_INDEX
  # Create total_count variables
  mutate(max_bin = max(BIN_INDEX)*25,
         aoi1_count = sum(aoi1),
         aoi2_count = sum(aoi2),
         aoi3_count = sum(aoi3),
         aoi4_count = sum(aoi4)) %>%
  # Select only the newly created variables and a single value of the existing variables
  distinct(session, participant, TRIAL_INDEX, max_bin, aoi_all, y_5, aoi1_count, aoi2_count, aoi3_count, aoi4_count, target_location, semantic_location, phonemic_location, unrelated_location)



 

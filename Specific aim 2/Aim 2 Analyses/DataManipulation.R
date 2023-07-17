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
  ifelse(df2$aoi_all == df2$unrelated_location, 'unrelated', 
                   ifelse(df2$aoi_all == df2$phonemic_location, 'phonemic',
                          ifelse(df2$aoi_all == df2$semantic_location, 'semantic',
                                 ifelse(df2$aoi_all == df2$target_location, 'correct', 4)))))

##sum aoi1-4 to get counts in a single bin across 4 quadrants, then we can sum that category after grouping on y_5
df2$aoi_sums = df2$aoi1 + df2$aoi2 +df2$aoi3 +df2$aoi4

df3 = df2 %>%
  select(participant, session, TRIAL_INDEX, BIN_INDEX, targetword, aoi_all, y_5, aoi_sums) %>%
  group_by(participant, session, TRIAL_INDEX) %>%
  mutate(max_bin = max(BIN_INDEX)*25) 

test = df3 %>%
  spread(y_5, aoi_sums)

test2 = test %>%
  mutate(correct_count = sum(correct, na.rm = TRUE),
         semantic_count = sum(semantic, na.rm = TRUE),
         phonemic_count = sum(phonemic, na.rm = TRUE),
         unrelated_count = sum(unrelated, na.rm = TRUE)) %>%
  mutate(correct_prop = correct_count/max_bin,
         semantic_prop = semantic_count/max_bin,
         phonemic_prop = phonemic_count/max_bin,
         unrelated_prop = unrelated_count/max_bin)

#################JUST NEED TO VERIFY THAT TEST 3 IS CORRECT THEN WE ARE READY FOR GCA ############

test3 = test2 %>% 
  distinct(session, participant, targetword, TRIAL_INDEX, correct_prop,  semantic_prop,phonemic_prop,  unrelated_prop)



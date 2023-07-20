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


df2.1 = df2 %>%
  gather(location_content, content_quadrant_number, target_location:unrelated_location, 
         factor_key = TRUE) %>%
  gather(gaze_location_name, gaze_quadrant_count, aoi1:aoi4,
         factor_key = TRUE) %>%
  mutate(gaze_quadrant_number = as.numeric(gaze_location_name)) %>%
  mutate(count_by_bin_by_quadrant_content = ifelse(gaze_quadrant_number == content_quadrant_number, 
                                                   gaze_quadrant_count, NA)) %>%
  group_by(targetword, participant, session, location_content) %>%
  mutate(count_by_bin_content = sum(count_by_bin_by_quadrant_content, na.rm = TRUE),
         max_bin = max(BIN_INDEX)*25)

df2.2 = df2.1 %>%
  distinct(participant, targetword, location_content, count_by_bin_content, max_bin) %>%
  rename(gaze_content = location_content) %>%
  mutate(proportion_gaze_content = count_by_bin_content/max_bin,
         gaze_content = str_replace_all(gaze_content, "_location", ""))




#check to make sure df2.2 is accurate

test = df %>%
  filter(participant == 308630,
         session == 1)

test2 = test %>%
  filter(TRIAL_INDEX == 43) %>%
  rename(correct_counts = RIGHT_IA_1_SAMPLE_COUNT,
         phon_counts = RIGHT_IA_2_SAMPLE_COUNT,
         sem_counts = RIGHT_IA_3_SAMPLE_COUNT,
         unrel_counts = RIGHT_IA_4_SAMPLE_COUNT) %>%
  mutate(sum_correct = sum(correct_counts),
         sum_phon = sum(phon_counts),
         sum_sem = sum(sem_counts),
         sum_unrel = sum(unrel_counts)) %>%
  mutate(max_bin = max(BIN_INDEX)*25) %>%
  mutate(props = sum_correct/max_bin)

#######################
test = df2 %>%
  filter(participant == 308630,
         session == 1)

test2 = test %>%
  filter(TRIAL_INDEX == 43) %>%
  rename(correct_counts = aoi1,
         phon_counts = aoi2,
         sem_counts = aoi3,
         unrel_counts = aoi4) %>%
  mutate(sum_correct = sum(correct_counts),
         sum_phon = sum(phon_counts),
         sum_sem = sum(sem_counts),
         sum_unrel = sum(unrel_counts)) %>%
  mutate(max_bin = max(BIN_INDEX)*25) %>%
  mutate(prop_correct = sum_correct/max_bin,
         prop_phon = sum_phon/max_bin,
         prop_sem = sum(sem_counts)/max_bin,
         prop_unrel = sum(unrel_counts)/max_bin)

df2.2.test = df2.2 %>%
  filter(participant == 308630,
         session == 1,
         targetword == 'stroller')

#winner winner chicken dinner


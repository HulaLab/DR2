library(readxl)
library(dplyr)
library(here)
library(purrr)
library(tidyr)
library(ggplot2)
library(stringr)

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
  rename(aoi4 = RIGHT_IA_4_SAMPLE_COUNT) %>%
  pivot_longer(cols = aoi1:aoi4,
               names_to = "fixation_location",
               values_to = "count") %>%
  pivot_longer(cols = target_location:unrelated_location,
               names_to = "quadrant_stimuli_name",
               values_to = "quadrant_number")

df2.0 = df2 %>%
  mutate(fixation_location = ifelse(fixation_location == 'aoi1', 1, 
                                    ifelse(fixation_location == 'aoi2', 2,
                                           ifelse(fixation_location == 'aoi3', 3, 4))))

#get counts by quadrant content

df2.01 = df2.0 %>%
  mutate(count_by_bin_by_quadrant_content = ifelse(fixation_location == quadrant_number, 
                                     count, 0))

#get max count per quadrant for proportions
df2.02 = df2.01 %>%
  group_by(targetword, participant, session) %>%
  mutate(max_bin = max(BIN_INDEX)*25)

#estimate proportions
#create label for easy plotting

df_out = df2.02 %>%
  mutate(proportion = count_by_bin_by_quadrant_content/max_bin,
         gaze_content = str_replace_all(quadrant_stimuli_name, "_location", ""))


df_test = df_out %>%
  filter(BIN_START_TIME < 500)

library(janitor)

df_test = df_test %>%
  clean_names() %>%
  select( -left_ia_0_sample_count,
          -left_ia_2_sample_count,
          -left_ia_1_sample_count,
          -left_ia_3_sample_count,
          -left_ia_4_sample_count,
          -left_ia_0_sample_count_percent,
          -left_ia_2_sample_count_percent,
          -left_ia_1_sample_count_percent,
          -left_ia_3_sample_count_percent,
          -left_ia_4_sample_count_percent,
          -ip_index,
          -ip_label,
          -trial_label)

df_test_merge = df_test %>%
  group_by(gaze_content, trial_index, participant, session, bin_start_time, bin_index, targetword) %>%
  #mutate(proportion2 = sum(proportion))
  summarise(proportion2 = sum(proportion))

ggplot(df_test_merge, aes(x =bin_index, y = proportion2, color = gaze_content)) +
  geom_smooth(se = FALSE) +
  facet_grid(~participant + session)

test = df_out %>%
  filter(participant == 308630,
         session == 1, 
         TRIAL_INDEX == 14)

ggplot(df_out, aes(x = bin))
  


#this is almost the same as df_out, but was used to create df2.2 and sums across bins within each item on the second to last mutateline 
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


## This manipulation shows the proportion of gaze types at the item level. 
df2.2 = df2.1 %>%
  distinct(participant, targetword, location_content, count_by_bin_content, max_bin) %>%
  rename(gaze_content = location_content) %>%
  mutate(proportion_gaze_content = count_by_bin_content/max_bin,
         gaze_content = str_replace_all(gaze_content, "_location", ""))




#check to make sure df2.2 is accurate

test = df 

test2 = test %>%
  #filter(TRIAL_INDEX == 43) %>%
  rename(correct_counts = RIGHT_IA_1_SAMPLE_COUNT,
         phon_counts = RIGHT_IA_2_SAMPLE_COUNT,
         sem_counts = RIGHT_IA_3_SAMPLE_COUNT,
         unrel_counts = RIGHT_IA_4_SAMPLE_COUNT) %>%
  group_by(participant, TRIAL_INDEX, session) %>%
  mutate(max_bin = max(BIN_INDEX)*25) %>%
  pivot_longer(cols = correct_counts:unrel_counts,
               names_to = "gaze_type",
               values_to = "count") 
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
  mutate(max_bin = max(BIN_INDEX)*25) %>%
  mutate(prop_correct = sum_correct/max_bin,
         prop_phon = sum_phon/max_bin,
         prop_sem = sum(sem_counts)/max_bin,
         prop_unrel = sum(unrel_counts)/max_bin)

df_out_test = df_out_test %>%
  filter(participant == 308630,
         session == 1,
         targetword == 'stroller')

#winner winner chicken dinner


library(ggplot2)

ggplot(data = test, aes(x = BIN_INDEX, ))


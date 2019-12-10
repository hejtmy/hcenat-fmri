library(data.table)
library(navr)
library(dplyr)
library(ez)
sapply(list.files("functions", full.names = T, recursive = T), source)
CORRECT_ANGLES <- read.table("data/correct-angles.csv", sep=",", header=TRUE)

data_dir <- "E:/OneDrive/NUDZ/projects/HCENAT/Data/"
img_path <- "images/megamap5.png"

df_preprocessing <- load_participant_preprocessing_status()

participants <- load_participants(data_dir, df_preprocessing = df_preprocessing, sessions = 2)
participants_pulses <- add_pulses.participants(participants)

## Creatomg the table  ----

## Pointing
df_pointing <- pointing_results.participants(participants_pulses)
df_pointing <- add_fmri_code(df_pointing, "participant", df_preprocessing)

pointting_out <- df_pointing %>% 
  select(fmri_code, point_start_fmri, point_end_fmri, correct_angle, chosen_angle) %>%
  rename(time_start = point_start_fmri, time_end = point_end_fmri) %>%
  mutate(duration = time_end - time_start, angle_error = angle_diff(correct_angle, chosen_angle)) %>%
  select(-c(correct_angle, chosen_angle))

## Onsets

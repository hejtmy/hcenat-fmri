library(data.table)
library(navr)
library(dplyr)
library(ez)
sapply(list.files("functions", full.names = T, recursive = T), source)
DATA_DIR <- "E:/OneDrive/NUDZ/projects/HCENAT/Data/"
# source("scripts/preprocess-participants.R")

load("participants-prepared.RData")

## Pointing ------
df_pointing <- pointing_results.participants(participants)
df_pointing <- add_fmri_code(df_pointing, "participant", df_preprocessing)

out_pointing <- df_pointing %>%
  select(fmri_code, point_start_fmri, point_end_fmri, correct_angle, chosen_angle) %>%
  rename(time = point_start_fmri, time_end = point_end_fmri) %>%
  mutate(duration = time_end - time, angle_error = round(angle_diff(correct_angle, chosen_angle), 4)) %>%
  mutate(time = round(time, 4), duration = round(duration, 4)) %>%
  select(-c(correct_angle, chosen_angle, time_end))

write.table(out_pointing, file.path("exports", "pointing.csv"), row.names = FALSE, sep=",", quote = FALSE)

## Onsets -----
df_onset_stop <- onset_stop_table.participants(participants, 10, 1, 3)
df_onset_stop <- add_fmri_code(df_onset_stop, "participant", df_preprocessing)

out_onset_stop <- df_onset_stop %>%
  mutate(time = round(fmri_time, 4), duration = round(duration, 4)) %>%
  select(fmri_code, time, duration, movement_type)

write.table(out_onset_stop, file.path("exports","walking.csv"), row.names = FALSE, sep=",", quote = FALSE)

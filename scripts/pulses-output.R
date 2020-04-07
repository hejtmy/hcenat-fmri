library(data.table)
library(navr)
library(dplyr)
source('scripts/loading.R')
DATA_DIR <- "E:/OneDrive/NUDZ/projects/HCENAT/Data/"
CORRECT_ANGLES <- read.table("data/correct-angles.csv", sep=",", header=TRUE)
df_preprocessing <- load_participant_preprocessing_status()
# source("scripts/preprocess-participants.R")

load("participants-prepared.RData")

## Results ----
res <- quest_summary.participants(participants)
res <- add_fmri_code(res, "participant", df_preprocessing)

## Pointing ------

res %>%
  select(fmri_code, point_start_fmri, point_end_fmri, correct_angle, chosen_angle) %>%
  rename(time = point_start_fmri, time_end = point_end_fmri) %>%
  mutate(duration = time_end - time, angle_error = round(angle_diff(correct_angle, chosen_angle), 4)) %>%
  mutate(time = round(time, 4), duration = round(duration, 4)) %>%
  filter(!is.na(time)) %>%
  select(-c(correct_angle, chosen_angle, time_end)) %>%
  write.table(., file.path("exports", "pointing.csv"), row.names = FALSE, sep=",", quote = FALSE)

res %>%
  filter(type =="learn") %>%
  select(fmri_code, point_start_fmri, point_end_fmri, correct_angle, chosen_angle) %>%
  rename(time = point_start_fmri, time_end = point_end_fmri) %>%
  mutate(duration = time_end - time, angle_error = round(angle_diff(correct_angle, chosen_angle), 4)) %>%
  mutate(time = round(time, 4), duration = round(duration, 4)) %>%
  select(-c(correct_angle, chosen_angle, time_end)) %>%
  write.table(., file.path("exports", "pointing-learn.csv"), row.names = FALSE, sep=",", quote = FALSE)

res %>%
  filter(type=="trial") %>%
  select(fmri_code, point_start_fmri, point_end_fmri, correct_angle, chosen_angle) %>%
  rename(time = point_start_fmri, time_end = point_end_fmri) %>%
  mutate(duration = time_end - time, angle_error = round(angle_diff(correct_angle, chosen_angle), 4)) %>%
  mutate(time = round(time, 4), duration = round(duration, 4)) %>%
  select(-c(correct_angle, chosen_angle, time_end)) %>%
  write.table(., file.path("exports", "pointing-trial.csv"), row.names = FALSE, sep=",", quote = FALSE)
  
## Onsets -----
df_onset_stop <- onset_stop_table.participants(participants, speed_threshold = 10, min_duration = 3, 
                                               still_threshold = 1, still_duration = 1, pause_duration = 0.5)
df_onset_stop <- add_fmri_code(df_onset_stop, "participant", df_preprocessing)

# Adds question information
df_onset_stop$quest <- NA
non_na_res <- res[!is.na(res$time) & !is.na(res$point_start),]
for(i in 1:nrow(non_na_res)){
  line <- non_na_res[i,]
  iFit <- df_onset_stop$ID == line$ID &
          df_onset_stop$time > line$point_start & 
          df_onset_stop$time + df_onset_stop$duration < line$point_start + line$time
  if(sum(iFit) > 0) df_onset_stop[iFit, ]$quest <- line$quest_order_session
}

df_onset_stop <- res %>%
  select(ID, quest=quest_order_session, type) %>%
  right_join(df_onset_stop, by=c("ID", "quest"))

# Exporting
df_onset_stop %>%
  mutate(time = round(fmri_time, 4), duration = round(duration, 4)) %>%
  select(fmri_code, time, duration, movement_type) %>%
  write.table(., file.path("exports","walking.csv"), row.names = FALSE, sep=",", quote = FALSE)

df_onset_stop %>%
  filter(type == "trial") %>%
  mutate(time = round(fmri_time, 4), duration = round(duration, 4)) %>%
  select(fmri_code, time, duration, movement_type) %>%
  write.table(., file.path("exports","walking-trial.csv"), row.names = FALSE, sep=",", quote = FALSE)

df_onset_stop %>%
  filter(type == "learn") %>%
  mutate(time = round(fmri_time, 4), duration = round(duration, 4)) %>%
  select(fmri_code, time, duration, movement_type) %>%
  write.table(., file.path("exports","walking-learn.csv"), row.names = FALSE, sep=",", quote = FALSE)

## Speeds ------
for(id in names(participants)){
  message('writing speed for ', id)
  speeds <- pulse_average_speeds.session(participants[[id]][[1]])
  speeds <- round(speeds, 4)
  fmri_id <- df_preprocessing$fmri_code[df_preprocessing$ID == id]
  filename <- file.path('exports', 'speeds', paste0(fmri_id, '_speed.txt'))
  data.table::fwrite(list(speeds), filename)
}

## Rotations -----
for(id in names(participants)){
  message('writing rotation for ', id)
  rotations <- pulse_sum_rotation.session(participants[[id]][[1]])
  rotations <- round(rotations, 4)
  fmri_id <- df_preprocessing$fmri_code[df_preprocessing$ID == id]
  filename <- file.path('exports', 'rotations', paste0(fmri_id, '_rotation.txt'))
  rotations <- rotations[, c("x", "y", "total")]
  write.table(rotations, filename, sep=",", row.names = FALSE)
}

res_pulses <- data.frame()
for(participant_name in names(hrfs)){
  rot_x <- hrfs[[name]]$rotation_x
  part_res <- res %>% filter(ID == participant_name)
  iPulses <- which(!is.na(part_res$pulse_start) & !is.na(part_res$pulse_end))
  pointing_pulses <- unlist(sapply(iPulses, function(x){seq(part_res$pulse_start[x], part_res$pulse_end[x], by = 1)}))
  non_pointing_pulses <- setdiff(1:400, pointing_pulses)
  res_pulses <- rbind(res_pulses, data.frame(poinitng = mean(rot_x[pointing_pulses]),
                               mot = mean(rot_x[non_pointing_pulses])))
}

res_pulses

library(data.table)
library(navr)
library(dplyr)
source('scripts/loading.R')
DATA_DIR <- "E:/OneDrive/NUDZ/projects/HCENAT/Data/"
CORRECT_ANGLES <- read.table("data/correct-angles.csv", sep=",", header=TRUE)
df_preprocessing <- load_participant_preprocessing_status()

load("participants-prepared.RData")

## Results ----
res <- quest_summary.participants(participants)
res <- add_fmri_code(res, "participant", df_preprocessing)
write.table(res, "exports/participant-performance.csv", sep=";", row.names = FALSE)

## Pulses output ----
df_temp <- res %>%
  mutate(n_pulses = quest_pulse_end - pulse_start + 1) %>%
  select(fmri_code, pulse_start, pulse_end, quest_pulse_end, 
         quest_order_session, n_pulses, type)

df_pulses <- data.frame(fmri_code = rep(unique(res$fmri_code), each = N_PULSES),
                        pulse_id = rep(1:N_PULSES, length(unique(res$fmri_code))),
                        quest_id = NA,
                        is_pointing = FALSE, learn = FALSE, trial = FALSE)

for(i in 1:nrow(df_temp)){
  line <- df_temp[i,]
  if(any(is.na(line))) next
  df_pulses[df_pulses$fmri_code == line$fmri_code &
              df_pulses$pulse_id >= line$pulse_start &
              df_pulses$pulse_id <= line$pulse_end, "is_pointing"] <- TRUE
  df_pulses[df_pulses$fmri_code == line$fmri_code &
              df_pulses$pulse_id >= line$pulse_start &
              df_pulses$pulse_id <= line$quest_pulse_end,
            c(line$type, "quest_id")] <- list(TRUE, line$quest_order_session)
  
}

write.table(df_pulses, "exports/participant-pulses.csv", sep=";", row.names = FALSE)
rm(df_pulses, df_temp)
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
  mutate(duration = time_end - time,
         angle_error = round(angle_diff(correct_angle, chosen_angle), 4)) %>%
  mutate(time = round(time, 4), duration = round(duration, 4)) %>%
  select(-c(correct_angle, chosen_angle, time_end)) %>%
  write.table(., file.path("exports", "pointing-learn.csv"), 
              row.names = FALSE, sep=",", quote = FALSE)

res %>%
  filter(type=="trial") %>%
  select(fmri_code, point_start_fmri, point_end_fmri, correct_angle, chosen_angle) %>%
  rename(time = point_start_fmri, time_end = point_end_fmri) %>%
  mutate(duration = time_end - time, 
         angle_error = round(angle_diff(correct_angle, chosen_angle), 4)) %>%
  mutate(time = round(time, 4), duration = round(duration, 4)) %>%
  select(-c(correct_angle, chosen_angle, time_end)) %>%
  write.table(., file.path("exports", "pointing-trial.csv"), 
              row.names = FALSE, sep=",", quote = FALSE)
  
## Onsets -----
df_onset_stop <- onset_stop_table.participants(participants, 
                                               speed_threshold = 10, 
                                               min_duration = 3,
                                               still_threshold = 1,
                                               still_duration = 1,
                                               pause_duration = 0.5)
df_onset_stop <- add_fmri_code(df_onset_stop, "participant", df_preprocessing)

# Adds questing information
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



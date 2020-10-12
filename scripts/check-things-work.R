library(tidyverse)
source("scripts/loading.R")

PARTICIPANT_CODE <- "HCE_E_10"

load("participants-prepared.RData")
df_results <- read.table("exports/participant-performance.csv", 
                         sep = ";", header = TRUE)

df_preprocessing <- load_participant_preprocessing_status()

FMRI_CODE <- fmri_code(PARTICIPANT_CODE, df_preprocessing)
participant <- participants[[PARTICIPANT_CODE]][[1]]
df_player <- participant$player_log
df_player$time_since_start <- df_player$Time - df_player$Time[1]
df_player$fmri_time <- df_player$Time - get_first_pulse_time(df_player)

## check onsets and stops -----
df_onsets_stops <- read.table(file.path("exports", "events", "walking.csv"), 
                              sep = ",", header = TRUE)
df_onsets_stops <- df_onsets_stops %>%
  filter(fmri_code == FMRI_CODE)

onset <- df_onsets_stops %>% filter(movement_type == "moving") %>% .[20,]

df_player %>%
  filter(fmri_time > onset$time, fmri_time < onset$time + onset$duration) %>%
  ggplot(aes(x=Time, y=distance)) + geom_line()

df_onsets[1,]

## Check the pulses ----
df_pulses <- read.table("exports/participant-pulses.csv", sep = ";", 
                        header = TRUE)
df_pulses <- filter(df_pulses, fmri_code == FMRI_CODE)
i_still <- df_pulses %>%
  filter(is_pointing) %>%
  pull(pulse_id)

# participant should be stationary during pointing
df_player %>%
  filter(pulse_id %in% i_still) %>%
  ggplot(aes(Position.x, Position.z)) + geom_point()

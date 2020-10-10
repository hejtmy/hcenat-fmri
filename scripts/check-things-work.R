library(tidyverse)

PARTICIPANT_CODE <- "HCE_E_10"

load("participants-prepared.RData")
df_results <- read_table("exports/participant-performance.csv", 
                         sep = ";", header = TRUE)

df_preprocessing <- load_participant_preprocessing_status()

FMRI_CODE <- fmri_code(PARTICIPANT_CODE, df_preprocessing)
participant <- participants[[PARTICIPANT_CODE]][[1]]
df_player <- participant$player_log
df_player$time_since_start <- df_player$Time - df_player$Time[1]
df_player$fmri_time <- df_player$Time - get_first_pulse_time(df_player)

## check onsets and stops -----
df_onsets_stops <- read.table(file.path("exports", "walking.csv"), 
                              sep = ",", header = TRUE)
df_onsets_stops <- df_onsets_stops %>%
  filter(fmri_code == FMRI_CODE)

onset <- df_onsets_stops %>% filter(movement_type=="moving") %>% .[20,]

df_player %>%
  filter(fmri_time > onset$time, fmri_time < onset$time+onset$duration) %>%
  ggplot(aes(x=Time, y=distance)) + geom_line()

df_onsets[1,]

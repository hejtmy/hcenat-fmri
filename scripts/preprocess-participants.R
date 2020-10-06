library(data.table)
library(navr)
library(dplyr)
sapply(list.files("functions", full.names = TRUE, recursive = TRUE), source)
DATA_DIR <- "E:/OneDrive/NUDZ/projects/HCENAT/Data/"

df_preprocessing <- load_participant_preprocessing_status()

## Unity loading -----
participants <- load_participants(DATA_DIR, df_preprocessing = df_preprocessing,
                                  sessions = 1)
participants_all <- add_pulses.participants(participants, clean = FALSE)
participants <- add_pulses.participants(participants, clean = TRUE)

## ALREADY READY FILES ------
save(participants, file = "participants-prepared.RData")
save(participants_all, file = "participants-prepared-uncleaned.RData")

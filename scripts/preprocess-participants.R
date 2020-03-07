library(data.table)
library(navr)
library(dplyr)
library(ez)
sapply(list.files("functions", full.names = T, recursive = T), source)
CORRECT_ANGLES <- read.table("data/correct-angles.csv", sep=",", header=TRUE)

df_preprocessing <- load_participant_preprocessing_status()

## Unity loading -----
participants <- load_participants(DATA_DIR, df_preprocessing = df_preprocessing, sessions = 1)
participants <- add_pulses.participants(participants, clean = TRUE)

# Chekc how many participants were not synchronized and why


## ALREADY READY FILES ------
save(participants, file = "participants-prepared.RData")
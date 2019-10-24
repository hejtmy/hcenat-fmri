library(data.table)
library(navr)
library(dplyr)
sapply(list.files("functions", full.names = T, recursive = T), source)
CORRECT_ANGLES <- read.table("data/correct-angles.csv", sep=",", header=TRUE)

data_dir <- "E:/OneDrive/NUDZ/projects/HCENAT/Data/"
img_path <- "images/megamap5.png"

df_preprocessing <- load_participant_preprocessing_status()

## Unity loading -----
participants <- load_participants(data_dir, df_preprocessing = df_preprocessing, sessions = 1)
participants <- add_pulses_participants(participants)

## MRI loading ------
folder <- file.path(data_dir, "../MRI-data-tomecek/filtered")
names_file <- file.path(data_dir, "../MRI-data-tomecek/subs_20190830_1422.txt")
components <- load_mri(folder, names_file)
components <- rename_mri_participants(components, df_preprocessing)
fmri <- restructure_mri(components)

## Analysis ----
quest <- get_quest(participant[[1]]$quests_logs, 13)
get_correct_angle(quest, participant[[1]]$player_log)
plot_quest_path.participant(participant[[2]], 3, img_path)
quest_pointing_accuracy(quest, participant[[1]]$player_log)
library(data.table)
library(navr)
library(dplyr)

sapply(list.files("functions", full.names = T, recursive = T), source)
DATA_DIR <- "E:/OneDrive/NUDZ/projects/HCENAT/Data/"
# source("scripts/preprocess-participants.R")
CORRECT_ANGLES <- read.table(file.path(DATA_DIR, "correct-angles.csv"), sep=",", header=TRUE)

load("participants-prepared.RData")
img_path <- "images/megamap5.png"
participant_code <- "HCE_E_13"

participant <- participants[[participant_code]][[1]]

## MRI loading ------
folder <- file.path(data_dir, "../MRI-data-tomecek/filtered")
names_file <- file.path(data_dir, "../MRI-data-tomecek/subs_20190830_1422.txt")
components <- load_mri(folder, names_file)
components <- rename_mri_participants(components, df_preprocessing)
fmri <- restructure_mri(components)

## Analysis ----
quest <- get_quest(participant$quests_logs, 13)
get_correct_angle(quest, participant$player_log)
plot_quest_path.session(participant, 3, img_path)
quest_pointing_accuracy(quest, participant$player_log)
pointing_results.session(participant)

## fmri analysis ----
movement_pulses <- onset_stop_table.session(participant, speed_threshold = 10, min_duration = 3,
                                            still_threshold = 1, still_duration = 1, pause_duration = 0.3)

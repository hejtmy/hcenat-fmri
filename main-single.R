library(data.table)
library(navr)
library(dplyr)
sapply(list.files("functions", full.names = T, recursive = T), source)
CORRECT_ANGLES <- read.table("data/correct-angles.csv", sep=",", header=TRUE)

data_dir <- "E:/OneDrive/NUDZ/projects/HCENAT/Data/"
img_path <- "images/megamap5.png"
participant_code <- "HCE_E_10"
df_preprocessing <- load_participant_preprocessing_status()

## Unity loading -----
participants <- load_participants(data_dir, participant_code, df_preprocessing)
participants <- add_pulses.participants(participants)
participant <- participants[[participant_code]]

## MRI loading ------
folder <- file.path(data_dir, "../MRI-data-tomecek/filtered")
names_file <- file.path(data_dir, "../MRI-data-tomecek/subs_20190830_1422.txt")
components <- load_mri(folder, names_file)
components <- rename_mri_participants(components, df_preprocessing)
fmri <- restructure_mri(components)

## Analysis ----
quest <- get_quest(participant[[1]]$quests_logs, 13)
get_correct_angle(quest, participant[[1]]$player_log)
plot_quest_path.session(participant[[2]], 3, img_path)
quest_pointing_accuracy(quest, participant[[1]]$player_log)
pointing_results.session(participant[[1]])

## fmri analysis ----
movement_pulses <- create_movement_pulses_table.session(participant[[1]], 3, 0.2, 5, 0.9) %>% mutate(session=1, participant=participant_code)
movement_fmri <- get_fmri(fmri, movement_pulses)
movement_fmri %>% filter(movement_type=="still") %>% lm(rotation_sum ~ filt_cen_11, data = .) %>% summary()

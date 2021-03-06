library(data.table)
library(navr)
library(dplyr)

library(googlesheets4)

sapply(list.files("functions", full.names = TRUE, recursive = TRUE), source)
CORRECT_ANGLES <- read.table("data/correct-angles.csv", sep=",", header=TRUE)

data_dir <- "E:/OneDrive/NUDZ/projects/HCENAT/Data/"
participant <- "HCE_E_1"
img_path <- "images/megamap5.png"
data <- load_participant(data_dir, participant)

df_quests <- df_quests_info(session$quests_logs)
df_player <- add_pulses_player(df_quests, session$quests_logs, session$player_log)

df_quests <- df_quests_info(data[[1]]$quests_logs)
pointing_results(data[[1]]$quests_logs, data[[1]]$player_log, correct_angles)

quest <- get_quest(data[[1]]$quests_logs, 12)
quest_summary(quest, data[[1]]$player_log)
quests_summary(df_quests, data[[1]]$quests_logs, data[[1]]$player_log)

plot_quest_path(get_quest(data[[1]]$quests_logs, 3), data[[1]]$player_log, data[[1]]$experiment_log, img_path)

## participant checking ----
all_participants <- list.dirs(data_dir, recursive = FALSE, full.names = FALSE)
i <- 26
participant <- all_participants[i]
participant
data <- load_participant(data_dir, participant)
check_data_participant(data)
quests_summary_participant(data[[1]], correct_angles)
warnings()

## Preprocessing
#pth <- file.path(data_dir, "HCE_K_24", "MRI", "Session2")
#read_unity_data(pth, override = T)

## loading final ----
df_preprocessing <- load_participant_preprocessing_status()
participants <- load_participants(data_dir, df_preprocessing = df_preprocessing, sessions = 1)

quest <- get_quest(participant$HCE_K_23[[1]]$quests_logs, 13)
get_correct_angle(quest, participant$HCE_K_23[[1]]$player_log)
plot_quest_path.session(participant$HCE_K_23[[2]], 3, img_path)
quest_pointing_accuracy(quest, participant$HCE_K_23[[1]]$player_log)

## Onsets
df <- onset_stop_table.session(participant[[1]], 3, 0.2, 5)
df %>% 
  filter(movement_type == "moving" & !is.na(pulse_id)) %>% 
  ggplot(aes(position_x, position_y, color=factor(pulse_id))) + 
    geom_path() + 
    theme(legend.position = "none")
df %>% 
  filter(movement_type == "still" & !is.na(pulse_id)) %>% unique() %>% 
  ggplot(aes(position_x, position_y, color=factor(pulse_id))) + 
    geom_jitter(width = 20, height = 20) + 
    theme(legend.position = "none")

## investigation of pulses ----
# difference between 1st and last
sum(diff(participant$HCE_E_14[[1]]$player_log %>% filter(Input == "fMRISynchro") %>% .$Time))
which((diff(participant$HCE_E_14[[1]]$player_log %>% filter(Input == "fMRISynchro") %>% .$Time) - 3))

# Soilution
participant <- add_pulses_participant(participant)

## MRI -----
folder <- file.path(data_dir, "../MRI-data-tomecek/filtered")
names_file <- file.path(data_dir, "../MRI-data-tomecek/subs_20190830_1422.txt")
components <- load_mri(folder, names_file)

create_movement_pulses_table.session(participant[[1]], 3,0.2,5,0.9) 

## Pointing
for(i in 1:20){
  quest <- get_quest(participant[[1]]$quests_logs, i)
  print(quest$type)
}

pointing_results.session(participant[[1]])


plot_quest_path.session(participant[[1]], 1)

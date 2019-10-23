library(data.table)
library(navr)
library(dplyr)
sapply(list.files("functions", full.names = T, recursive = T), source)
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
participant <- load_participants(data_dir, c("HCE_K_23"), df_preprocessing)

quest <- get_quest(participant$HCE_K_23[[1]]$quests_logs, 13)
get_correct_angle(quest, participant$HCE_K_23[[1]]$player_log)
plot_quest_path.participant(participant$HCE_K_23[[2]], 3, img_path)
quest_pointing_accuracy(quest, participant$HCE_K_23[[1]]$player_log)
## investigation of pulses ----
# difference between 1st and last
sum(diff(participant$HCE_E_14[[1]]$player_log %>% filter(Input == "fMRISynchro") %>% .$Time))
which((diff(participant$HCE_E_14[[1]]$player_log %>% filter(Input == "fMRISynchro") %>% .$Time) - 3))

# Soilution
pokus <- add_pulses_participant(participant$HCE_K_23[[2]])

library(data.table)
library(navr)
library(dplyr)
sapply(list.files("functions", full.names = T, recursive = T), source)

correct_angles <- read.table("data/correct-angles.csv", sep=",", header=TRUE)
data_dir <- "E:/OneDrive/NUDZ/projects/HCENAT/Data/"
participant <- "HCE_E_1"
data <- load_participant(data_dir, participant)

df_quests <- df_quests_info(session$quests_logs)
df_player <- add_pulses_player(df_quests, session$quests_logs, session$player_log)

df_quests <- df_quests_info(data[[1]]$quests_logs)
pointing_results(df_quests, data[[1]]$quests_logs, data[[1]]$player_log, correct_angles)

quest <- get_quest(df_quests, data[[1]]$quests_logs, 12)
quest_summary(quest, data[[1]]$player_log)
quests_summary(df_quests, data[[1]]$quests_logs, data[[1]]$player_log)

plot_quest_path(get_quest(df_quests, session$quests_logs, 3), df_player, session$experiment_log, img_path)

## participant checking ----
all_participants <- list.dirs(data_dir, recursive = FALSE, full.names = FALSE)
i <- 26
participant <- all_participants[i]
participant
data <- load_participant(data_dir, participant)
check_data_participant(data)
quests_summary_participant(data[[1]], correct_angles)
warnings()

## loading final ----
df_preprocessing <- load_participant_preprocessing_status()
participants <- list()
for(i in 1:nrow(df_preprocessing)){
  line <- df_preprocessing[i,]
  participant_data <- list()
  if(line$session1_ok){
    data <- load_participant(data_dir, participant, 1)
    participant_data[[1]] <- data[[1]]
  }
  if(line$session2_ok){
    data <- load_participant(data_dir, participant, 2)
    participant_data[[2]] <- data[[1]]
  }
  participants[[line$ID]] <- participant_data
}

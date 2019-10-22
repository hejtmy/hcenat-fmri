library(data.table)
library(navr)
library(dplyr)
sapply(list.files("functions", full.names = T, recursive = T), source)

img_path <- "images/megamap5.png"
folder <- "E:/OneDrive/NUDZ/projects/HCENAT/Data/HCE_E_14/MRI/Session1"
session <- read_unity_data(folder)

df_quests <- df_quests_info(session$quests_logs)
df_player <- add_pulses_player(df_quests, session$quests_logs, session$player_log)

correct_angles <- read.table("data/correct-angles.csv", sep=",", header=TRUE)

df_pointing_results(df_quests, session$quests_logs, session$player_log, correct_angles)

quest <- get_quest(df_quests, session$quests_logs, 2)
plot_quest_path(get_quest(df_quests, session$quests_logs, 3), df_player, session$experiment_log, img_path)

data_dir <- "E:/OneDrive/NUDZ/projects/HCENAT/Data/"
participant <- "HCE_E_1"
data <- load_participant(data_dir, participant, 2)

df_quests <- df_quests_info(data[[1]]$quests_logs)
pointing_results(df_quests, data[[1]]$quests_logs, data[[1]]$player_log, correct_angles)
quests_summary(df_quests, data[[1]]$quests_logs, data[[1]]$player_log)




res <- quests_summary_participant(data[[1]])

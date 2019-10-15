library(data.table)
library(navr)
sapply(list.files("functions", full.names = T, recursive = T), source)

folder <- "F:/projects/hcenat/Data/HCE_E_1/MRI/Session1"
folder <- "E:/OneDrive/NUDZ/projects/HCENAT/Data/HCE_E_14/MRI/Session1"
session <- read_unity_data(folder)

df_quests <- df_quests_info(session$quests_logs)
df_player <- add_pulses_player(df_quests, session$quests_logs, session$player_log)

df_pointing_results(df_quests, session$quests_logs, session$player_log)

quest <- get_quest(df_quests, session$quests_logs, 2)
plot_quest_path(quest, df_player, session$experiment_log, img_path)

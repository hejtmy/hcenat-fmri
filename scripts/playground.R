library(data.table)
sapply(list.files("functions", full.names = T, recursive = T), source)

folder <- "F:/projects/hcenat/Data/HCE_E_1/MRI/Session1"
folder <- "E:/OneDrive/NUDZ/projects/HCENAT/Data/HCE_E_12/MRI/Session1"
session <- read_unity_data(folder)
df_quests <- df_quests_info(session$quests_logs)

df_player <- add_pulses_player(df_quests, session$quests_logs, session$player_log)

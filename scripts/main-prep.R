#libraries in correct order
library('R6')
library('data.table')
library('dplyr')
library('stringr')
library('ggplot2')

data_dir <- "M:/OneDrive/NUDZ/HCENAT/Data/"

subject_table <- read.table(paste(data_dir, "ListOfSubjects.csv", sep = ""), sep = ",", 
                           header = T, stringsAsFactors = F, na.strings = c(""))

SESSION <- 1

subject_table <- subject_table[c(16, 18), ]

source('scripts/loading.r')

#loads from the subjectList table
# dir = dir of all data
# paritcipatn code = code overall
# session = session
subject_code <- subject_table[1, "ID"]
session_code <- subject_table[1, "VR_MRI_1"]
subject_dir <- paste0(data_dir, subject_code, "/MRI/", "Session1/")

ls <- open_experiment_logs(subject_dir)
#for each experiment_log, we open player log, scenario log and appropriate quest logs
self$trial_sets = list()
for (i in 1:length(ls)){
  experiment_log <- ls[[i]]
  player_log <- open_player_log(experiment_log, F)
  #preprocesses player log
  #checks if there is everything we need and if not, recomputes the stuff
  if(is.null(player_log)) next
  if (override) SavePreprocessedPlayer(experiment_log, player_log)
  scenario_log <- open_scenario_log(experiment_log)
  quests_logs <- open_quests_logs(experiment_log, scenario_log)
  
  session <- list(experiment_log, player_log, scenario_log, quests_logs)
}
#self$quest_set = make_quest_set(self$trial_sets)
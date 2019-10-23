read_unity_data <- function(folder, override = FALSE){
  experiment_logs <- open_experiment_logs(folder)
  if(length(experiment_logs) != 1){
    warning('there are more experiment logs ion the folder')
    return(NULL)
  }
  response <- list()
  experiment_log <- experiment_logs[[1]]
  player_log <- open_player_log(experiment_log, override)
  if(is.null(player_log)) next
  if(override) SavePreprocessedPlayer(experiment_log, player_log)
  scenario_log <- open_scenario_log(experiment_log)
  quests_logs <- open_quests_logs(experiment_log, scenario_log)
  response <- list(experiment_log = experiment_log,
                     player_log = player_log,
                     scenario_log = scenario_log,
                     quests_logs = quests_logs)
  return(response)
}

SavePreprocessedPlayer <- function(experiment_log, pos_tab){
  directory <- dirname(experiment_log$filename)
  ptr <- paste("_player_", experiment_log$header$Time, sep="", collapse="")
  log <- list.files(directory, pattern = ptr ,full.names = T)[1]
  #writes preprocessed file
  preprocessed_filename <- gsub(".txt","_preprocessed.txt",log)
  message("Saving processed player log as", preprocessed_filename)
  write.table(pos_tab, preprocessed_filename, sep=";", dec=".", quote=F, row.names = F)
}
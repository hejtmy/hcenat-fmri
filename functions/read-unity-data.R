read_unity_data <- function(folder, override = FALSE){
  ls  <- open_experiment_logs(folder)
  #for each experiment_log, we open player log, scenario log and appropriate quest logs
  response <- list()
  for (i in 1:length(ls)){
    experiment_log <- ls[[i]]
    player_log <- open_player_log(experiment_log, F)
    #preprocesses player log
    #checks if there is everything we need and if not, recomputes the stuff
    if(is.null(player_log)) next
    if (override) SavePreprocessedPlayer(experiment_log, player_log)
    scenario_log <- open_scenario_log(experiment_log)
    quests_logs <- open_quests_logs(experiment_log, scenario_log)
    
    response[[i]] <-  list(experiment_log = experiment_log,
                           player_log = player_log,
                           scenario_log = scenario_log,
                           quests_logs = quests_logs)
  }
  return(response)
}
open_scenario_log <- function(experiment_log){
  if(is.null(experiment_log$scenario$Name)) return (NULL)
  directory <- dirname(experiment_log$filename)
  ptr <- paste("_", escape_quest_regex(experiment_log$scenario$Name), "_", experiment_log$scenario$Timestamp, sep="")
  log <- list.files(directory, pattern = ptr, full.names = T)[1]
  if(!file.exists(log)){
    warning("Could not find the file for scenario log with pattern ", ptr)
    return(NULL)
  }
  scenario_log <- open_quest_log(log)
  return(scenario_log)
}
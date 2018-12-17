open_scenario_log <- function(experiment_log){
  if(is.null(experiment_log$scenario$Name)) return (NULL)
  directory <- dirname(experiment_log$filename)
  ptr <- paste("_", escape_quest_regex(experiment_log$scenario$Name), "_", experiment_log$scenario$Timestamp, sep="")
  #needs to check if we got only one file out
  log <- list.files(directory, pattern = ptr, full.names = T)[1]
  #if the file does not exists returning NULL and exiting
  if(!file.exists(log)){
    print(paste("!!!Could not find the file for scenario log!!!", ptr, sep = " "))
    print(ptr)
    return(NULL)
  }
  scenario_log <- open_quest_log(log)
  return(scenario_log)
}
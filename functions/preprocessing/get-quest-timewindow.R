get_quest_timewindow <- function(quest, include_teleport = T){
  if(include_teleport){
    start_time <- quest$data$TimeFromStart[quest$data$Action == "Quest started"]
  }else{
    start_time <- get_teleport_times(quest)$finish
  }
  end_time <- quest$data$TimeFromStart[quest$data$Action == "Quest finished"]
  #if there never was end of the quest
  if (length(end_time) < 1) end_time <- tail(quest$data,1)$TimeFromStart
  ls <- list()
  ls[["start"]] <- start_time
  ls[["finish"]] <- end_time
  return(ls)
}

get_teleport_times <- function(quest = NULL){
  if(is.null(quest)){
    SmartPrint(c("ERROR:get_teleport_times", "Quest log not reachable"))
    return(NULL)
  } 
  ls <- list()
  ls[["start"]] <- get_step_time(quest, "Teleport Player")
  ls[["finish"]] <- get_step_time(quest, "Teleport Player", "StepFinished")
  return(ls)
}
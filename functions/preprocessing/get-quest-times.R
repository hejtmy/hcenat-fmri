#' Title
#'
#' @param quest quest as returned by get_quest
#' @param include_teleport should the teleporting time be included.
#'
#' @return
#' @export
#'
#' @examples
get_quest_timewewindow <- function(quest, include_teleport = TRUE){
  if(include_teleport){
    start_time <- quest$data$TimeFromStart[quest$data$Action == "Quest started"]
  } else {
    start_time <- get_teleport_times(quest)$finish
  }
  end_time <- quest$data$TimeFromStart[quest$data$Action == "Quest finished"]
  #if there never was end of the quest
  if (length(end_time) < 1) end_time <- tail(quest$data,1)$TimeFromStart
  result <- list()
  result[["start"]] <- start_time
  result[["finish"]] <- end_time
  return(result)
}

#' Returns list(start, finish) with player times of teleports
#'
#' @param quest what quest for
#'
#' @return
#' @export
#'
#' @examples
get_teleport_times <- function(quest){
  result <- list()
  result[["start"]] <- get_step_time(quest, "Teleport Player")
  result[["finish"]] <- get_step_time(quest, "Teleport Player", "StepFinished")
  return(result)
}

#' Title
#'
#' @param quest 
#' @param step_name 
#' @param step_action 
#' @param step_id 
#'
#' @return
#' @export
#'
#' @examples
get_step_time <- function(quest, step_name, step_action = "StepActivated", step_id = NULL){
  if(!is.null(step_id)){
    stepTime <- quest$data$TimeFromStart[quest$data$StepID == step_id & quest$data$Action == step_action]
  } else {
    stepTime <- quest$data$TimeFromStart[quest$data$StepType == step_name & quest$data$Action == step_action]
  }
  if(length(stepTime) > 1){ 
    SmartPrint(c("ERROR:getStepTime", quest$name, "TYPE:", "There is more steps of the same parameters: ", step_action))
    return(NULL)
  }
  if(length(stepTime) == 0) return(NULL)
  return(stepTime)
}
#' Get time of window 
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
#' @return
get_teleport_times <- function(quest){
  result <- list()
  result[["start"]] <- get_step_time(quest, "Teleport Player")
  result[["finish"]] <- get_step_time(quest, "Teleport Player", "StepFinished")
  return(result)
}

#' Get times of certain steps
#'
#' @param quest 
#' @param step_name 
#' @param step_action 
#' @param step_id 
#' @return
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

#' Get times of evets happening in player log
#'
#' @param df_player 
#' @param event_name 
#' @return
get_event_times = function(df_player, event_name = NULL){
  dt_events <- df_player[Input != "", .(Time, Input)]
  if(nrow(dt_events) == 0) return(NULL)
  if(!is.null(event_name)){
    dt_events <- dt_events[Input == event_name]
  }
  return(dt_events)
}

#' returns data frame with all occurances of certain step type in a form of StepID, StepActivated, StepFinished
#' 
#' @param quest Loaded quest list as by get_quest
#' @param step_name Name of the step, ex. "Point in Direction"
#' @return dataframe
get_step_timespans <- function(quest, step_name){
  step_times <- quest$data[quest$data$StepType == step_name, c("TimeFromStart", "Action", "StepID")]
  if(nrow(step_times) < 1 ) return(NULL)
  # it is possible to extract only one part of the quest (e.g. was only activated or only finnished)
  step_times <- reshape(step_times, timevar = c("Action"), idvar = "StepID", direction = "wide")
  if(ncol(step_times) != 3){
    warning("Step doesn't have complete acitvation and finish ", quest$name)
    return(NULL)
  }
  colnames(step_times) <- c("StepID", "StepActivated", "StepFinished")
  return(step_times)
}

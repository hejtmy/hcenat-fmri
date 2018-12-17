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
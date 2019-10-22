#' Title
#'
#' @param quest_set 
#' @param quest 
#' @param include_teleport 
#'
#' @return
#' @export
#'
#' @examples
get_quest_start_finish_positions <- function(df_player, quest, include_teleport = FALSE){
  response <- list()
  time_teleport_finished <- get_quest_timewindow(quest, include_teleport = include_teleport)$start
  response[["start"]] <- get_player_position_at_time(df_player, time_teleport_finished)
  if(is.null(response[["start"]])) return(NULL)
  response[["finish"]] <- get_last_quest_position(quest)
  return(response)
}

get_player_position_at_time <- function(df_player, time){
  position <- df_player[Time > time, .SD[1, c(Position.x, Position.z)]]
  return(position)
}

get_last_quest_position <- function(quest){
  i_transforms <- quest$steps$ID[quest$steps$Transform != "NO transform"]
  if(length(i_transforms) == 0) stop("There are no quest steps with transforms")
  i_last <- tail(i_transforms, 1)
  return(quest_step_position(quest, i_last))
}

quest_step_position = function(quest, iStep){
  step <- quest$steps %>% dplyr::filter(ID == iStep)
  if(nrow(step) == 0) stop("There is no step of id", iStep)
  if(step$Transform == "NO transform") stop("Step has no transform")
  return(text_to_vector3(step$Transform)[c(1,3)])
}


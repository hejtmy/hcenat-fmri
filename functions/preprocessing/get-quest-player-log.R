#' Extracts playuer log information only for the duration of the quest
#' 
#' @param quest_set Important because of the information about the set in which quest took place
#' 
get_quest_player_log <- function(quest_set, quest_logs, quest, include_teleport = T){
  if(!is.null(quest)) quest_line = filter(quest_set, order_session == quest$order_session)
  if(nrow(quest_line) > 1){
    print("player_log_quest:: Multiple quests have the same name")
    return(NULL)
  }
  quest_times <- get_quest_timewindow(quest, include_teleport = include_teleport)
  player_log <- trial_sets[[quest_line$set_id]]$player_log[Time > quest_times$start & Time < quest_times$finish,]
  return(player_log)
}
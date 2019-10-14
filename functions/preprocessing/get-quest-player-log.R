#' Extracts player log information only for the duration of the quest
#'
#' @param quest quest object from the get_quest
#' @param df_player player log from the session
#' @param include_teleport should the teleport be included
get_quest_player_log <- function(quest, df_player, include_teleport = TRUE){
  quest_line <- dplyr::filter(df_quests, order_session == quest$order_session)
  if(nrow(quest_line) > 1){
    warning("player_log_quest:: Multiple quests have the same name")
    return()
  }
  quest_times <- get_quest_timewindow(quest, include_teleport)
  df_player <- df_player[Time > quest_times$start & Time < quest_times$finish, ]
  return(df_player)
}
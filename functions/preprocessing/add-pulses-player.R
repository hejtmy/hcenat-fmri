#' Adds pulses information to the player log
#'
#' @param df_quests dataframe as created by the df_quests_info function
#' @param quests_logs quest logs loaded by the read_unity_data function
#' @param df_player player log loaded by the read_unity_data funtcion
#'
#' @return df_player with added quest and pulse columns
#'
#' @examples
add_pulses_player <- function(df_quests, quests_logs, df_player){
  df_player$pulse <- NA_integer_
  df_player$quest <- NA_integer_
  for(i in 1:nrow(df_quests)){
    quest <- get_quest(df_quests, quests_logs, i)
    quest_times <- get_quest_timewindow(quest, include_teleport = T) #can be null
    df_player[Time > quest_times$start & Time < quest_times$finish, quest := i]
  }
  iSynchro <- which(df_player$Input == "fMRISynchro")
  nSynchro <- length(iSynchro)
  if(length(nSynchro) < 1){
    warning('there are no Synchropulses in the player log')
    return(df_player)
  } 
  for(iPulse in 1:nSynchro){
    df_player$pulse[iSynchro[iPulse]:iSynchro[nSynchro]] <- iPulse
  }
  return(df_player)
}
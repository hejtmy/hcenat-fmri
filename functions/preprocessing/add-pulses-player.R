#' Title
#'
#' @param participants 
#' @param clean shoud non synchronized participants be removed
#'
#' @return
#' @export
#'
#' @examples
add_pulses.participants <- function(participants, clean = TRUE){
  for(participant_name in names(participants)){
    message("Adding pulses to ", participant_name)
    participants[[participant_name]] <- add_pulses_participant(participants[[participant_name]])
    if(!clean) next
    for(i in 1:length(participants[[participant_name]])){
      if(is.null(participants[[participant_name]][[i]])) next
      if(!("pulse_id" %in% colnames(participants[[participant_name]][[i]]$player_log))){
        message(participant_name, "session ", i," was not synchronized, removing from the object")
        participants[[participant_name]][[i]] <- NULL
      }
    }
  }
  return(participants)
}

#' Adds pulses to participant data
#'
#' @param data data list as loaded by load_participant
add_pulses.participant <- function(participant){
  for(i in 1:length(participant)){
    if(is.null(participant[[i]])) next
    participant[[i]]$player_log <- add_pulses_player(participant[[i]]$quests_logs, participant[[i]]$player_log)
  }
  return(participant)
}

#' Adds pulses information to the player log
#'
#' @param quests_logs quest logs loaded by the read_unity_data function
#' @param df_player player log loaded by the read_unity_data funtcion
#' @return df_player with added quest and pulse columns
add_pulses_player <- function(quests_logs, df_player){
  df_player$quest_id <- NA_integer_
  for(i in 1:length(quests_logs)){
    quest <- get_quest(quests_logs, i)
    quest_times <- get_quest_timewindow(quest, include_teleport = FALSE) #can be null
    df_player[Time > quest_times$start & Time < quest_times$finish, quest_id := i]
  }
  iSynchro <- which(df_player$Input == "fMRISynchro")
  nSynchro <- length(iSynchro)
  if(length(nSynchro) < 1){
    warning('there are no Synchropulses in the player log')
    return(df_player)
  } 
  ## DO the check
  # 1st and last need to be 1197 (400 pulses by 3s with 1st at 0) s away from each other
  first_last_difference <- df_player$Time[iSynchro[nSynchro]] - df_player$Time[iSynchro[1]]
  if(abs((first_last_difference - 1197)) > 0.05){
    warning("First and last pulse are not 1197 s away, but ", first_last_difference,", not synchronizing")
    return(df_player)
  }
  df_player$pulse_id <- NA_integer_
  firstPulse <- df_player$Time[iSynchro[1]]
  for(i in 0:399){
    pulseTime <- c(firstPulse + 3*i, firstPulse + 3*(i+1))
    df_player[Time > pulseTime[1] & Time < pulseTime[2], pulse_id:= i+1]
  }
  return(df_player)
}
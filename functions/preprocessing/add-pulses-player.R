#' Adds pulses AND QUEST IDs to all participants in the object
#'
#' @param participants participants object created by load participants function 
#' @param clean shoud non synchronized participants be removed
#'
#' @return participants structure
add_pulses.participants <- function(participants, clean = TRUE){
  for(participant_name in names(participants)){
    message("Adding pulses to ", participant_name)
    participants[[participant_name]] <- add_pulses.participant(participants[[participant_name]])
    if(!clean) next
    #runs for each of the 4 experiemnts
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

#' Adds pulses AND QUEST IDs to participant data
#'
#' @param data data list as loaded by load_participant
add_pulses.participant <- function(participant){
  for(i in 1:length(participant)){
    if(is.null(participant[[i]])) next
    participant[[i]]$player_log <- add_pulses_player(participant[[i]]$player_log)
    participant[[i]]$player_log <- add_quest_ids_player(participant[[i]]$player_log, 
                                                        participant[[i]]$quests_logs)
  }
  return(participant)
}

#' Adds pulses information to the player log
#'
#' IMPORTANT: This function actually only looks for the fistt and last Synchropulse as logged
#' in the player log. If they are really N_PULSES * PULSE_LENGTH away from each other,
#' e.g. fMRI shoudl ahve lasted 1197 s and first and last ARE 1197s away from each other, 
#' then all other pulses are just added each PULSE_LENGTH.
#' 
#' @param quests_logs quest logs loaded by the read_unity_data function
#' @param df_player player log loaded by the read_unity_data funtcion
#' @return df_player with added quest and pulse columns
add_pulses_player <- function(df_player){
  ## Adding pulse information to the table
  iSynchro <- which(df_player$Input == "fMRISynchro")
  nSynchro <- length(iSynchro)
  
  ### Validations
  if(length(nSynchro) < 1){
    warning('there are no Synchropulses in the player log')
    return(df_player)
  } 
  # 1st and last need to be 1197 (400 pulses by 3s with 1st at 0) 
  first_last_difference <- df_player$Time[iSynchro[nSynchro]] - df_player$Time[iSynchro[1]]
  RECORDING_LENGTH <- (N_PULSES-1) * PULSE_LENGTH
  if(abs((first_last_difference - RECORDING_LENGTH)) > 0.1){
    warning("First and last pulse are not",  RECORDING_LENGTH, " s away, but ", first_last_difference,", not synchronizing")
    return(df_player)
  }
  
  ### Adds the pulses into the pulses column
  df_player$pulse_id <- NA_integer_
  firstPulse <- df_player$Time[iSynchro[1]]
  for(i in 0:(N_PULSES-1)){
    pulseTime <- c(firstPulse + PULSE_LENGTH*i, firstPulse + PULSE_LENGTH * (i+1))
    df_player[Time > pulseTime[1] & Time < pulseTime[2], pulse_id:= i+1]
  }
  return(df_player)
}

add_quest_ids_player <- function(df_player, quests_logs){
   ## Adding quest ids to the player table
  df_player$quest_id <- NA_integer_
  for(i in 1:length(quests_logs)){
    quest <- get_quest(quests_logs, i)
    quest_times <- get_quest_timewindow(quest, include_teleport = FALSE) #can be null
    df_player[Time > quest_times$start & Time < quest_times$finish, quest_id := i]
  } 
  return(df_player)
}
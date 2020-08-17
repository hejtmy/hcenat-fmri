quest_summary.participants <- function(obj){
  res <- data.frame()
  for(participant_name in names(obj)){
    message("calculating for participant ", participant_name)
    participant <- obj[[participant_name]]
    df_participant <- quests_summary.participant(participant)
    df_participant$participant <- participant_name
    if(nrow(df_participant) > 0) res <- rbind(res, df_participant)
  }
  return(res)
}

quests_summary.participant <- function(obj){
  res <- data.frame()
  for(i in length(obj)){
    df_session <- quests_summary.session(obj[[1]])
    df_session$session <- i
    if(nrow(df_session) > 0) res <- rbind(res, df_session)
  }
  return(res)
}

quests_summary.session <- function(data){
  df_quests <- df_quests_info(data$quests_logs)
  pointing <- pointing_results.session(data)
  result <- quests_summary(df_quests, data$quests_logs, data$player_log)
  if(!is.null(pointing)){
    result <- merge(pointing, result, by=c("name", "quest_order_session"), all=TRUE)
  }
  return(result)
}

#' @param df_quests dataframe as created by the df_quests_info function
#' @param df_player 
quests_summary <- function(df_quests, quests_logs, df_player){
  df_result <- data.frame()
  for(i in 1:nrow(df_quests)){
    quest <- get_quest(quests_logs, i)
    quest_info <- quest_summary(quest, df_player)
    df_result <- rbind(df_result, as.data.frame(quest_info))
  }
  return(df_result)
}

#' single quest results
quest_summary <- function(quest, df_player){
  result <- list()
  quest_times <- get_quest_timewindow(quest, include_teleport = FALSE) #can be null
  result$name <- quest$name
  result$quest_order_session <- quest$order_session
  result$time <- ifelse(length(quest_times) != 2, NA, diff(c(quest_times$start, quest_times$finish)))
  player_log <- get_quest_player_log(quest, df_player, include_teleport = FALSE)
  # TODO - simplyfy this
  if(length(quest_times) == 2){
    result$quest_pulse_start <- get_pulse_at_time(player_log, quest_times$start)
    result$quest_pulse_starttime <- get_pulse_timewindow(player_log, result$quest_pulse_start)$start
    result$quest_pulse_end <- tail(player_log$pulse_id, 1)
    result$quest_pulse_endtime <- tail(player_log$Time, 1)
  } else {
    result$quest_pulse_start <- NA
    result$quest_pulse_starttime <- NA
    result$quest_pulse_end <- NA
    result$quest_pulse_endtime <- NA
  }
  #calculating sky distance from start to goal
  start_stop <- get_quest_start_finish_positions(player_log, quest, include_teleport = FALSE)
  if(!is.null(start_stop)) result$sky_distance <- navr::euclid_distance(start_stop$start, start_stop$finish)
  result$walked_distance <- diff(range(player_log$cumulative_distance))
  result$finished <- was_quest_finished(quest)
  result$distance_to_last_step <- distance_to_last_step(quest, player_log)
  return(result)
}


# Helpers --------
distance_to_last_step <- function(quest, df_player){
  lastPosition <- get_last_player_position_quest(quest, df_player)
  questLastPosition <- get_last_quest_position(quest) #keeping only X and Z
  distance <- navr::euclid_distance(lastPosition, questLastPosition)
  return(distance)
}

#returns X Z position of the player at the end of the given quest
get_last_player_position_quest <- function(quest, df_player){
  t <- get_quest_finish_time(quest) - 0.5 #hack because fo how the player log is selected
  pos <- get_player_position_at_time(df_player, t)
  return(pos)
}
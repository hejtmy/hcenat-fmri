## General getters ------
get_pulse_at_time.session <- function(data, times){
  return(get_pulse_at_time(data$player_log, times))
}

#' Returns pulse ids of specified times 
#'
#' @param df_player 
#' @param times 
get_pulse_at_time <- function(df_player, times){
  if(!("pulse_id" %in% colnames(df_player))){
    warning("There are no synchronized pulses in the player log. Have you run add_pulses function?")
    return(NULL)
  }
  pulses <- c()
  for(time in times){
    pulses <- c(pulses, df_player[Time > time, .SD[1]$pulse_id])
  }
  return(pulses)
}

get_pulse_timewindow <- function(df_player, pulse_id) {
  start <- head(df_player$Time[!is.na(df_player$pulse_id) & df_player$pulse_id == pulse_id], 1)
  end <- tail(df_player$Time[!is.na(df_player$pulse_id) & df_player$pulse_id == pulse_id], 1)
  return(list(start = start, end = end))
}

#' Return pulse ids which correspond to given timewindows
#'
#' @param df_player 
#' @param timewindows 
get_pulses_in_timewindow <- function(df_player, timewindows){
  
}


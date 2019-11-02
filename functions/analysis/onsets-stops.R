onset_stop_table.session <- function(participant_session, speed_threshold, still_threshold, min_duration){
  nav <- as.navr(participant_session$player_log, participant_session$experiment_log)
  df_onsets <- onset_table.navr(nav, speed_threshold, min_duration)
  df_stops <- stop_table.navr(nav, still_threshold, min_duration)
  df_onsets$movement_type <- "moving"
  df_stops$movement_type <- "still"
  df_result <- rbind(df_onsets, df_stops) 
  return(df_result)
}

onset_table.navr <- function(obj, speed_threshold, min_duration){
  onsets <- navr::search_onsets(obj, speed_threshold, min_duration)
  onset_obj <- filter_events(obj, onsets$time_since_start, onsets$duration)
  return(onset_obj$data)
}

stop_table.navr <- function(obj, speed_threshold, min_duration){
  stops <- navr::search_stops(obj, speed_threshold, min_duration)
  stops_obj <- filter_events(obj, stops$time_since_start, stops$duration)
  return(stops_obj$data)
}

filter_events <- function(obj, event_times, durations){
  mat_events <- matrix(c(event_times, event_times+durations), ncol = 2)
  obj <- navr::filter_times(obj, mat_events, zero_based=TRUE)
  return(obj)
}

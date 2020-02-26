#' Title
#'
#' @param participants 
#' @param speed_threshold 
#' @param still_threshold 
#' @param min_duration 
#'
#' @return
#' @export
#'
#' @examples
onset_stop_table.participants <- function(participants, speed_threshold, still_threshold, min_duration){
  out <- data.frame()
  for(participant_name in names(participants)){
    message("calculating for ", participant_name)
    participant_results <- onset_stop_table.participant(participants[[participant_name]], speed_threshold, still_threshold, min_duration)
    if(nrow(participant_results) > 0){
      participant_results$participant <- participant_name
      out <- rbind(out, participant_results)
    } 
  }
  return(out)
}

#' Title
#'
#' @param participant_data 
#' @param speed_threshold 
#' @param still_threshold 
#' @param min_duration 
#'
#' @return
#' @export
#'
#' @examples
onset_stop_table.participant <- function(participant_data, speed_threshold, still_threshold, min_duration){
  out <- data.frame()
  for(i in 1:length(participant_data)){
    session_data <- participant_data[[i]]
    if(is.null(session_data)) next
    session_results <- onset_stop_table.session(session_data, speed_threshold, still_threshold, min_duration)
    if(nrow(session_results) > 0){
      session_results$session <- i
      out <- rbind(out, session_results)
    }
  }
  return(out)
}

#' Title
#'
#' @param participant_session 
#' @param speed_threshold 
#' @param still_threshold 
#' @param min_duration 
#'
#' @return
#' @export
#'
#' @examples
onset_stop_table.session <- function(participant_session, speed_threshold, still_threshold, min_duration){
  nav <- as.navr(participant_session$player_log, participant_session$experiment_log)
  nav <- remove_unreal_speeds(nav, 30, "value")
  onsets <- navr::search_onsets(nav, speed_threshold, min_duration, still_speed_threshold = still_threshold)
  stops <- navr::search_stops(nav, still_threshold, min_duration)
  
  df_onsets <- data.frame(time = onsets$time_since_start,
                       duration = onsets$duration,
                       movement_type = "moving")
  
  df_stops <- data.frame(time = stops$time_since_start,
                       duration = stops$duration,
                       movement_type = "still")
  out <- rbind(df_onsets, df_stops)
  #need to get it from the navr object
  first_pulse_time <- nav$data %>%
    filter(Input == "fMRISynchro") %>% pull(time_since_start) %>%
    .[1]
  out$fmri_time <- out$time - first_pulse_time
  return(out)
}
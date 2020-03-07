#' Runs onset stop table for each participant and then binds the results
#'
#' @description uses navr::search_onsets under the hood
#' 
#' @param participants 
#' @param speed_threshold what is the speed which count as a movement
#' @param still_threshold What is the speed which counts as being still. 
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

#' Runs onset_stop table for each participants session
#'
#' @param participant
#' @param speed_threshold 
#' @param still_threshold 
#' @param min_duration 
#'
#' @return
#' @export
#'
#' @examples
onset_stop_table.participant <- function(participant, speed_threshold, still_threshold, min_duration){
  out <- data.frame()
  for(i in 1:length(participant)){
    session_data <- participant[[i]]
    if(is.null(session_data)) next
    session_results <- onset_stop_table.session(session_data, speed_threshold, still_threshold, min_duration)
    if(nrow(session_results) > 0){
      session_results$session <- i
      out <- rbind(out, session_results)
    }
  }
  return(out)
}

#' Creates onsets and stops table for passed session data
#'
#' @param session session data
#' @param speed_threshold 
#' @param still_threshold 
#' @param min_duration 
#'
#' @return
#' @export
#'
#' @examples
onset_stop_table.session <- function(session, speed_threshold, still_threshold, min_duration){
  nav <- as.navr(session$player_log, session$experiment_log)
  nav <- navr::remove_unreal_speeds.navr(nav, 30, "value")
  onsets <- navr::search_onsets(nav, speed_threshold = speed_threshold, 
                                min_duration = min_duration,
                                still_speed_threshold = still_threshold)
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
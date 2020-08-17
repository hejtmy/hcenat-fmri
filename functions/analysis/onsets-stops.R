#' Runs onset stop table for each participant and then binds the results
#'
#' @description uses navr::search_onsets under the hood
#' 
#' @return
#'
#' @examples
onset_stop_table.participants <- function(participants, speed_threshold, still_threshold, 
                                          min_duration, still_duration, pause_duration){
  out <- data.frame()
  for(participant_name in names(participants)){
    message("calculating for ", participant_name)
    participant_results <- onset_stop_table.participant(participants[[participant_name]], 
                                                        speed_threshold = speed_threshold, 
                                                        still_threshold = still_threshold, 
                                                        min_duration = min_duration, 
                                                        still_duration = still_duration, 
                                                        pause_duration = pause_duration)
    if(nrow(participant_results) > 0){
      participant_results$participant <- participant_name
      out <- rbind(out, participant_results)
    } 
  }
  return(out)
}

#' Runs onset_stop table for each participants session
#'
#' @return
#' @examples
onset_stop_table.participant <- function(participant, speed_threshold, still_threshold, 
                                         min_duration, still_duration, pause_duration){
  out <- data.frame()
  for(i in 1:length(participant)){
    session_data <- participant[[i]]
    if(is.null(session_data)) next
    session_results <- onset_stop_table.session(session_data, 
                                                speed_threshold = speed_threshold, 
                                                still_threshold = still_threshold, 
                                                min_duration = min_duration, 
                                                still_duration = still_duration,
                                                pause_duration = pause_duration)
    if(nrow(session_results) > 0){
      session_results$session <- i
      out <- rbind(out, session_results)
    }
  }
  return(out)
}

#' Creates onsets and stops table for passed session data. Returnes fMRI times
#'
#' @param session session data
#' @param speed_threshold what is the speed which count as a movement
#' @param still_threshold What is the speed which counts as being still. 
#' @param min_duration 
#' @param still_duration time of required stillness before movement is 
#' considered as movement onset. Prevents sudden onsets
#' @param pause_duration 
#'
#' @return
#'
#' @examples
onset_stop_table.session <- function(session, speed_threshold, 
                                     still_threshold = speed_threshold,
                                     min_duration = 3, still_duration = 1,
                                     pause_duration = 0.5){
  nav <- as.navr(session$player_log, session$experiment_log)
  nav <- navr::remove_unreal_speeds(nav, cutoff=30, type="value")
  onsets <- navr::search_onsets(nav, speed_threshold = speed_threshold, 
                                min_duration = min_duration,
                                still_speed_threshold = still_threshold,
                                still_duration = still_duration,
                                pause_duration = pause_duration)
  stops <- navr::search_stops(nav, still_threshold, min_duration)
  
  df_onsets <- data.frame(time = onsets$time_since_start,
                       duration = onsets$duration,
                       movement_type = "moving")
  
  df_stops <- data.frame(time = stops$time_since_start,
                       duration = stops$duration,
                       movement_type = "still")
  out <- rbind(df_onsets, df_stops)
  first_pulse_time <- nav$data %>% 
    filter(pulse_id == 1) %>%
    pull(time_since_start) %>% .[1]
  out$fmri_time <- out$time - first_pulse_time
  return(out)
}
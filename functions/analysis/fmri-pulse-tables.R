# Desctiption -----------
#' All pulses tables have the following fields
#' participant, pulse, session, ....


#' Creates table of pointing results
#'
#' @param df_pointing table created by pointint_results.participants
#'
#' @return data.frame
create_pointing_pulses_table <- function(df_pointing, angle_correct = 20, pulse_percent = 0.9){
  df_pointing$angle_diff <- abs(navr::angle_to_180(df_pointing$correct_angle - df_pointing$chosen_angle))
  df_pointing$correct <- df_pointing$angle_diff < angle_correct
  result <- df_pointing %>% filter(!is.na(pulse_start) & !is.na(pulse_end)) %>%
    mutate(pulse_start_percent = 1-((point_start - pulse_start_starttime)/PULSE_LENGTH),
           pulse_end_percent = (point_end - pulse_end_starttime)/PULSE_LENGTH) %>%
    mutate(pulse_start = ifelse(pulse_start_percent < pulse_percent, pulse_start + 1, pulse_start), #starts pointing pulses later if 
           pulse_end = ifelse(pulse_end_percent < pulse_percent, pulse_end - 1, pulse_end)) %>% #ends pointing pulses earlier if not full 
    filter(pulse_end - pulse_start >= 0) #it is possible that because of previous step we might get -1 
  result <- result %>% 
    select(participant, pulse_start, pulse_end, session, correct) %>%
    spread_table()
  return(result)
}

create_movement_stop_pulses_table <- function(participants, speed_threshold, still_threshold,
                                              min_duration, pulse_percent = 0.9, silent=FALSE){
  df_results <- data.frame()
  for(participant_name in names(participants)){
    if(!silent) message("calculating for ", participant_name)
    for(i in 1:length(participants[[participant_name]])){
      data <- participants[[participant_name]][[i]]
      if(is.null(data)) next
      df_onset_stop <- create_movement_stop_pulses_table.session(data, speed_threshold, still_threshold, pulse_percent)
      df_onset_stop <- df_onset_stop %>%  mutate(session=i, participant = participant_name)
      df_results <- rbind(df_results, df_onset_stop)
    }
  }
  return(df_results)
}

create_movement_pulses_table.session <- function(data, speed_threshold, still_threshold, min_duration, pulse_percent) {
  df_onset_stop <- onset_stop_table.participant(data, speed_threshold, still_threshold, min_duration)
  df_onset_stop <- df_onset_stop %>% filter(!is.na(pulse_id)) %>%
    filter_full_pulses(pulse_percent) %>%  group_by(pulse_id) %>%
    mutate(rotation_x_sum = sum(abs(rotation_x_diff)),
           rotation_y_sum = sum(abs(rotation_y_diff)),
           rotation_sum = rotation_x_sum + rotation_y_sum) %>%
    ungroup()
  df_onset_stop <- df_onset_stop %>%
    select(pulse_id, movement_type, rotation_x_sum, rotation_y_sum, rotation_sum) %>%
    unique()
  return(df_onset_stop) 
}

# Helpers ---------

#' Filters out only those pulses which cover pulse percent portion of the event
#'
#' @param df 
#' @param pulse_percent 
#'
#' @return
#' @export
#'
#' @examples
filter_full_pulses <- function(df, pulse_percent) {
  df <- df %>% group_by(pulse_id) %>% 
    mutate(percent_of_pulse = diff(range(timestamp))/PULSE_LENGTH) %>% #pulse length is defined in constants 
    ungroup() %>% filter(pulse_percent < percent_of_pulse)
  return(df)
}

#' Used to spread the pulse_start and pulse_end to a list of pulses
#'
#' @param pulses_table 
#'
#' @return

spread_table <- function(pulses_table){
  df_spread <- data.frame()
  # POTENTIALLY DO DIFFERENTLY????
  for(i in 1:nrow(pulses_table)){
    line <- pulses_table[i, ]
    pulses <- line$pulse_start:line$pulse_end
    df_res <- line[rep(1, length(pulses)),]
    df_res$pulse_id <- pulses
    df_res <- df_res %>% select(-pulse_start, -pulse_end)
    df_spread <- rbind(df_spread, df_res)
  }
  return(df_spread)
}
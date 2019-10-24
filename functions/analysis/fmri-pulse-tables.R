# Desctiption -----------
#' All pulses tables have the following fields
#' participant, pulse, session, ....


#' Creates table of pointing results
#'
#' @param df_pointing table created by pointint_results.participants
#'
#' @return data.frame
create_pointing_pulses_table <- function(df_pointing, angle_correct = 20){
  df_pointing$angle_diff <- abs(navr::angle_to_180(df_pointing$correct_angle - df_pointing$chosen_angle))
  df_pointing$correct <- df_pointing$angle_diff < angle_correct
  result <- df_pointing %>% filter(!is.na(pulse_start) & !is.na(pulse_end)) %>% select(participant, pulse_start, pulse_end, session, correct)
  result <- spread_table(result)
  return(result)
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
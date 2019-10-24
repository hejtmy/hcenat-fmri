library(dplyr)

pointing_results.participants <- function(participants, silent = FALSE){
  df_results <- data.frame()
  for(participant_name in names(participants)){
    if(!silent) message("calculating for ", participant_name)
    for(i in 1:length(participants[[participant_name]])){
      data <- participants[[participant_name]][[i]]
      if(is.null(data)) next
      df_session_pointing <- pointing_results.participant(data)
      df_session_pointing$session <- i
      df_session_pointing$participant <- participant_name
      df_results <- rbind(df_results, df_session_pointing)
    }
  }
  return(df_results)
}

pointing_results.participant <- function(data){
  result <- pointing_results(data$quests_logs, data$player_log)
  return(result)
}

#' Creates pointing results data frame for a single participant data
#'
#' @param quests_logs quest logs loaded by the read_unity_data function
#' @param df_player player log loaded by the read_unity_data funtcion
#'
#' @return
pointing_results <- function(quests_logs, df_player){
  df_quests <- df_quests_info(quests_logs)
  df_results <- data.frame()
  # FOR EACH QUEST
  for(quest_order_session in df_quests$order_session){
    quest <- get_quest(quests_logs, quest_order_session)
    pointing_times <- get_step_timespans(quest, "Point in Direction")
    if (is.null(pointing_times)) next #skipping trials without pointing
    if (nrow(pointing_times) > 1){
      warning("Too many points in pointing")
      next
    }
    quest_pointing <- quest_pointing_accuracy(quest, df_player) #possble to get NAS in the data frame
    # Adding the fnru pulses
    quest_pointing$pulse_start <- get_pulse_time(df_player, quest_pointing$point_start)
    quest_pointing$pulse_end <- get_pulse_time(df_player, quest_pointing$point_end)
    
    quest_pointing <- as.data.frame(quest_pointing) %>% mutate(quest_order_session = quest_order_session)
    df_results <- rbindlist(list(df_results, quest_pointing), fill = TRUE)
  }
  return_dt <- merge(df_results, df_quests, by.x = "quest_order_session", by.y = "order_session")
  return(return_dt)
}

#' Returns small data frame 
#' Based on the quest it searches for correct place in the player log and calculates pointing direction from the player
#' position at that time adn the position of the goal of the quest as suggested from the last known transform
#' 
#' @param quest as returend by get_quest
#' @return data.frame 
quest_pointing_accuracy <- function(quest, df_player){
  ALLOWED_DIFFERENCE <- 0.1
  pointing_times <- get_step_timespans(quest, "Point in Direction")
  n_pointing <- nrow(pointing_times)
  quest_start_finish <- get_quest_start_finish_positions(df_player, quest, include_teleport = FALSE)
  choosing_times <- get_event_times(df_player, "ChooseDirection")
  dt_time <- pointing_times[1, ]
  #' This should be more accurate than StepFinished - selects ChooseDirection event
  #' from the player log rather than from the quest log
  player_point_time <- choosing_times %>%
    filter(Time > dt_time$StepActivated) %>%
    filter((Time - dt_time$StepFinished) < ALLOWED_DIFFERENCE) %>%
    select(Time) %>% first
  if(length(player_point_time) != 1) next
  pointing_moment <- df_player[Time > player_point_time, .SD[1]]
  player_pos <- pointing_moment[, c(Position.x, Position.z)]
  correct_angle <- get_correct_angle(quest, df_player)
  point_start <- dt_time$StepActivated
  point_end <- player_point_time
  chosen_angle <- pointing_moment$Rotation.X
  result <- list(correct_angle = correct_angle, 
               chosen_angle = chosen_angle, point_start = point_start, 
               point_end = point_end)
  return(result)
}

get_correct_angle <- function(quest, df_player){
  if(!exists("CORRECT_ANGLES")){
    stop("You need to load the CORRECT_ANGLES first from the data folder") 
  }
  quest_start_finish <- get_quest_start_finish_positions(df_player, quest, include_teleport = FALSE)
  if(quest$name %in% CORRECT_ANGLES$name){
    correct_angle <- CORRECT_ANGLES$target_angle[CORRECT_ANGLES$name == quest$name]
  } else {
    correct_angle <- angle_from_positions(quest_start_finish$start, quest_start_finish$finish)
  }
  return(correct_angle)
}

#' Needs to be in order FROM -> TO, otherwise can provide weird values
angle_from_positions <- function(pos_from, pos_to){
  ZERO_VECTOR <- c(0, 1)
  target_vector <- pos_to - pos_from
  theta <- atan2(target_vector[1], target_vector[2])
  angle <- radian_to_angle(theta)
  return(angle)
}

radian_to_angle <- function(radian){
  angle <- radian/pi * 180
  if(angle < 0) angle <- 360 + angle
  return(angle)
}
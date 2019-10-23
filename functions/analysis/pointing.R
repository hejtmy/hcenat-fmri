library(dplyr)
#' Creates pointing results data frame for a single participant data
#'
#' @param df_quests dataframe as created by the df_quests_info function
#' @param quests_logs quest logs loaded by the read_unity_data function
#' @param df_player player log loaded by the read_unity_data funtcion
#' @param correct_angles dataframe with angles loaded from the file to fill for the B tasks
#'
#' @return
pointing_results <- function(df_quests, quests_logs, df_player, correct_angles = NULL){
  if(is.null(df_quests)) return(NULL)
  target_angle <- numeric(nrow(df_quests))
  chosen_angle <- numeric(nrow(df_quests))
  quest_end_angle <- numeric(nrow(df_quests))
  decision_time <- numeric(nrow(df_quests))
  
  df_results <- data.frame()
  choosing_times <- get_event_times(df_player, "ChooseDirection")
  if(is.null(choosing_times)){
    warning("No choose direction events were found")
    return(NULL)
  }
  # FOR EACH QUEST
  for(quest_order_session in df_quests$order_session){
    quest <- get_quest(quests_logs, quest_order_session)
    pointing_times <- get_step_timespans(quest, "Point in Direction")
    if (is.null(pointing_times)) next #skipping trials without pointing
    if (nrow(pointing_times) > 2){
      warning("Too many points in pointing")
      next
    }
    correct_angle <- NULL
    if (!is.null(correct_angles)){
      correct_angle <- correct_angles %>% 
        filter(name == quest$name) %>% 
        select(target_angle)
      correct_angle <- if(nrow(correct_angle) == 1){correct_angle$target_angle} else { NULL }
    }
    quest_pointing <- quest_pointing_accuracy(df_player, quest, choosing_times, correct_angle) #possble to get NAS in the data frame
    quest_pointing <- quest_pointing %>% mutate(quest_order_session = quest_order_session)
    df_results <- rbindlist(list(df_results, quest_pointing), fill = TRUE)
  }
  return_dt <- merge(df_results, df_quests, by.x = "quest_order_session", by.y = "order_session")
  return(return_dt)
}

#' Returns small data frame 
#' Based on the quest it searches for correct place in the player log and calculates pointing direction from the player
#' position at that time adn the position of the goal of the quest as suggested from the last known transform
#' 
#' @param choosing_times - evet times of ChooseDirections in Unity log - data.frame
#' @param quest as returend by get_quest
#' @return data.frame 
quest_pointing_accuracy <- function(df_player, quest, choosing_times, correct_angle = NULL){
  ALLOWED_DIFFERENCE <- 0.1
  pointing_times <- get_step_timespans(quest, "Point in Direction")
  n_pointing <- nrow(pointing_times)
  df <- data.frame(pointing_order = as.numeric(rep(NA, n_pointing)), 
                  target_angle = as.numeric(rep(NA, n_pointing)), 
                  chosen_angle = as.numeric(rep(NA, n_pointing)),
                  quest_end_angle = as.numeric(rep(NA, n_pointing)),
                  point_start = as.numeric(rep(NA, n_pointing)),
                  point_end = as.numeric(rep(NA, n_pointing)))
  quest_start_finish <- get_quest_start_finish_positions(df_player, quest, include_teleport = FALSE)
  
  #' splitting to the first and second part
  #' First shoudl be occuring on the start and second on the end
  for (i in 1:n_pointing){
    dt_time <- pointing_times[i, ]
    #' This should be more accurate than StepFinished - selects ChooseDirection event
    #' from the player log rather than from the quest log
    player_point_time <- choosing_times %>%
      filter(Time > dt_time$StepActivated) %>%
      filter((Time - dt_time$StepFinished) < ALLOWED_DIFFERENCE) %>%
      select(Time) %>% first
    if(length(player_point_time) != 1) next
    pointing_moment <- df_player[Time > player_point_time, .SD[1]]
    player_pos <- pointing_moment[, c(Position.x, Position.z)]
    
    if(is.null(correct_angle)){
      if(i == 1){ target_pos <- quest_start_finish$finish } else { target_pos <- quest_start_finish$start }
      target_angle <- angle_from_positions(player_pos, target_pos)
    } else {
      target_angle <- correct_angle
    }
    point_start <- dt_time$StepActivated
    point_end <- player_point_time
    quest_end_angle <- df_player[Time > point_start, .SD[1, c(Rotation.X)]]
    chosen_angle <- pointing_moment$Rotation.X
    df[i, ] <- c(i, target_angle, chosen_angle, quest_end_angle, point_start, point_end)
  }
  return(df)
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
#' Title
#'
#' @param df_quests dataframe as created by the df_quests_info function
#' @param df_player 
#'
#' @return
#' @export
#'
#' @examples
quests_summary <- function(df_quests, quests_logs, df_player){
  df_result <- data.frame()
  for(i in 1:nrow(df_quests)){
    quest <- get_quest(df_quests, quests_logs, i)
    quest_info <- quest_summary(quest, df_player)
    df_result <- rbind(df_result, as.data.frame(quest_info))
  }
  return(df_result)
}
#' shorthand for the loaded data
quests_summary_participant <- function(data, correct_angles = NULL){
  df_quests <- df_quests_info(data$quests_logs)
  pointing <- pointing_results(df_quests, data$quests_logs, data$player_log, correct_angles)
  result <- quests_summary(df_quests, data$quests_logs, data$player_log)
  if(!is.null(pointing)) result <- merge(pointing, result, by=c("name", "quest_order_session"))
  return(result)
}

quest_summary <- function(quest, df_player){
  result <- list()
  quest_times <- get_quest_timewindow(quest, include_teleport = F) #can be null
  result$name <- quest$name
  result$quest_order_session <- quest$order_session
  result$time <- ifelse(is.null(quest_times), NA, diff(c(quest_times$start,quest_times$finish)))
  player_log <- get_quest_player_log(quest, df_player, include_teleport = FALSE)
  #calculating sky distance from start to goal
  start_stop <- get_quest_start_finish_positions(player_log, quest, include_teleport = FALSE)
  if(!is.null(start_stop)) result$sky_distance <- navr::euclid_distance(start_stop$start, start_stop$finish)
  result$walked_distance <- diff(range(player_log$cumulative_distance))
  result$finished <- was_quest_finished(quest)
  result$distance_to_last_step <- distance_to_last_step(quest, player_log)
  #result$n_deliberation_stops <- nrow(get_deliberation_stops(player_log))
  return(result)
}

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

get_deliberation_stops <- function(df_player, deliberation_time = 3, tolerance = 0, remove_start = T){
  # we gonna assume that the log is quite orderly and that it recorded every n-ms
  pl <- copy(df_player)
  pl[, time_diff := c(0, diff(Time))]
  pl[, dist_id:= rleid(distance)] #creates an id for rows with consecutive values
  pl <- pl[distance <= tolerance] # removing non-0 parts
  pl[, time_delib := sum(time_diff), by = dist_id]
  if(remove_start) pl <- pl[dist_id > 2]
  pl <- pl[time_delib > deliberation_time, .SD[1], by = dist_id]
  pl[, c('dist_id', 'time_diff') := NULL]
  return(pl)
}
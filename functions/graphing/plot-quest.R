MAP_LIMITS <- list(x=c(-1378,1622), y=c(-1367,1133))
PLOT_LIMITS <- list(x=c(-1000,1000), y=c(-800,500))

plot_quest_path.session <- function(data, quest_id, img_path){
  quest <- get_quest(data$quests_logs, quest_id)
  return(plot_quest_path(quest, data$player_log, data$experiment_log, img_path))
}

#' Draws by default learnd and return path of a quest
#' 
#' @param quest_set provided by the UnityAnalysis
#' @param trial_sets data saved in UnityAnalysisClass
#' @param quest_id ID of the quest - not session id, but the order of a quest
#' @param img_path path to the image that will be overwrote
#' @return graph of the learned and trial path
plot_quest_path <- function(quest, df_player, experiment_log, img_path){
  obj <- prepare_quest_path(quest, df_player, experiment_log)
  plt <- ggplot() + theme_void() + 
    geom_navr_backround(img_path, obj$area_boundaries$x, obj$area_boundaries$y) + 
    geom_navr_path(obj, size = 1, color="blue")
  start_finish <- get_quest_start_finish_positions(df_player, quest)
  
  pointed_angle <- obj$data %>% filter(Input == "ChooseDirection") %>% .$Rotation.X
  # add the potential correct angle for B tasks
  correct_angle <- get_correct_angle(quest, df_player)
  plt <- plt + navr::geom_navr_points(start_finish)
  plt <- plt + xlim(PLOT_LIMITS$x) + ylim(PLOT_LIMITS$y)
  plt <- plt + navr::geom_navr_direction(start_finish$start, correct_angle, color="green", length = 100, size=1.25)
  plt <- plt + navr::geom_navr_direction(start_finish$start, pointed_angle, color="blue", length = 100, size=1.25)
  return(plt)
}

prepare_quest_path <- function(quest, df_player, experiment_log){
  df_player <- get_quest_player_log(quest, df_player, include_teleport = FALSE)
  obj <- as.navr(df_player, experiment_log)
  return(obj)
}
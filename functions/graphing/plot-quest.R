MAP_LIMITS <- list(x=c(-1378,1622), y=c(-1367,1133))
PLOT_LIMITS <- list(x=c(-1000,1000), y=c(-800,500))

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
    geom_navr_path(obj, size=1, color="blue")
  start_finish <- get_quest_start_finish_positions(df_player, quest)
  plt <- plt + navr::geom_navr_points(start_finish)
  plt <- plt + xlim(PLOT_LIMITS$x) + ylim(PLOT_LIMITS$y)
  #plt <- draw_pointing_participant(plt, quest_set, trial_sets, quest_id)
  return(plt)
}

prepare_quest_path <- function(quest, df_player, experiment_log){
  obj <- NavrObject()
  obj$data <- get_quest_player_log(quest, df_player, include_teleport = FALSE)
  obj$data <- dplyr::rename(obj$data, "position_x" = "Position.x", 
                            "position_y"="Position.z", 
                            "timestamp" = "Time")
  obj$area_boundaries <- get_map_size(experiment_log)
  return(obj)
}

# returns information about quest so that it can be drawn
# returns start and stop times, positions and player log for the duration
quest_path_data <- function(quest, df_player){
  result <- list()
  result[["player_log"]] <- 
  return(result)
}

#' Draws by default learnd and return path of a quest
#' 
#' @param quest_set provided by the UnityAnalysis
#' @param trial_sets data saved in UnityAnalysisClass
#' @param quest_id ID of the quest - not session id, but the order of a quest
#' @param img_path path to the image that will be overwrote
#' @return graph of the learned and trial path
draw_pointing_participant = function(plt, quest_set, trial_sets, quest_id){
  
  #this is only for buffering purposes - could be done int he add_pointing function, but would be more intensive
  choosings = get_event_times(trial_sets, "ChooseDirection")
  
  #this is TODO - make it clearer - getting too much of quest data in each function
  quest = get_quest(quest_set, trial_sets, quest_id, quest_types = "trial")
  start_stop = get_quest_start_finish_positions(quest_set, trial_sets, quest, include_teleport = F)
  
  pointing_df = prepare_pointing_quest(quest_set, trial_sets, quest, choosings)
  plt = add_pointing_arrows(plt, pointing = pointing_df, start_stop = start_stop)
  
  return(plt)
}
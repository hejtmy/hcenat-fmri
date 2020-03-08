MAP_LIMITS <- list(x=c(-1378,1622), y=c(-1367,1133))
PLOT_LIMITS <- list(x=c(-1000,1000), y=c(-800,500))

#' Plots quest path for given session data
#'
#' @param session session data
#' @param i_quest 
#' @param img_path 
#'
#' @return
#' @export
#'
#' @examples
plot_quest_path.session <- function(session, i_quest, img_path = NULL){
  quest <- get_quest(session$quests_logs, i_quest)
  return(plot_quest_path(quest, session$player_log, session$experiment_log, img_path))
}

#' Draws by default learnd and return path of a quest
#' 
#' @param quest_set provided by the UnityAnalysis
#' @param trial_sets data saved in UnityAnalysisClass
#' @param quest_id ID of the quest - not session id, but the order of a quest
#' @param img_path path to the image that will be overwrote
#' @return graph of the learned and trial path
plot_quest_path <- function(quest, df_player, experiment_log, img_path = NULL){
  obj <- prepare_quest_path(quest, df_player, experiment_log)
  if(is.null(obj)) return(NULL)
  plt <- ggplot() + theme_void()
  if(!is.null(img_path)) plt <- plt + geom_navr_background(img_path, obj$area_boundaries$x, obj$area_boundaries$y)
  plt <- plt + geom_navr_path(obj, size = 1, color="blue")
  
  start_finish <- get_quest_start_finish_positions(df_player, quest)
  pointed_angle <- obj$data %>% filter(Input == "ChooseDirection") %>% pull(rotation_x)
  
  # add the potential correct angle for B tasks
  correct_angle <- get_correct_angle(quest, df_player)
  plt <- plt + navr::geom_navr_points(start_finish)
  plt <- plt + xlim(PLOT_LIMITS$x) + ylim(PLOT_LIMITS$y)
  plt <- plt + navr::geom_navr_direction(start_finish$start, correct_angle, color="green", length = 100, size=1.25)
  plt <- plt + navr::geom_navr_direction(start_finish$start, pointed_angle, color="blue", length = 100, size=1.25)
  title_text <- paste0(quest$header$Patient, " trial: ", quest$name)
  plt <- plt + labs(title = title_text)
  return(plt)
}

# Prepares path for a given quest as a navr object
prepare_quest_path <- function(quest, df_player, experiment_log){
  df_player <- get_quest_player_log(quest, df_player, include_teleport = FALSE)
  if(nrow(df_player) < 10){
    warning("the quest ", quest$name, " for ", quest$header$Patient, " data is missing")
    return(NULL)
  }
  obj <- as.navr(df_player, experiment_log)
  return(obj)
}
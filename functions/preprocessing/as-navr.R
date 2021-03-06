#' Converts player log to a navr object
#'
#' @param df_player player log table
#'
#' @return
#' @export
#'
#' @examples
as.navr <- function(df_player, experiment_log){
  df_player <- dplyr::rename(df_player, 
                            "position_x" = "Position.x", 
                            "position_y"="Position.z", 
                            "timestamp" = "Time",
                            "rotation_x" = "Rotation.X",
                            "rotation_y" = "Rotation.Y")
  obj <- NavrObject()
  obj$data <- df_player
  obj$area_boundaries <- get_map_size(experiment_log)
  obj <- prepare_navr(obj)
  obj$data$speed[obj$data$Input == "Pause"] <- NA_real_ #should fix the issue with onset and stop search
  return(obj)
}

as.navr.session <- function(session){
  return(as.navr(session$player_log, session$experiment_log))
}

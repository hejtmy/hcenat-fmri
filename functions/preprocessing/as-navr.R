#' Converts player log to a navr object
#'
#' @param df_player player log table
#'
#' @return
#' @export
#'
#' @examples
as.navr <- function(df_player, experiment_log){
  df_player <- dplyr::rename(df_player, "position_x" = "Position.x", 
                            "position_y"="Position.z", 
                            "timestamp" = "Time")
  obj <- NavrObject()
  obj$data <- df_player
  obj$area_boundaries <- get_map_size(experiment_log)
  return(obj)
}
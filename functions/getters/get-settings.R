get_map_size <- function(experiment_log){
  result <- list()
  terrain_info <- experiment_log$terrain
  size <- text_to_vector3(terrain_info$Size)
  pivot <- text_to_vector3(terrain_info$Pivot)
  result[["x"]] <- c(pivot[1],pivot[1] + size[1])
  result[["y"]] <- c(pivot[3],pivot[3] + size[3])
  return(result)
}
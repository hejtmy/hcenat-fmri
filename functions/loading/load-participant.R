load_participant <- function(data_dir, id, sessions = c(1,2)){
  response <- list()
  for(session in sessions){
    folder <- file.path(data_dir, id, "MRI", paste0("Session",session))
    if(!dir.exists(folder)){
      warning("directory ", folder, " doesn't exist")
      next
    }
    unity <- read_unity_data(folder)
    response[[session]] <- unity
  }
  return(response)
}
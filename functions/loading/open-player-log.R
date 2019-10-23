open_player_log <- function(experiment_log, override = F){
  directory <- dirname(experiment_log$filename)
  ptr <- paste(experiment_log$header$Patient, "_player_", experiment_log$header$Time, sep="", collapse="")
  logs <- list.files(directory, pattern = ptr, full.names = T)
  log_columns_types <- c(Time="numeric", Position="string", Rotation.X="numeric",
                         Rotation.Y="numeric", Focus = "character", FPS = "numeric", 
                         Input="character")
  preprocessed_log_column_types = c(log_columns_types, Position.x = "numeric", 
                                    Position.y = "numeric", Position.z = "numeric",
                                    distance = "numeric", cumulative_distance="numeric")
  if(length(logs) < 1){
    warning("!!!Could not find the file for player log with pattern", ptr)
    return(NULL)
  }
  if (length(logs) > 1){
    #check if there is a preprocessed player file
    preprocessed_index <- grep("*_preprocessed",logs)
    if(length(preprocessed_index) > 0){
      if(override){
        log <- logs[1]
        file.remove(logs[preprocessed_index])
      } else {
        log <- logs[preprocessed_index]
        return(fread(log, header=T, sep=";",dec=".", stringsAsFactors = F, colClasses = preprocessed_log_column_types))
      }
    } else{
      warning("There is more player logs with appropriate timestamp in the same folder. Have you named and stored everything appropriately?")
      return(NULL)
    }
  } else {
    log <- logs[1]
  }
  text <- readLines(log,warn=F)
  idxTop <- which(grepl('\\*\\*\\*\\*\\*',text))
  idxBottom <- which(grepl('\\-\\-\\-\\-\\-',text))
  pos_tab <- fread(log, header=T, sep=";", dec=".", skip=idxBottom, stringsAsFactors=F, colClasses = log_columns_types)
  pos_tab[, ncol(pos_tab) := NULL]
  pos_tab <- preprocess_player_log(pos_tab)
  return(pos_tab)
}
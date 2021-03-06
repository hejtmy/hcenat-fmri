#' Loads multiple participant from a data folder.
#'
#' @param data_dir path tot he desired folder
#' @param ids list of participant IDS- correspodn to folder names int he passed data_dir. If empty, all are loaded
#' @param df_preprocessing preprocessing table loaded from google sheets with mri codes and preprocessing status
#' @param sessions which session to load. possible sessions are 1 and 2
#'
#' @return named list with all loaded particiapnts
#'
#' @examples
load_participants <- function(data_dir, ids=c(), df_preprocessing = NULL, sessions = c(1,2)){
  if(is.null(df_preprocessing)) df_preprocessing <- load_participant_preprocessing_status()
  participants <- list()
  if(length(ids) != 0) df_preprocessing <- df_preprocessing %>% filter(ID %in% ids)
  for(i in 1:nrow(df_preprocessing)){
    line <- df_preprocessing[i, ]
    participant_data <- list()
    message("Loading participant ", line$ID)
    if(line$session1_ok & (1 %in% sessions)){
      data <- load_participant(data_dir, line$ID, 1)
      participant_data[[1]] <- data[[1]]
    }
    if(line$session2_ok & (2 %in% sessions)){
      data <- load_participant(data_dir, line$ID, 2)
      participant_data[[2]] <- data[[2]]
    }
    if(length(participant_data) == 0) next
    participants[[line$ID]] <- participant_data
  }
  return(participants)
}

#' Loads participant data from given directory when given ID and a MRI session
#'
#' @param data_dir directory with all participants data
#' @param id participant data to be loaded
#' @param sessions which sesion to load for the participant. e.g 1 or 2 or 1,2
load_participant <- function(data_dir, id, sessions = c(1,2)){
  response <- list()
  for(session in sessions){
    folder <- file.path(data_dir, id, "MRI", paste0("Session", session))
    if(!dir.exists(folder)){
      warning("directory ", folder, " doesn't exist")
      next
    }
    unity <- read_unity_data(folder)
    response[[session]] <- unity
  }
  return(response)
}

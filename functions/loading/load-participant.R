#' Title
#'
#' @param data_dir 
#' @param ids 
#'
#' @return
#' @export
#'
#' @examples
load_participants <- function(data_dir, ids=c(), df_preprocessing = NULL){
  if(is.null(df_preprocessing)) df_preprocessing <- load_participant_preprocessing_status()
  participants <- list()
  if(length(ids) != 0) df_preprocessing <- df_preprocessing %>% filter(ID %in% ids)
  for(i in 1:nrow(df_preprocessing)){
    line <- df_preprocessing[i,]
    participant_data <- list()
    if(line$session1_ok){
      data <- load_participant(data_dir, participant, 1)
      participant_data[[1]] <- data[[1]]
    }
    if(line$session2_ok){
      data <- load_participant(data_dir, participant, 2)
      participant_data[[2]] <- data[[1]]
    }
    participants[[line$ID]] <- participant_data
  }
  return(participants)
}


#' Loads participant data from given directory when given ID and a MRI session
#'
#' @param data_dir 
#' @param id 
#' @param sessions 
#'
#' @return
#' @export
#'
#' @examples
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
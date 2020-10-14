#' renames columns in components to match unity code
#'
#' @param components components loaded with load_mri function
#' @param df_participants table hcenat-fmri-preprocessing loaded
rename_mri_participants <- function(components, df_participants){
  ## Because of how the data is loaded, it is always loaded in the same order
  df <- data.frame(fmri_code = colnames(components[[1]]), stringsAsFactors = FALSE)
  df <- df %>%
    left_join(df_participants[, c("ID", "fmri_code")],
              by = c("fmri_code"))
  new_names <- df$ID
  for(name in names(components)){
    colnames(components[[name]]) <- new_names
  }
  return(components)
}


#' Returns fmri code for a particular participant
#'
#' @param codes Unity codes to change to fmri
#' @param df_preprocessing data.frame loaded with load_preprocessing_status
#'
#' @examples fmri_code("HCE_E_10", df_preprocessing)
fmri_code <- function(codes, df_preprocessing){
  ids <- sapply(codes, function(x){which(df_preprocessing$ID == x)}, 
                USE.NAMES = FALSE)
  if(!is.numeric(ids)){
    warning("bad code passed")
    return(NULL)
  }
  return(df_preprocessing$fmri_code[ids])
}


unity_code <- function(codes, df_preprocessing){
  ids <- sapply(codes, function(x){which(df_preprocessing$fmri_code == x)}, 
                USE.NAMES = FALSE)
  if(!is.numeric(ids)){
    warning("bad code passed")
    return(NULL)
  }
  return(df_preprocessing$ID[ids])
}

#' Changes the fmri data so that each participant has a single data frame with all components as columns
#'
#' @param components 
#'
#' @return
#' @export
#'
#' @examples
restructure_mri <- function(components){
  participants_codes <- colnames(components[[1]])
  df_fmri <- data.frame()
  for(participant_code in participants_codes){
    participant_results <- data.frame(pulse_id = 1:400)
    for(component_name in names(components)){
      participant_results[[component_name]] <- components[[component_name]][[participant_code]]
    }
    participant_results$participant <- participant_code
    df_fmri <- rbind(df_fmri, participant_results)
  }
  return(df_fmri)
}


#' Adds fmri_code column to given table based on data in the recoding table
#'
#' @param df table to which the fmri_column should be added
#' @param participant_column name of the column with participant id 
#' @param recoding_table needs to have columns "ID" and "fmri_code". 
#' Loaded from the google sheets with load_participant_preprocessing_status()
#'
#' @return
#' @export
#'
#' @examples
add_fmri_code <- function(df, participant_column, recoding_table){
  out <- recoding_table %>% 
    select(ID, fmri_code) %>%
    right_join(df, by = c("ID"="participant"))
  return(out)
}


#' Returns Ids of participants who finished session i
#'
#' @param df_preprocessing df_preprocessing table as loaded by load_preprocessing_table
#' @param return_code can be c("fmri", "unity"). Reutnrs appropriate code
#'
#' @return
#' @export
#'
#' @examples
get_good_participant_ids <- function(df_preprocessing, return_code = "fmri"){
  i_good_participants <- df_preprocessing$session1_ok
  if(return_code == "fmri"){
    return(df_preprocessing$fmri_code[i_good_participants])
  }
  if(return_code == "unity"){
    return(df_preprocessing$ID[i_good_participants])
  }
}

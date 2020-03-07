#' renames columns in components to match unity code
#'
#' @param components components loaded with load_mri function
#' @param df_participants table hcenat-fmri-preprocessing loaded
rename_mri_participants <- function(components, df_participants){
  ## Because of how the data is loaded, it is always loaded in the same order
  df <- data.frame(fmri_code = colnames(components[[1]]), stringsAsFactors = FALSE)
  df <- df %>% left_join(df_participants[, c("ID", "fmri_code")], by=c("fmri_code"))
  new_names <- df$ID
  for(name in names(components)){
    colnames(components[[name]]) <- new_names
  }
  return(components)
}


#' Flips fmri data so that each participant has a single data frame with all components as columns
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
#' @param recoding_table needs to have columns "ID" and "fmri_code". Loaded from the google sheets with load_participant_preprocessing_status()
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

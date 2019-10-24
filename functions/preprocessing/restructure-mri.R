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

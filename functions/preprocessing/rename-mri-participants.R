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

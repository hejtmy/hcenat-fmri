#' Selects from the fmri object based on selection table
#'
#' @param fmri fmri data.frame
#' @param df_select selection table as created by some fmri pulse table function
#'
#' @return
get_fmri <- function(fmri, df_select){
  df_results <- df_select %>% left_join(fmri, by=c("pulse_id", "participant")) %>% filter(complete.cases(.))
  return(df_results)
}
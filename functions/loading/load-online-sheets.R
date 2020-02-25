library(dplyr)

load_participant_preprocessing_status <- function(){
  results <- googlesheets4::read_sheet(GS_SHEET_PREPROCESSING)
  results <- results %>% mutate_at(vars(ends_with("present"), ends_with("ok")), ~(.==1))
  return(results)
}

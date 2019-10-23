library(googlesheets)
library(dplyr)

load_participant_preprocessing_status <- function(){
  results <- gs_key('1i_pmfCHHg4wSTVLJyyFWoXUvguxiMpLIyJnMd-gRqok') %>% gs_read()
  results <- results %>% mutate_at(vars(ends_with("present"), ends_with("ok")), ~(.==1))
  return(results)
}
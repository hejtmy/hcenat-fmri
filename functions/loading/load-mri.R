#' Loads component files from folder and names columns as per names file
#'
#' @param folder 
#' @param names_file 
#'
#' @return
#' @export
#'
#' @examples
load_mri <- function(folder, names_file){
  ptr <- "\'HCE_([CP0-9]+)_.*'"
  participant_codes <- readLines(names_file)
  participant_codes <- gsub(ptr, replacement = "\\1", participant_codes)
  
  component_files <- list.files(folder, full.names = TRUE)
  ptr <- "(^.*?_.*?_.*?)_.*\\.csv"
  components <- list()
  for(f in component_files){
    component_name <- gsub(ptr, replacement = "\\1", basename(f))
    df <- read.table(f, header=F, sep=",")
    colnames(df) <- participant_codes
    components[[component_name]] <- df
  }
  return(components)
}
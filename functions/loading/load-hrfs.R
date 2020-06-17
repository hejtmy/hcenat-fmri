#' Title
#'
#' @param base_dir 
#' @param hrf_names 
#' @param fmri_codes 
#'
#' @return
#' @export
#'
#' @examples
load_hrfs <- function(base_dir, hrf_names, fmri_codes){
  hrf_folder <- file.path(base_dir, "hrf")
  
  hrfs <- list()
  for(code in fmri_codes){
    f <- file.path(base_dir, "speeds", paste0(code, "_speed.txt"))
    #' Speeds have blank lines where there was too many missing values
    hrfs[[code]]$speed <- scan(f, what = numeric(), n = 400, sep = "\n", 
                               fill = NA_real_, blank.lines.skip = FALSE,
                               quiet = TRUE)
    f <- file.path(base_dir, "rotations", paste0(code, "_rotation.txt"))
    rotation <- read.table(f, sep=",", header = TRUE)
    hrfs[[code]]$rotation_x <- rotation$x
    hrfs[[code]]$rotation_total <- rotation$total
    for(hrf in hrf_names){
      f <- file.path(hrf_folder, paste0(code, "_", hrf, ".txt"))
      hrfs[[code]][[hrf]]<- scan(f, n = 400, sep="\n", quiet = TRUE)
      if(length(hrfs[[code]][[hrf]]) != 400){
        warning(code, " ", hrf, " has length ", length(hrfs[[hrf]][[code]]))
      }
    }
  }
  return(hrfs)
}

rename_hrfs <- function(hrfs, df_preprocessing, to="unity"){
  
}
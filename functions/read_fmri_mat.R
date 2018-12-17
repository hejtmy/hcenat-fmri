read_fmri_mat <- function(path){
  if(!require(R.matlab)){
    warning('Needs R.matlab package to load the data')
    return(NULL)
  }
  return <- R.matlab::readMat(path)
}
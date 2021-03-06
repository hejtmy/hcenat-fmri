contrast_output <- function(model, contrast){
  out <- multcomp::glht(model, linfct=contrast)
  out <- as.data.frame(summary(out)$test[c('coefficients', 'tstat', 'pvalues')])
  out$contrast <- rownames(contrast)
  return(out)
}

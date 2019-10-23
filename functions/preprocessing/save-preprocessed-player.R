save_preprocessed_player <- function(experiment_log, df_player){
  directory <- dirname(experiment_log$filename)
  ptr <- paste("_player_", experiment_log$header$Time, sep="", collapse="")
  log <- list.files(directory, pattern = ptr, full.names = T)[1]
  #writes preprocessed file
  preprocessed_filename <- gsub(".txt","_preprocessed.txt",log)
  write.table(df_player, preprocessed_filename, sep=";", dec=".", quote = F, row.names = F)
}
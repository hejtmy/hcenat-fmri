open_experiment_logs = function(directory = ""){
  ls <- list()
  #needs to check if we got only one file out
  logs <- list.files(directory, pattern = "_experiment_", full.names = T)
  if(length(logs) < 1){
    print("!!!Could not find the file for experiment log!!!")
    return(NULL)
  }
  for(i in 1:length(logs)){
    ls[[i]] <- open_experiment_log(logs[i])
    ls[[i]]$filename <- logs[i]
  }
  return(ls)
}
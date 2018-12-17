open_experiment_log <- function(filepath){
  ls <- list()
  #reads into a text file at first
  text <- readLines(filepath,warn=F)
  #finds the header start
  idxHeaderTop <- which(grepl('\\*\\*\\*\\*\\*',text))
  #finds the header bottom
  idxHeaderBottom <- which(grepl('\\-\\-\\-\\-\\-',text))
  #potentially returns the header as well in a list
  ls[["header"]] <- parse_asterisk_value(text[(idxHeaderTop+1):(idxHeaderBottom-1)])
  
  #todo
  idxTerrainTop <- which(grepl('\\*\\*\\*Terrain information\\*\\*\\*',text))
  idxTerrainBottom <- which(grepl('\\-\\-\\-Terrain information\\-\\-\\-',text))
  ls[["terrain"]]  <- parse_asterisk_value(text[(idxTerrainTop+1):(idxTerrainBottom-1)])
  
  #todo - so far it only reads one
  idxSceneTop <- which(grepl('\\*\\*\\*Scenario information\\*\\*\\*',text))
  idxSceneBottom <- which(grepl('\\-\\-\\-Scenario information\\-\\-\\-',text))
  if (length(idxSceneTop) > 0 & length(idxSceneBottom) > 0){
    ls[["scenario"]]  <- parse_asterisk_value(text[(idxSceneTop+1):(idxSceneBottom-1)])
  }
  #todo - so far it only reads one
  idxSceneTop <- which(grepl('\\*\\*\\*Screen information\\*\\*\\*',text))
  idxSceneBottom <- which(grepl('\\-\\-\\-Screen information\\-\\-\\-',text))
  if (length(idxSceneTop) > 0 & length(idxSceneBottom) > 0){
    ls[["screen"]]  <- parse_asterisk_value(text[(idxSceneTop+1):(idxSceneBottom-1)])
  }
  return(ls)
}
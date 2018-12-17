open_quest_log <- function(filepath){
  ls <- list()
  #reads into a text file at first
  text <- readLines(filepath,warn=F)
  #finds the header start
  idxHeaderTop <- which(grepl('\\*\\*\\*\\*\\*',text))
  #finds the header bottom
  idxHeaderBottom <- which(grepl('\\-\\-\\-\\-\\-',text))
  #potentially returns the header as well in a list
  ls[["header"]] <- parse_asterisk_value(text[(idxHeaderTop+1):(idxHeaderBottom-1)])
  #todo - reads the header 
  idxStepTop <- which(grepl('\\*\\*\\*Quest step data\\*\\*\\*',text))
  idxStepBottom <- which(grepl('\\-\\-\\-Quest step data\\-\\-\\-',text))
  #puts everyting from the quest header to the steps list
  file = textConnection(text[(idxStepTop+1):(idxStepBottom-1)])
  ls[["steps"]]  <- read.table(file, header=T, sep=";", stringsAsFactors=F)
  close(file)
  #and the timestamps and other the the data list
  ls$data <- read.table(filepath, header=T, sep=";",dec=".", skip = idxStepBottom, stringsAsFactors = F)
  #deletes last column
  ls$data[ncol(ls$data)] = NULL
  return(ls)
}
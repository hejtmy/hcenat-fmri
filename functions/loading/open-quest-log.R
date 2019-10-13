open_quest_log <- function(filepath){
  ls <- list()
  text <- readLines(filepath,warn=F)
  idxHeaderTop <- which(grepl('\\*\\*\\*\\*\\*',text))
  idxHeaderBottom <- which(grepl('\\-\\-\\-\\-\\-',text))
  ls[["header"]] <- parse_asterisk_value(text[(idxHeaderTop+1):(idxHeaderBottom-1)])
  idxStepTop <- which(grepl('\\*\\*\\*Quest step data\\*\\*\\*',text))
  idxStepBottom <- which(grepl('\\-\\-\\-Quest step data\\-\\-\\-',text))
  file <- textConnection(text[(idxStepTop+1):(idxStepBottom-1)])
  ls[["steps"]]  <- read.table(file, header=T, sep=";", stringsAsFactors=F)
  close(file)
  ls$data <- read.table(filepath, header=T, sep=";",dec=".", skip = idxStepBottom, stringsAsFactors = F)
  ls$data[ncol(ls$data)] <- NULL
  return(ls)
}
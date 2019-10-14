library(stringr)
##Helper for escaping characters in quest names
escape_quest_regex <- function(string){
  return(gsub("([.|()\\^{}+$*?]|\\[|\\])", "\\\\\\1", string))
}

# the header files ar writen in this format
## PROPERTY NAME: *VALUE*
## PROPERTY NAME 2: *VALUE 2*
# this function sorts that out into the list/dictionary of keys and values
parse_asterisk_value <- function(text = ""){
  ls <- list()
  for (info in text) {
    split <- str_split(info, pattern = ":",n=2) #finds the PROEPRTY NAME
    # strsplit creates a list of lists so we need to extract the CODE
    code <- split[[1]][1]
    #extracting the VALUE from the second part of the list
    value <- str_extract_all(split[[1]][2],"\\*(.*?)\\*")[[1]][1]
    value <- substring(value, 2, nchar(value)-1)# removing trailing *
    ls[[code]] <- value
  }
  return(ls)
}
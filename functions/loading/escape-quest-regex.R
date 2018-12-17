##Helper for escaping characters in quest names
escape_quest_regex <- function(string){
  return(gsub("([.|()\\^{}+$*?]|\\[|\\])", "\\\\\\1", string))
}
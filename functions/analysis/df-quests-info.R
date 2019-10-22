library(stringr)
#' Createst summary data frame with all the quests for some functions
#'
#' @param quests_logs all quests as loaded by the read unity data
#'
#' @return data.frame with basic quests information
#' @export
#'
#' @examples
df_quests_info <- function(quests_logs){
  if (length(quests_logs) == 0) next
  df_result <- data.frame(id = numeric(0), 
                   order_session = numeric(0), 
                   name = character(0), 
                   type = character(0), 
                   order_set = numeric(0),
                   stringsAsFactors = FALSE)
  order_session <- 1
  for(i in 1:length(quests_logs)){
    quest_info <- get_quest_info(quests_logs[i])
    df_result <- rbindlist(list(df_result, list(as.numeric(quest_info$id), order_session, quest_info$name, quest_info$type, i)))
    order_session <- order_session + 1
  }
  return(df_result)
}

get_quest_info <- function(quest_log){
  ls <- list()
  ls[["name"]] <- names(quest_log)
  # gets all the letters and numbers until the dash(-) symbol
  # first is E in VR experiments, second the quest index and then the a/b version
  id_pattern <- "(.*?)-"
  id_part <- str_match(ls[["name"]], id_pattern)[2]
  # weird complicated stuff because the naming of quests conventions don't make sense
  if(is.na(id_part)) stop("not clear quest log naming")
  ls$id <- as.numeric(str_match(id_part, "[AB](\\d+)")[2])
  if(!is.na(str_match(id_part, "[A]")[1])) ls[["id"]] <- ls[["id"]]*2
  if(!is.na(str_match(id_part, "[B]")[1])) ls[["id"]] <- ls[["id"]]*2-1
  if(is.null(ls$id)) stop ("No appropriate id")
  # MRI has B for trials with directions and A for trials
  # Eyetracker has a for learning trials and "b" for trials
  learn <- c("a", "B")
  trial <- c("b", "A")
  type_pattern = "[aAbB]"
  if(is.na(str_match(id_part, type_pattern)[1])) stop("not clear quest log naming")
  type_string <- str_match(id_part, type_pattern)[1]
  type <- NA
  if (type_string %in% learn) type <- "learn"
  if (type_string %in% trial) type <- "trial"
  ls[["type"]] <- type
  return(ls)
}

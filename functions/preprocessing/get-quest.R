library(dplyr)

#' Returns quest as a list
#'
#' @param df_quests dataframe with quests as created by df_quests_info
#' @param quests_logs logs with all quests s loaded by 
#' @param i_quest index of given quest (either session index if types not given, or quest index if type is given)
#' @param quest_types type of quest("learn" vs "trial"), as found in the quest_set
#'
#' @return quest list with given information (header, steps, data, name, order_session)
#' @export
#'
#' @examples 
get_quest <- function(df_quests, quests_logs, i_quest, quest_types = NULL){
  ls <-  list()
  #if the length is 0, we assume that the quest_id is order_session
  if(length(quest_types) == 0){
    quest_lines <- df_quests[df_quests$order_session %in% i_quest, ]
    if(nrow(quest_lines) == 0) return(NULL)
    for(i in 1:nrow(quest_lines)){
      quest_line <-  quest_lines[i,]
      if(is.null(quest_line)) stop(quest_line)
      quest <- quests_logs[quest_line$order_set]
      if(is.null(quest)) return(NULL)
      quest[[1]]$name <- dplyr::select(quest_line,name)[[1]]
      quest[[1]]$order_session <- dplyr::select(quest_line, order_session)[[1]]
      ls <- c(ls, quest)
    }
    ls <- ls[[1]] #$removes redundant header - we can resave it
  } 
  if(length(quest_types) > 0){
    quest_lines <- filter(df_quests, id == i_quest & type %in% quest_types)
    if(!(nrow(quest_lines) > 0)) return(NULL) 
    for(i in 1:nrow(quest_lines)){
      quest_line = quest_lines[i, ]
      ls[[quest_types[i]]] <- quests_logs[quest_line$order_set][[1]]
      ls[[quest_types[i]]]$name <- dplyr::select(quest_line, name)[[1]]
      ls[[quest_types[i]]]$order_session <- dplyr::select(quest_line, order_session)[[1]]
    }
    #if we only searched for a signle quest
    if(length(quest_types) == 1) ls <- ls[[1]]
  }
  return(ls)
}
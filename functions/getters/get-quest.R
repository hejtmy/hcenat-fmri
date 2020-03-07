#' Returns quest as a list
#'
#' @param df_quests dataframe with quests as created by df_quests_info
#' @param quests_logs logs with all quests s loaded by 
#' @param i_quest index of given quest (either session index if types not given, or quest index if type is given)
#'
#' @return quest list with given information (header, steps, data, name, order_session)
#' @export
#'
#' @examples 
get_quest <- function(quests_logs, i_quest){
  quest <- quests_logs[i_quest][[1]]
  if(is.null(quest)) return(NULL)
  quest$name <- names(quests_logs[i_quest])
  quest$order_session <- i_quest
  quest$type <- get_quest_type(quest)
  return(quest)
}

#' Returns logical if the quest was succesfully finished
#'
#' @param quest 
was_quest_finished <- function(quest){
  return(!is.null(get_last_step_finished_time(quest)))
}


#' Title
#'
#' @param quest 
#'
#' @return either "control" or "experimental"
#' @export
#'
#' @examples
get_quest_type <- function(quest){
  # TODO combine with the get_quest_info
  if(grepl("Sipka", quest$name)) return("learn")
  if(grepl("A[0-9]", quest$name)) return("trial")
  return("unknown")
}

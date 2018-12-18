add_pulses_player <- function(quests_set, quests_log, player_log){
  player_log$pulse <- NA_integer_
  player_log$quest <- NA_integer_
  
  for(i in 1:nrow(quests_set)){
    quest <- get_quest(quests_set, quests_log, i)
    quest_times <- get_quest_timewindow(quest, include_teleport = T) #can be null
    player_log[Time > quest_times$start & Time < quest_times$finish, quest := i]
  }
  return(player_log)
}
open_quests_logs = function(experiment_log, scenario_log = NULL){
  if (is.null(scenario_log)) return (NULL)
  directory <- dirname(experiment_log$filename)
  #prepares list
  ls = list()
  #list of activated logs from the scenario process
  #it looks for steps finished because for some weird reason of bad logging
  table_steps_activated <- scenario_log$data[scenario_log$data$Action=="StepActivated",]
  table_steps_finished <- scenario_log$data[scenario_log$data$Action=="StepFinished",]
  if (nrow(table_steps_activated) >= nrow(table_steps_finished)) use_finished = F else use_finished = T
  for_interations <- if (use_finished) nrow(table_steps_finished) else nrow(table_steps_activated) 
  for(i in 1:for_interations){
    if (use_finished){
      step <- table_steps_finished[i,]
      timestamp <- ""
      #name of the step that activated the quest
      finished_step_name = scenario_log$steps[scenario_log$steps$ID == step$StepID,"Name"]
      #get the name of the quest activated from the name of the atctivation step
      quest_name <- get_activated_quest_name(finished_step_name)
    } else {
      step = table_steps_activated[i,]
      timestamp = step$Timestamp
      #name of the step that activated the quest
      activated_step_name = scenario_log$steps[scenario_log$steps$ID == step$StepID,"Name"]
      #get the name of the quest activated from the name of the atctivation step
      quest_name <- get_activated_quest_name(activated_step_name)
    }
    if(is.na(quest_name)) next
    if (!is.null(quest_name) ){
      ptr <- paste("_", escape_quest_regex(quest_name), "_", timestamp, sep="")
      #needs to check if we got only one file out
      log <- list.files(directory, pattern = ptr, full.names = T)[1]
      if(!file.exists(log)){
        print(paste("!!!Could not find the file for given quest log!!!", ptr, sep = " "))
        print(ptr)
        next
      }
      #might change this 
      ls[[quest_name]] = open_quest_log(log)
    }
  }
  return(ls)
}

#helper function to figure out the name of the activated quest as is saved in the steps
#list in the scenario quest
get_activated_quest_name <- function(string = ""){
  #The name of the quest is between square brackets - [quest name]
  name <- str_extract_all(string,"\\[(.*?)\\]")[[1]][1]
  #removing the square brackets
  name <- substring(name, 2, nchar(name) - 1)
  return(name)
}
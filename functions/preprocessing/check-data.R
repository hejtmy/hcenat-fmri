check_data_participant <- function(data){
  for(s in 1:2){
    main_message <- paste0("Session ", s, " of participant ", data[[1]]$experiment_log$header$Patient, " has ")
    if(is.null(data[[s]])){
      warning("Session ", s, " is missing")
      next
    }
    iSynchro <- which(data[[s]]$player_log$Input == "fMRISynchro")
    
    if(length(iSynchro) != 400) warning(main_message, length(iSynchro), " pulses")
    quests_results <- quests_summary_participant(data[[s]])
    if(ncol(quests_results) != 16) warning(main_message, ncol(quests_results), " columns in results")
    if(nrow(quests_results) != 20) warning(main_message, nrow(quests_results), " quests in results")
  }
}
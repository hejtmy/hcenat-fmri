pulse_average_speeds.participants <- function(participants){
  res <- data.frame()
  for(id in names(participants)){
    participant_res <- pulse_average_speeds.participant(participants[[id]]) 
    participant_res$id <- id
    res <- rbind(res, participant_res)
  }
  return(res)
}
pulse_average_speeds.participant <- function(participant){
  res <- data.frame()
  for(i in length(participant)){
    session_speed <- pulse_average_speeds.session(participant[[i]])
    if(is.null(session_speed)) next
    session_res <- data.frame(speed = session_speed, pulse = 1:length(session_speed), 
                              session = rep(i, length(session_speed)))
    res <- rbind(res, session_res)
  }
  return(res)
}
#' returns vector of speeds and number of speed NA values for each pulse 
#'
#' @param session session data
#' @param na.limit maximum limit of NA speed values in a pulse for it to be flagged as na. Default 5 
#'
#' @return numeric(400) speeds for each pulse. Vector value at a pulse is NA 
#' if the number of speed NA in a pulse was above na.limit
#' @export
#'
#' @examples
pulse_average_speeds.session <- function(session, na.limit = 5){
  nav <- as.navr.session(session)
  nav <- navr::remove_unreal_speeds(nav, cutoff=30, type="value")
  log <- nav$data[!is.na(nav$data$pulse_id),]
  res <- aggregate(log$speed, by = list(pulse = log$pulse_id), mean, na.rm = TRUE)
  res.na <- aggregate(log$speed, by = list(pulse = log$pulse_id), function(x) sum(is.na(x)))
  res$x[res.na$x > na.limit] <- NA_real_
  res <- res$x
  if(length(res) != N_PULSES){
    warning('Something went wrong')
    return(NULL)
  }
  return(res)
}
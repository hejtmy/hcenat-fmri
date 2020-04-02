pulse_sum_rotation.participants <- function(participants){
  res <- data.frame()
  for(id in names(participants)){
    participant_res <- pulse_sum_rotation.participant(participants[[id]]) 
    participant_res$id <- id
    res <- rbind(res, participant_res)
  }
  return(res)
}

pulse_sum_rotation.participant <- function(participant){
  res <- data.frame()
  for(i in length(participant)){
    session_rotation <- pulse_sum_rotation.session(participant[[i]])
    if(is.null(session_rotation)) next
    session_rotation$session <- rep(i, length(session_rotation))
    res <- rbind(res, session_rotation)
  }
  return(res)
}
#' returns vector of x and y rotation and total
#'
#' @param session session data
#'
#' @return numeric(400) speeds for each pulse. Vector value at a pulse is NA 
#' if the number of speed NA in a pulse was above na.limit
#' @export
#'
#' @examples
pulse_sum_rotation.session <- function(session){
  nav <- as.navr.session(session)
  log <- nav$data[!is.na(nav$data$pulse_id),]
  x <- aggregate(abs(log$rotation_x_diff), by = list(pulse = log$pulse_id), sum, na.rm = TRUE)
  y <- aggregate(abs(log$rotation_y_diff), by = list(pulse = log$pulse_id), sum, na.rm = TRUE)
  if(any(sapply(c(x[2], y[2]), length) != 400)){
    warning('Something went wrong')
    return(NULL)
  }
  res <- data.frame(x=x$x, y=y$x, pulse = 1:N_PULSES)
  res$total <- res$x + res$y
  return(res)
}
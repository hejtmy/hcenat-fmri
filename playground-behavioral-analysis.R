res_pulses <- data.frame()
for(participant_name in names(hrfs)){
  rot_x <- hrfs[[name]]$rotation_x
  part_res <- res %>% filter(ID == participant_name)
  iPulses <- which(!is.na(part_res$pulse_start) & !is.na(part_res$pulse_end))
  pointing_pulses <- unlist(sapply(iPulses, function(x){seq(part_res$pulse_start[x], part_res$pulse_end[x], by = 1)}))
  non_pointing_pulses <- setdiff(1:400, pointing_pulses)
  res_pulses <- rbind(res_pulses,
                      data.frame(pointing = mean(rot_x[pointing_pulses]),
                               mot = mean(rot_x[non_pointing_pulses])))
}

res_pulses
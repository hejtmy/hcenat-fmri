ggplot(df_glm, aes(x = pulse_id, y=value, color = hrf)) +
  geom_line() +
  geom_line(aes(x=pulse_id, y=component), color = "black") +
  facet_wrap(~hrf, ncol=1)


ggplot(df_all, aes(pulse_id, moving)) + 
  geom_line(size=1.5) + facet_wrap(~participant) + 
  geom_line(aes(y=-filt_mot_33), color= "blue")


ggplot(filter(df_all, participant=="HCE_E_10"), aes(pulse_id, moving)) + 
  geom_line(size=2) +
  geom_line(aes(y=-filt_mot_33), color= "blue")


ggplot(filter(df_all, participant=="HCE_K_6"), aes(pulse_id, moving)) +
  geom_line(size=2) +
  geom_line(aes(y=-filt_hpc_12), color= "blue")


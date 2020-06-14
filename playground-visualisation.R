ggplot(df_glm, aes(x = pulse_id, y=value, color = hrf)) +
  geom_line() +
  geom_line(aes(x=pulse_id, y=component), color = "black") +
  facet_wrap(~hrf, ncol=1)
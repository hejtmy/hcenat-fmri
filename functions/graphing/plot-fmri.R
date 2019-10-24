plot_component <- function(timeseries){
  df <- timeseries %>% melt(id.vars = "pulse_id")
  plt <- ggplot(df, aes(pulse_id, value, color = variable)) + geom_line()
  return(plt)
}

add_events <- function(){
  
}
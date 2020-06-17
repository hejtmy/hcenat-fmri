library(navr)
library(plotly)
library(dplyr)
library(knitr)
library(car)
library(tidyr)

sapply(list.files("functions", full.names = TRUE, recursive = TRUE), source)
data_dir <- "E:/OneDrive/NUDZ/projects/HCENAT/Data/"
img_path <- "images/megamap5.png"

source("scripts/load-data.R")

## Correlations ------
correlations <- data.frame(stringsAsFactors = FALSE)
for(name in good_participants){
  participant_series <- hrfs[[name]]
  comps <- sapply(components, function(x){x[[name]]}, USE.NAMES = TRUE, simplify = FALSE)
  for(series_name in names(participant_series)){
    series <- participant_series[[series_name]]
    res <- sapply(comps, function(x){cor(x, series, use = "complete.obs")}, simplify = FALSE)
    res$participant <- name
    res$event <- series_name
    correlations <- rbind(correlations, as.data.frame(res))
  }
}
cor_long <- correlations %>% pivot_longer(cols = -c(participant, event), names_to = "component")
avg_cor <- cor_long %>% group_by(event, component) %>% summarize(average = mean(value))

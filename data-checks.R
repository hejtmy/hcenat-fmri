library(car)
library(navr)
library(plotly)
library(knitr)
library(nlme)
library(tidyverse)

sapply(list.files("functions", full.names = TRUE, recursive = TRUE), source)
data_dir <- "E:/OneDrive/NUDZ/projects/HCENAT/Data/"

source("scripts/load-data.R")

## Pointing ------
# Checking that pointing HRFS correspond
plot_pointing_hrfs <- function(hrfs, df_behavioral, participant){
  hrf <- hrfs[[participant]]
  ggplot(data=data.frame()) +
    geom_line(aes(1:400, y=hrf$pointing), size=2) +
    geom_line(aes(1:400, y=hrf$`pointing-learn`), color="red") +
    geom_line(aes(1:400, y=hrf$`pointing-trial`), color="blue") +
    geom_vline(data=filter(df_behavioral, ID==participant),
               aes(xintercept=quest_pulse_start, color = type)) +
    scale_color_manual(values=c("learn" = "red", "trial"="blue"))
}
plot_pointing_hrfs(hrfs, df_behavioral, "HCE_E_14")
plot_pointing_hrfs(hrfs, df_behavioral, "HCE_K_4")

#' The missing pointings are the pointings which encompassed less then 0.75 percent of the 
#' pulse and therefore weren't modeled in the HRF modelling part in matlab

## Movement ------

plot_movement_hrfs <- function(hrfs, df_behavioral, participant){
  hrf <- hrfs[[participant]]
  ggplot(data=data.frame()) +
    geom_line(aes(1:400, y=hrf$moving), size=2) +
    geom_line(aes(1:400, y=hrf$`moving-learn`), color="red") +
    geom_line(aes(1:400, y=hrf$`moving-trial`), color="blue") +
    geom_vline(data=filter(df_behavioral, ID==participant),
               aes(xintercept=quest_pulse_start, color = type)) +
    scale_color_manual(values=c("learn" = "red", "trial"="blue"))
}

plot_movement_hrfs(hrfs, df_behavioral, "HCE_E_14")
plot_movement_hrfs(hrfs, df_behavioral, "HCE_K_4")
plot_movement_hrfs(hrfs, df_behavioral, "HCE_E_9")


### Non separated movement hrfsparticipant_id <- "HCE_E_9"
hrf <- as.data.frame(hrfs[[participant_id]]) %>%
  select(moving.learn, moving, moving.trial) %>%
  mutate(pulse_id = 1:N_PULSES, ID = participant_id) %>%
  left_join(df_pulses, by=c("ID", "pulse_id")) %>%
  pivot_longer(cols=c(moving.learn:moving.trial))

# Visualising coloring of 
filter(hrf, name == "moving") %>%
  ggplot(aes(pulse_id, value, color=learn, group="ALL")) +
  geom_line(size=1.25) +
  geom_vline(data=filter(df_behavioral, ID==participant_id),
             aes(xintercept=quest_pulse_start))

## The three consecutive learning trials corrrespond to the situation int he data

## Visualising movement types with overlap
#' 1 = only one is active
#' 0 = no třype of trial is running
#' 2 both are seemingly active
filter(hrf, name == "moving") %>%
  ggplot(aes(pulse_id, value, color=factor(learn+trial), group="ALL")) +
  geom_line(size=1.25)

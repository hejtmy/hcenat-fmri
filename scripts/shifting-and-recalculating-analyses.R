library(tidyverse)
source("scripts/loading.R")
SHIFT_INTERVAL <- c(-30, 30)
EVENTS_DIR <- file.path("exports", "events")
EXPORT_DIR <- file.path("exports", "shifted-events")
if(!dir.exists(EXPORT_DIR)) dir.create(EXPORT_DIR)

files <- list.files(EVENTS_DIR, full.names = TRUE, pattern = ".*\\.csv")
filenames <- basename(files)

## Load the onsets and stops
set.seed(14564645)
for(i in 1:length(files)){
  filepath <- files[i]
  df_events <- read.csv(filepath)
  df_events$time <- df_events$time + runif(nrow(df_events),
                                         min = SHIFT_INTERVAL[1],
                                         max = SHIFT_INTERVAL[2])
  new_path <- file.path(EXPORT_DIR, filenames[i])
  write.table(df_events, new_path, row.names = FALSE, sep = ",", quote = FALSE)
}

## Run the matlab code in exportshiftedhrfs.m

## Load
DATA_DIR <- "E:/OneDrive/NUDZ/projects/HCENAT/Data/"
COMPONENT_TYPE <- "filtered"
RELATIVE_DIR <- "."
source("scripts/load-data.R")
df_all_hrfs <- df_shifted_hrfs %>%
  right_join(df_hrfs, by = c("participant", "pulse_id"))

## Visually compare
df_all_hrfs %>%
  ggplot(aes(x=pulse_id)) +
    geom_line(aes(y = shifted_moving.trial), color = "red") +
    geom_line(aes(y = moving.trial), color = "black") +
    facet_wrap(~participant)

cor(df_all_hrfs$shifted_pointing, df_all_hrfs$pointing)

## CALCULATING shifted betas ------
library(nlme)
library(broom.mixed)
library(tidyverse)
df_all_shifted <- merge(df_shifted_hrfs, df_fmri_all,
                        by = c("pulse_id", "participant"))
df_all_shifted <- left_join(df_all_shifted, df_pulses,
                            by = c("participant" = "ID", "pulse_id"))
df_all_shifted <- arrange(df_all_shifted, participant, pulse_id)
colnames(df_all_shifted) <- gsub("shifted_", "", colnames(df_all_shifted))

components <- components_all
df_analysis <- df_all_shifted

component_names <- names(components)
participant_names <- unique(df_analysis$participant)

## Setting parameters -------
FORMULA <- " ~ 1 + moving.learn + moving.trial + pointing.learn + pointing.trial"
autocorrelation_structure_first <- corAR1(0.3, form = ~1)

## Mixed model first level output -------
lme_first_order_model <- function(formula, dat){
  mod <- gls(formula,
             method = "REML",
             data = dat,
             control = nlme::lmeControl(rel.tol = 1e-6),
             correlation = autocorrelation_structure_first)
  return(mod)
}
df_first_order_beta_shifted <- data.frame()
for(component in component_names){
  message("\nCalculating for component ", component)
  for(participant_code in participant_names){
    cat(".")
    df_participant <- df_analysis[df_analysis$participant == participant_code, ]
    form <- paste0(component, FORMULA)
    form <- as.formula(form)
    mod <- lme_first_order_model(form, df_participant)
    mod_out <- tidy(mod) %>%
      mutate(participant = participant_code, component = component)
    df_first_order_beta_shifted <- rbind(df_first_order_beta_shifted, mod_out)
  }
}
write.table(df_first_order_beta_shifted,
            file = "summaries/first-order-beta-shifted.csv", 
            sep = ";", row.names = FALSE)
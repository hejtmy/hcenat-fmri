library(nlme)
library(broom.mixed)
library(tidyverse)

# Preparing data ------
sapply(list.files("functions", full.names = TRUE, recursive = TRUE), source)
DATA_DIR <- "E:/OneDrive/NUDZ/projects/HCENAT/Data/"
COMPONENT_TYPE <- "filtered"
RELATIVE_DIR <- "."

source("scripts/load-data.R")
df_all <- merge(df_hrfs, df_fmri_all, by = c("pulse_id", "participant"))
df_all <- left_join(df_all, df_pulses, by = c("participant" = "ID", "pulse_id"))
df_all <- arrange(df_all, participant, pulse_id)

components <- components_all
df_analysis <- df_all

component_names <- names(components)
participant_names <- unique(df_analysis$participant)

## Setting parameters -------
FORMULA <- " ~ 1 + moving.learn + moving.trial + pointing.learn + pointing.trial"
contrast <- matrix(c(0,-1,1,0,0, 0,1,1,0,0, 0,0,0,-1,1, 0,0,0,1,1),
                   4, 5, byrow = TRUE)

rownames(contrast) <- c("movement.trial > movement.learn", "movement > 0", 
                        "pointing.trial > pointing.learn", "pointing > 0")

autocorrelation_structure <- corAR1(0.3, form = ~1|participant)
autocorrelation_structure_first <- corAR1(0.3, form = ~1)

## Mixed model second level output ------
# Created with functions as set in https://psyarxiv.com/crx4m/
message("Starting second level analysis")
lme_second_order_model <- function(formula, component){
  f_fixed <- as.formula(paste0(component, formula))
  f_random <- as.formula(paste0(FORMULA, " | participant"))
  mod <- lme(f_fixed,
      random = f_random,
      method = "REML",
      data = df_analysis,
      control = nlme::lmeControl(rel.tol=1e-6),
      correlation = autocorrelation_structure)
  return(mod)
}
df_mixed_beta <- data.frame()
df_mixed_contrast <- data.frame()
for(component in component_names){
  message("Calculating for component ", component)

  mod <- lme_second_order_model(form, component)
  fname <- file.path(RELATIVE_DIR, "models", paste0("lme_", component, "_ar1"))
  save(mod, file = fname)
  cont <- contrast_output(mod, contrast) %>%
    mutate(component = component)
  df_mixed_contrast <- rbind(df_mixed_contrast, cont)
  
  mod_out <- tidy(mod) %>%
    filter(effect == "fixed") %>%
    select(-c(effect, group)) %>%
    mutate(component = component)
  df_mixed_beta <- rbind(df_mixed_beta, mod_out)
}
write.table(df_mixed_beta, file = "summaries/second-order-mixed-beta.csv",
            sep = ";", row.names = FALSE)
write.table(df_mixed_contrast, file = "summaries/second-order-mixed-contrasts.csv",
            sep = ";", row.names = FALSE)

## Mixed model fMRI package settings
# https://github.com/cran/fmri/blob/4b4d69d4e899abafe201d271852dfbe4c6aca69b/R/lmGroup.R
# Its is basically the same but the intercepts are set to 0
message("calculating zero intercept models")
lme_second_order_model_fmripackage <- function(formula, component){
  f_fixed <- as.formula(paste0(component, formula))
  f_random <- as.formula(paste0(formula, " | participant"))
  mod <- lme(f_fixed,
      random = f_random,
      method = "REML",
      data = df_analysis,
      control = nlme::lmeControl(rel.tol=1e-6),
      correlation = corAR1(0.3, form = ~1|participant, fixed = TRUE))
  return(mod)
}

df_mixed_fmripackage_beta <- data.frame()
df_mixed_fmripackage_contrast <- data.frame()
zero_intercept_contrast <- matrix(c(-1,1,0,0, 1,1,0,0, 0,0,-1,1, 0,0,1,1),
                                  4, 4, byrow = TRUE)
for(component in component_names){
  message("Calculating for component ", component)
  mod <- lme_second_order_model_fmripackage(
    " ~ 0 + moving.learn + moving.trial + pointing.learn + pointing.trial",
    component)
  fname <- file.path(RELATIVE_DIR, "models", paste0("lme_", component, "_ar1_fmripackage"))
  save(mod, file = fname)
  cont <- contrast_output(mod, zero_intercept_contrast) %>%
    mutate(component = component)
  df_mixed_fmripackage_contrast <- rbind(df_mixed_fmripackage_contrast, cont)
  
  mod_out <- tidy(mod) %>%
    filter(effect == "fixed") %>%
    select(-c(effect, group)) %>%
    mutate(component = component)
  df_mixed_fmripackage_beta <- rbind(df_mixed_fmripackage_beta, mod_out)
}
write.table(df_mixed_beta, file = "summaries/second-order-mixed-fmripackage-beta.csv",
            sep = ";", row.names = FALSE)
write.table(df_mixed_contrast, file = "summaries/second-order-mixed-fmripackage-contrasts.csv",
            sep = ";", row.names = FALSE)


## Mixed model first level output -------
message("calculating first level analyses")
lme_first_order_model <- function(formula, dat){
  mod <- gls(formula,
      method="REML",
      data = dat,
      control = nlme::lmeControl(rel.tol=1e-6),
      correlation = autocorrelation_structure_first)
  return(mod)
}
df_first_order_beta <- data.frame()
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
    df_first_order_beta <- rbind(df_first_order_beta, mod_out)
  }
}
write.table(df_first_order_beta, file = "summaries/first-order-beta.csv", 
            sep = ";", row.names = FALSE)

## GLM first level output ----
message("calculating GLMs")
glm_first_order_model <- function(formula, dat){
  mod <- gls(formula,
             method = "REML",
             data = dat)
  return(mod)
}

df_glm_first_order_beta <- data.frame()
for(component in component_names) {
  message("\nCalculating GLM for component ", component)
  for(participant_code in participant_names){
    cat(".")
    df_participant <- df_analysis[df_analysis$participant == participant_code, ]
    form <- paste0(component, FORMULA)
    form <- as.formula(form)
    mod <- glm_first_order_model(form, df_participant)
    mod_out <- tidy(mod) %>%
      mutate(participant = participant_code, component = component)
    df_glm_first_order_beta <- rbind(df_glm_first_order_beta, mod_out)
  }
}

write.table(df_glm_first_order_beta, file = "summaries/glm-first-order-beta.csv", 
            sep = ";", row.names = FALSE)

## Other exports ------
write.table(df_component_localization, file = "summaries/component-localization.csv", 
            sep = ";", row.names = FALSE)

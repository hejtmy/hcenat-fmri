library(nlme)
library(broom.mixed)
library(tidyverse)

sapply(list.files("functions", full.names = TRUE, recursive = TRUE), source)
DATA_DIR <- "E:/OneDrive/NUDZ/projects/HCENAT/Data/"

source("scripts/load-data.R")
df_all <- df_all %>% arrange(participant, pulse_id)

component_names <- names(components)
participant_names <- unique(df_all$participant)
contrast <- matrix(c(-1,1,0,0,1,1,0,0,0,0,-1,1,0,0,1,1), 4, 4)
rownames(contrast) <- c("movement.trial > movement.learn", "movement > 0", 
                        "pointing.trial > pointing.learn", "pointing > 0")

contrast_output <- function(model, contrast){
  out <- multcomp::glht(model, lincft=contrast)
  out <- as.data.frame(summary(out)$test[c('coefficients', 'sigma', 'tstat', 'pvalues')])
  out$contrast <- rownames(contrast)
  return(out)
}

autocorrelation_structure <- corAR1(0.3, form = ~1|participant)
autocorrelation_structure_first <- corAR1(0.3, form = ~1)

## Mixed model second level output ------
lme_second_order_model <- function(formula){
  mod <- lme(formula,
      random = ~ 0 + moving.learn + moving.trial + pointing.learn + pointing.trial | participant,
      method="REML",
      data = df_all,
      control = nlme::lmeControl(rel.tol=1e-6),
      correlation = autocorrelation_structure)
  return(mod)
}
df_mixed_beta <- data.frame()
df_mixed_contrast <- data.frame()
for(component in component_names){
  message("Calculating for component ", component)
  form <- paste0(component, " ~ 0 + moving.learn + moving.trial + pointing.learn + pointing.trial")
  form <- as.formula(form)
  mod <- lme_second_order_model(form)
  fname <- paste0("lme_", component, "_ar1")
  save(mod, file=fname)
  cont <- contrast_output(mod, contrast) %>%
    mutate(compoentn = component)
  df_mixed_contrast <- rbind(df_mixed_contrast, cont)
  
  mod <- tidy(mod) %>%
    filter(effect == "fixed") %>%
    select(-c(effect, group)) %>%
    mutate(component = component)
  df_mixed_beta <- rbind(df_mixed_beta, mod)
}
write.table(df_mixed_beta, file="summaries/second-order-mixed-beta.csv")
write.table(df_mixed_contrast, file="summaries/second-order-mixed-contrasts.csv")
  
## Mixed model first level output -------
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
    df_participant <- df_all[df_all$participant == participant, ]
    form <- paste0(component, " ~ 0 + moving.learn + moving.trial + pointing.learn + pointing.trial")
    form <- as.formula(form)
    mod <- lme_first_order_model(form, df_participant)
    mod <- tidy(mod) %>%
      mutate(participant = participant, component = component)
    df_first_order_beta <- rbind(df_first_order_beta, mod)
  }
}

write.table(df_first_order_beta, file="summaries/first-order-beta.csv")

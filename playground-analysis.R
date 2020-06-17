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

## Regression analysis 

### For a single participant ----
name <- good_participants[1]
participant_series <- as.data.frame(hrfs[[name]])
participant_series_long <- as.data.frame(hrfs[[name]]) %>%
  mutate(pulse_id = 1:400) %>%
  pivot_longer(cols = -c(pulse_id), names_to = "hrf") %>%
  arrange(hrf, pulse_id)

comps <- sapply(components, function(x){x[[name]]},
                USE.NAMES = TRUE, simplify = FALSE)

## Single testing with moving 
component_name <- names(comps)[1]
df_glm <- participant_series_long %>%
  filter(grepl("moving", hrf)) %>%
  mutate(hrf = factor(hrf), 
         component = rep(comps[[component_name]], 3))

model.matrix.default( ~ hrf, df_glm, contrasts.arg =
                        list(hrf = contr.treatment(n = 3, base = 1)))

model <- glm(component ~ value*hrf, data = df_glm)
model <- glm(comps[[component_name]] ~ 
               participant_series$moving +
               participant_series$moving.learn +
               participant_series$moving.trial +
               participant_series$moving:participant_series$moving.trial +
               participant_series$moving:participant_series$moving.learn)
model <- glm(component ~ value*hrf, data = df_glm, # Same as normal interaction model
             contrasts = list(hrf = contr.treatment(n = 3, base = 1)))
summary(model)
Anova(model,type = "II")


## Single testing without moving ----
library(multcomp)
component_name <- names(comps)[1]
df_glm <- participant_series_long %>%
  filter(grepl("moving.", hrf)) %>%
  mutate(hrf = factor(hrf), 
         bold = rep(comps[[component_name]], 2),
         participant = "NEO")

model <- glm(comps[[component_name]] ~ 
               participant_series$moving.learn:participant_series$moving.trial)
summary(model)
levels(df_glm$hrf)
model <- glm(bold ~ value:hrf, data=df_glm, contrasts = list(hrf=c(-1,1))) #♣contrats do nothing
summary(model)
Anova(model,type = "II")

### GLHT CONTRATS
# intercept, value:hrf1, value:hrf2
contrast <- matrix(c(0, -1, 1), 1)
model <- glm(comps[[component_name]] ~ 
               participant_series$moving.learn + participant_series$moving.trial)
summary(model)
# taken from https://genomicsclass.github.io/book/pages/interactions_and_contrasts.html
inter <- glht(model, linfct=contrast)
summary(inter)

model <- glm(bold ~ value:hrf, data=df_glm)
summary(model)
cont <- glht(model, linfct = mcp(hrf = "Tukey"))
summary(cont)

### Mixed model

### All component -----
regressions_moving_learn_trial <- list()
df_regressions_moving_learn_trial <- data.frame()

for(component_name in names(comps)){
  regressions_moving_learn_trial[[component_name]] <- 
    glm(comps[[component_name]] ~ participant_series$moving.learn + participant_series$moving.trial)
  out <- broom::tidy(regressions_moving_learn_trial[[component_name]])
  out <- out %>%
    select(term, estimate, p.value) %>%
    filter(term != "(Intercept)") %>%
    mutate(term = gsub("participant_series\\$moving\\.", "", .$term),
           component = component_name) %>%
    pivot_wider(id_cols = c(component), names_from = term, 
                values_from = c(estimate, p.value), names_sep = "_")
  df_regressions_moving_learn_trial <- rbind(df_regressions_moving_learn_trial, out)
}

## All participants ------
df_hrfs <- data.frame()
for(name in good_participants){
  out <- as.data.frame(hrfs[[name]])
  out$participant <- name
  out$pulse_id <- 1:400
  df_hrfs <- rbind(df_hrfs, out)
}
all_data <- merge(df_hrfs, fmri, by=c("participant", "pulse_id"))

summary(lm(filt_dmn_52 ~ moving.learn + moving.trial, data=all_data))


all_data %>%
  #filter(participant %in% good_participants[1:10]) %>%
  ggplot(aes(moving, filt_mot_33)) + 
    geom_point() + geom_smooth(method="lm") +
    facet_wrap(~participant) + ylim(-2,2)

l <- lmerTest::lmer(filt_dmn_2 ~ moving.learn + moving.trial + (moving|participant), data=all_data)
summary(l)




library(car)
library(navr)
library(plotly)
library(knitr)
library(nlme)
library(tidyverse)

sapply(list.files("functions", full.names = TRUE, recursive = TRUE), source)
data_dir <- "E:/OneDrive/NUDZ/projects/HCENAT/Data/"
img_path <- "images/megamap5.png"

source("scripts/load-data.R")

## Regression analysis 
name <- good_participants[1]
comps <- sapply(components, function(x){x[[name]]},
                USE.NAMES = TRUE, simplify = FALSE)
component_name <- names(comps)[1]

### For a single participant ----
participant_series <- as.data.frame(hrfs[[name]])
participant_series_long <- as.data.frame(hrfs[[name]]) %>%
  mutate(pulse_id = 1:400) %>%
  pivot_longer(cols = -c(pulse_id), names_to = "hrf") %>%
  arrange(hrf, pulse_id)

## Single testing with moving
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

### Autocorrelation ------
df_gls <- df_all %>%
  filter(participant == name)
model <- gls(filt_hpc_12 ~ moving.trial + moving.learn +
               pointing.trial + pointing.learn, data = df_gls)
summary(model)
plot(residuals(model), type="l")
acf(residuals(model))

#model_arma <- update(model, correlation = corARMA(p = 1, q = 1, form = ~1))
model_arma <- gls(filt_hpc_12 ~ moving.trial + moving.learn + 
                    pointing.trial + pointing.learn, data = df_gls,
             correlation = corARMA(p = 1, q = 1, form = ~1))
summary(model_arma)
plot(fitted(model_arma),residuals(model_arma))
plot(resid(model_arma, type="normalized"), type="l")
acf(resid(model_arma, type="normalized"))

df_all <- df_all %>%
  arrange(participant, pulse_id)

## Mixed models -----
lme_movement_mot_33<- lme(filt_mot_33 ~ 0 + moving.learn + moving.trial +
                            pointing.learn + pointing.trial,
                              random = ~ 0 + moving.learn + moving.trial +
                            pointing.learn + pointing.trial | participant,
                              data = df_all,
                              method="ML")
summary(lme_movement_mot_33)

lme_movement_mot_33_au <- lme(filt_mot_33 ~ 0 + moving.learn + moving.trial +
                                pointing.learn + pointing.trial,
           random = ~ 0 + moving.learn + moving.trial +
             pointing.learn + pointing.trial | participant,
           data = df_all,
           method="ML",
           correlation = corAR1(form = ~1|participant))

summary(lme_movement_mot_33_au)

## TAKES FOREVER
lme_movement_cen_11_au_11 <- lme(filt_cen_11 ~ 1 + moving.learn + moving.trial,
                              random = ~ moving.learn + moving.trial | participant,
                              data = df_all,
                              correlation = corARMA(p = 1, q = 1, form = ~1|participant),
                              method="ML")
summary(lme_movement_cen_11_au_11)
save(lme_movement_cen_11_au_11, file="models/lme_movement_cen_11_au_11")

lme_movement_cen_11 <- lme(filt_cen_11 ~ 0 + moving,
           random = ~ moving.learn | participant,
           data = df_all,
           method="ML")
summary(lme_movement_cen_11)
sapply(fitted(lme_movement_cen_11, asList = TRUE), length)
sapply(resid(lme_movement_cen_11, asList = TRUE), length)

library(broom.mixed)
broom.mixed::augment(lme_movement_cen_11) %>%
  ggplot(aes(pulse_id, filt_cen_11)) + 
    geom_line() + facet_wrap(~participant) +
    geom_line(aes(y=.fitted), col="blue")

## Seeing residuals and checking which model is better
## https://stats.stackexchange.com/questions/80823/do-autocorrelated-residual-patterns-remain-even-in-models-with-appropriate-corre
acf(resid(lme_movement_cen_11))
acf(resid(lme_movement_cen_11_au))
acf(resid(lme_movement_cen_11, type="normalized"))
acf(resid(lme_movement_cen_11_au, type="normalized"))
acf(resid(lme_movement_cen_11_au_11, type="normalized"))

data.frame(resid = resid(lme_movement_cen_11, type="normalized"),
           participant = names(residuals(lme_movement_cen_11)),
           volume = 1:400,
           fitted = fitted(lme_movement_cen_11)) %>%
  ggplot(aes(volume, resid)) + geom_line() + facet_wrap(~participant)

data.frame(resid = resid(lme_movement_cen_11_au, type="normalized"),
           participant = names(residuals(lme_movement_cen_11_au)),
           volume = 1:400,
           fitted = fitted(lme_movement_cen_11_au)) %>%
  ggplot(aes(volume, resid)) + geom_line() + facet_wrap(~participant)

anova(lme_movement_cen_11, lme_movement_cen_11_au, lme_movement_cen_11_au_11)

## Mixed models II ------
df_all_mixed <- df_all %>%
  mutate(moving.learn = moving*learn, moving.trial = moving*trial,
         pointing.learn = pointing*learn, pointing.trial = pointing*trial)

lme_movement_cen_11_au <- lme(filt_cen_11 ~ 1 + moving:trial,
                              random = ~ moving:trial | participant,
                              data = df_all_mixed,
                              method="ML")
summary(lme_movement_cen_11_au)
## TAKES FOREVER
lme_movement_cen_11_au_11 <- lme(filt_cen_11 ~ 1 + moving.learn + moving.trial,
                                 random = ~ moving.learn + moving.trial | participant,
                                 data = df_all_movement_filtered,
                                 correlation = corARMA(p = 1, q = 1, form = ~1|participant),
                                 method="ML")
summary(lme_movement_cen_11_au_11)
save(lme_movement_cen_11_au_11, file="models/lme_movement_cen_11_au_11")

summary(lme_movement_cen_11)
sapply(fitted(lme_movement_cen_11, asList = TRUE), length)
sapply(resid(lme_movement_cen_11, asList = TRUE), length)

library(broom.mixed)
broom.mixed::augment(lme_movement_cen_11) %>%
  ggplot(aes(pulse_id, filt_cen_11)) + 
  geom_line() + facet_wrap(~participant) +
  geom_line(aes(y=.fitted), col="blue")


## Select those components which do something moving wise -----
df_res <- data.frame()
for(participant in unique(df_all$participant)){;
  for(component in component_names){
    formula <- as.formula(paste0(component, "~moving"))
    model <- glm(formula, data = df_all[df_all$participant == participant,])
    coefs <- as.list(summary(model)$coefficients[2,])
    coefs$participant <- participant
    coefs$component <- component
    df_res <- rbind(df_res, as.data.frame(coefs))
  }
}

colnames(df_res) <- c("beta", "std.err", "t.value", "p.value", "participant", "component")
head(df_res)

df_res %>%
  filter(p.value < 0.05) %>%
  ggplot(aes(p.value)) + geom_histogram() + facet_wrap(~component)

bonferroni_p <- 0.05/length(component_names)
df_res %>%
  group_by(component) %>%
  count(pass = p.value < bonferroni_p) %>%
  pivot_wider(names_from = pass, values_from = n)

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
model <- glm(bold ~ value:hrf, data=df_glm, contrasts = list(hrf=c(-1,1))) # contrats do nothing
summary(model)
Anova(model,type = "II")

### GLHT CONTRATS -----
# intercept, value:hrf1, value:hrf2
contrast <- matrix(c(0, -1, 1), 1)
model <- glm(comps[[component_name]] ~ 
               participant_series$moving.learn + participant_series$moving.trial)
summary(model)
# taken from https://genomicsclass.github.io/book/pages/interactions_and_contrasts.html
inter <- multcomp::glht(model, linfct=contrast)
summary(inter)

model <- glm(bold ~ value:hrf, data=df_glm)
summary(model)
cont <- glht(model, linfct = mcp(hrf = "Tukey"))
summary(cont)

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




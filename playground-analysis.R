library(navr)
library(plotly)
library(dplyr)
library(knitr)
library(tidyr)
sapply(list.files("functions", full.names = TRUE, recursive = TRUE), source)
data_dir <- "E:/OneDrive/NUDZ/projects/HCENAT/Data/"
img_path <- "images/megamap5.png"

options(gargle_oauth_email = "hejtmy@gmail.com")
df_preprocessing <- load_participant_preprocessing_status()

# Load components
folder <- file.path(data_dir, "../MRI-data-tomecek/filtered")
names_file <- file.path(data_dir, "../MRI-data-tomecek/subs_20190830_1422.txt")
components <- load_mri(folder, names_file)
components <- rename_mri_participants(components, df_preprocessing)
fmri <- restructure_mri(components)

component_names <- names(components)
good_participants <- get_good_participants(df_preprocessing, "unity")

#only selects those participants who have components
good_participants <- intersect(names(components[[1]]), good_participants)

hrf_names <- c("moving", "still", "pointing")
hrf_folder <- file.path("exports", "hrf")
speed_folder <- file.path("exports", "speeds")
rotation_folder <- file.path("exports", "rotations")

hrfs <- list()
for(name in good_participants){
  code <- fmri_code(name, df_preprocessing)
  f <- file.path(speed_folder, paste0(code, "_speed.txt"))
  #' Speeds have blank lines where there was too many missing values
  hrfs[[name]]$speed <- scan(f, what = numeric(), n = 400, sep = "\n", 
                             fill = NA_real_, blank.lines.skip = FALSE,
                             quiet = TRUE)
  f <- file.path(rotation_folder, paste0(code, "_rotation.txt"))
  rotation <- read.table(f, sep=",", header = TRUE)
  hrfs[[name]]$rotation_x <- rotation$x
  hrfs[[name]]$rotation_total <- rotation$total
  for(hrf in hrf_names){
    f <- file.path(hrf_folder, paste0(code, "_", hrf, ".txt"))
    hrfs[[name]][[hrf]]<- scan(f, n = 400, sep="\n", quiet = TRUE)
    if(length(hrfs[[name]][[hrf]]) != 400){
      warning(name, " ", hrf, " has length ", length(hrfs[[hrf]][[name]]))
    }
  }
}

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

## Regression analysis -----

### For a single participant

name <- good_participants[1]
participant_series <- as.data.frame(hrfs[[name]])

comps <- sapply(components, function(x){x[[name]]}, USE.NAMES = TRUE, simplify = FALSE)
regressions_moving_learn_trial <- list()
df_regressions_moving_learn_trial <- data.frame()
for(component_name in names(comps)){
  regressions_moving_learn_trial[[component_name]] <- lm(comps[[component_name]] ~ participant_series$moving.learn + participant_series$moving.trial)
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

df_regressions_moving_learn_trial
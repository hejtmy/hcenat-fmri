options(gargle_oauth_email = "hejtmy@gmail.com")

if(!exists("RELATIVE_DIR")) RELATIVE_DIR <- "."

# Loading demograhics ---------
message("Loading demographics")
df_preprocessing <- read.table(file.path(RELATIVE_DIR, "exports", "preprocessing.csv"), 
                               sep = ";", header = TRUE)

# Loading pulses -----
df_pulses <- read.table(file.path(RELATIVE_DIR, "exports", "participant-pulses.csv"), 
                        sep = ";", header = TRUE)

# Loading behavioral data ----
df_behavioral <- read.table(file.path(RELATIVE_DIR, "exports", "participant-performance.csv"),
                            sep=";", header = TRUE)

# Load components -----
message("Loading components")
mri_folder <- file.path(DATA_DIR, "../MRI-data-tomecek/raw")
names_file <- file.path(DATA_DIR, "../MRI-data-tomecek/subs_20190830_1422.txt")
components <- load_mri(mri_folder, names_file)
components <- rename_mri_participants(components, df_preprocessing)
fmri <- restructure_mri(components)

## All components
components_all <- load_mri("exports/components/", names_file)
names_clean <- sapply(names(components_all),
                      function(x) {gsub(".csv", "", x)}, USE.NAMES = FALSE)
names(components_all) <- names_clean
components_all <- rename_mri_participants(components_all, df_preprocessing)
fmri_all <- restructure_mri(components_all)


component_names <- names(components)
good_participants <- get_good_participant_ids(df_preprocessing, "unity")

# only selects those participants who have components
good_participants <- intersect(names(components[[1]]), good_participants)

hrf_names <- c("moving", "moving-learn", "moving-trial",
               "still", "still-learn", "still-trial",
               "pointing", "pointing-learn", "pointing-trial")
hrf_folder <- file.path(RELATIVE_DIR, "exports", "hrf")
speed_folder <- file.path(RELATIVE_DIR, "exports", "speeds")
rotation_folder <- file.path(RELATIVE_DIR, "exports", "rotations")

## Loading hrfs ------
message("loading hrfs")
codes <- fmri_code(good_participants, df_preprocessing)

#hrfs <- load_hrfs("exports", hrf_names, codes)
#hrfs <- rename_hrfs(hrfs, df_preprocessing, to="unity")
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

restructure_hrfs <- function(hrfs){
  res <- data.frame()
  for(participant in names(hrfs)){
    temp <- as.data.frame(hrfs[[participant]])
    temp$participant <- participant
    temp$pulse_id <- 1:400
    res <- rbind(res, temp)
  }
  return(res)
}

df_hrfs <- restructure_hrfs(hrfs)
df_mri <- restructure_mri(components)
df_all <- merge(df_hrfs, df_mri, by=c("pulse_id", "participant"))
df_all <- left_join(df_all, df_pulses, by=c("participant" = "ID", "pulse_id"))
df_all <- df_all %>% arrange(participant, pulse_id)

rm(code, codes, component_names, mri_folder, hrf_folder,
   hrf, name, names_file, f, hrf_names, speed_folder, rotation_folder,
   rotation)

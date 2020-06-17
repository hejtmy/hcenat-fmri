options(gargle_oauth_email = "hejtmy@gmail.com")
df_preprocessing <- load_participant_preprocessing_status()

# Load components -----
folder <- file.path(data_dir, "../MRI-data-tomecek/filtered")
names_file <- file.path(data_dir, "../MRI-data-tomecek/subs_20190830_1422.txt")
components <- load_mri(folder, names_file)
components <- rename_mri_participants(components, df_preprocessing)
fmri <- restructure_mri(components)

component_names <- names(components)
good_participants <- get_good_participant_ids(df_preprocessing, "unity")

# only selects those participants who have components
good_participants <- intersect(names(components[[1]]), good_participants)

hrf_names <- c("moving", "moving-learn", "moving-trial",
               "still", "still-learn", "still-trial",
               "pointing")
hrf_folder <- file.path("exports", "hrf")
speed_folder <- file.path("exports", "speeds")
rotation_folder <- file.path("exports", "rotations")

## Loading hrfs ------

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


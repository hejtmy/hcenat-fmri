SHIFT_INTERVAL <- c(-6, 6)
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

## Visually compare
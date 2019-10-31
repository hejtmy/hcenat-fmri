library(data.table)
library(navr)
library(dplyr)
library(ez)
sapply(list.files("functions", full.names = T, recursive = T), source)
CORRECT_ANGLES <- read.table("data/correct-angles.csv", sep=",", header=TRUE)

data_dir <- "E:/OneDrive/NUDZ/projects/HCENAT/Data/"
img_path <- "images/megamap5.png"

df_preprocessing <- load_participant_preprocessing_status()

## Unity loading -----
participants <- load_participants(data_dir, df_preprocessing = df_preprocessing, sessions = 1)
participants <- add_pulses.participants(participants)

## MRI loading ------
folder <- file.path(data_dir, "../MRI-data-tomecek/filtered")
names_file <- file.path(data_dir, "../MRI-data-tomecek/subs_20190830_1422.txt")
components <- load_mri(folder, names_file)
components <- rename_mri_participants(components, df_preprocessing)
fmri <- restructure_mri(components)

## Analysis ----
df_pointing <- pointing_results.participants(participants)

## fmri analysis ----
component_names <- c("filt_cen_11", "filt_cen_16", "filt_cen_23", "filt_cen_37", 
                     "filt_cen_39", "filt_cen_46", "filt_dmn_2", "filt_dmn_51", 
                     "filt_dmn_52","filt_hpc_12", "filt_hpc_54", "filt_hpc_56", 
                     "filt_mot_33", "filt_sn_31",  "filt_sn_8", "filt_unk_10", 
                     "filt_vis_4", "filt_vis_43")

### pointing ----
pointing_pulses <- create_pointing_pulses_table(df_pointing)
pointing_fmri <- get_fmri(fmri, pointing_pulses)

head(pointing_fmri)
ezANOVA(pointing_fmri,
        dv = "filt_cen_16",
        wid = participant,
        within = correct)

ggplot(pointing_fmri, aes(participant, filt_cen_11, fill=correct)) + geom_boxplot()

pointing_long <- reshape2::melt(pointing_fmri, id.vars=c("pulse_id", "participant", "correct", "session"))
ggplot(pointing_long, aes(variable, value, fill=correct)) + geom_boxplot()

### movement ----
movement_pulses <- create_movement_stop_pulses_table(participants, 3,0.2,3)
movement_fmri <- get_fmri(fmri, movement_pulses)
head(movement_fmri)
ggplot(movement_fmri, aes(movement_type, filt_cen_11, fill=movement_type)) + geom_boxplot()

movement_long <- reshape2::melt(movement_fmri, id.vars=c("pulse_id", "participant", "movement_type", "session"))
ggplot(movement_long, aes(variable, value, fill=movement_type)) + geom_boxplot()

#libraries in correct order
library('R6')
library('data.table')
library('dplyr')
library('stringr')
library('ggplot2')

data_dir <- "M:/OneDrive/NUDZ/HCENAT/Data/"

subject_table <- read.table(paste(data_dir, "ListOfSubjects.csv", sep = ""), sep = ",", 
                           header = T, stringsAsFactors = F, na.strings = c(""))

SESSION <- 1
subject_table <- subject_table[c(16, 18), ]
source('scripts/loading.r')
# loads from the subjectList table
# dir = dir of all data
# paritcipatn code = code overall
# session = session
subject_code <- subject_table[1, "ID"]
session_code <- subject_table[1, "VR_MRI_1"]
subject_dir <- paste0(data_dir, subject_code, "/MRI/", "Session1/")

ls <- read_unity_data(subject_dir)
quests_set <- df_quests_info(ls[[1]]$quests_logs)
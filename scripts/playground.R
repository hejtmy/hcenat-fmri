library(data.table)
sapply(list.files("functions", full.names = T, recursive = T), source)

folder <- "F:/projects/hcenat/Data/HCE_E_1/MRI/Session1"
ls <- read_unity_data(folder)

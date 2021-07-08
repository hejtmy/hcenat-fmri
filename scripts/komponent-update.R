library(googlesheets4)
library(tidyverse)

df_components <- read_sheet("https://docs.google.com/spreadsheets/d/1wRhS7LCDq36QnzJPmKf8iarVa4gkXm-U7TGpGeWv90s")

df_out <- select(df_components, component=komponenta, component_notes=notes,
                 component_label=name)


write.table(df_out, "data/komponenty.txt", sep=";", row.names = FALSE)

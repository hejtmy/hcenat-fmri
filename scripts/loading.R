source_folder <- function(path){
  sapply(list.files(pattern = "[.]R$", path = path,
                    full.names = TRUE, recursive = TRUE),
         source);
}
source_folder("functions/")
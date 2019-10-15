preprocess_player_log <- function(position_tab){
  if (!("Position.x" %in% colnames(position_tab))){
    position_tab <- vector3_to_columns(position_tab, "Position")
  }
  if (!("cumulative_distance" %in% colnames(position_tab))){
    position_tab <- add_distance_walked(position_tab)
  } 
}

#turns vector columns in string "(x, y, z)" into three columns(Position.x, Position.y, Position.z) and returns the table
vector3_to_columns <- function(tab, column_name){
  xyz <- c("x","y","z")
  splitted <- strsplit(substring(tab[,get(column_name)], 2, nchar(tab[, get(column_name)]) - 1), ",")
  #turns the Vector3 into lists of 3 values
  i <- 1
  for (letter in xyz){
    new_name <- paste(column_name,letter,sep=".")
    tab[,(new_name) := as.numeric(sapply(splitted,"[", i))]
    i <- i + 1
  }
  return(tab)
}

#calculates the distance walked between each two points of the position table and returns the table
add_distance_walked <- function(position_table){
  distances <- numeric(0)
  for (i in 2:nrow(position_table)){
    position_table[c(i - 1, i),distance := EuclidDistanceColumns(.(Position.x, Position.z)[1], .(Position.x, Position.z)[2])]
    #distances = c(distances,EuclidDistance(position_table[i,list(Position.x,Position.z)],position_table[i-1,list(Position.x,Position.z)]))
  }
  position_table[, cumulative_distance := cumsum(distance)]
  return(position_table)
}

euclid_distance_columns <- function(x_values,y_values){
  if(is.list(x_values)){
    x <- c(x_values[[1]][1], y_values[[1]][1])
    y <- c(x_values[[1]][2], y_values[[1]][2])
  }
  #TODO - this is rubbish-basically it depends on which fnction it calls it and what input it passes
  if (is.numeric(x_values) && is.numeric(y_values)){ 
    x <- c(x_values[1], x_values[2])
    y <- c(y_values[1], y_values[2])
  }
  if(is.null(x) || is.null(y)) return(NA)
  return(sqrt(sum((x-y)^2)))
}
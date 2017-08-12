library("TSP")
dist <- read.csv("/tmp/dist.csv",header=F)
row.names(dist) <- names(dist)
tsp <- TSP(as.matrix(dist))
tour <- solve_TSP(tsp)
cat(labels(tour))


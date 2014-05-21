
# Selection variable à estimer
data <- select.final.variable(data, y.letter)

# Cluster 3
data <- subset(data, cluster_number == "3")
data <- data[, colnames(data) != "cluster_number"]

# Separation train, test
set.seed(seed.value)
tmp <- get.base.train.test(data, y.variable, percent.train)

dataTrainBase <- tmp$train
dataTest <- tmp$test

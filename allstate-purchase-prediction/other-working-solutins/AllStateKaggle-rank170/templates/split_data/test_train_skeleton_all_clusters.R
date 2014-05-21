
# Selection variable à estimer
data <- select.final.variable(train.data, y.letter)

# Separation train, test
set.seed(seed.value)
tmp <- get.base.train.test(data, y.variable, percent.train)

dataTrainBase <- tmp$train
dataTest <- tmp$test

#!/usr/bin/Rscript

# makes the random forest submission

library(randomForest)

train <- read.csv("../kgg/train.csv", header=TRUE)
test <- read.csv("../kgg/test.csv", header=TRUE)

labels <- as.factor(train[,1])
train <- train[,-1]

rf <- randomForest(train, labels, xtest=test, ntree=1000)
predictions <- levels(labels)[rf$test$predicted]

write(predictions, file="rf_benchmark.csv", ncolumns=1) 

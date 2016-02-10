#Model Stacking - Blending for HQC Kaggle
# Models bagged: xgboost, gbm, rf, treebag etc

setwd("C:/Ahmed/ML/Kag2016/Homesite Quote Conversion/")
getwd()

library(readr)
library(xgboost)
library(caret)
library(pROC)

##########Initial Legwork
set.seed(1718)

cat("reading the train and test data\n")
train <- read_csv("./train.csv")
test  <- read_csv("./test.csv")

mytrain <- train
mytest <- test

# There are some NAs in the integer columns so conversion to zero
#getback train and test
#train <- mytrain
#test <- mytest

#missingCount
train$missCount <- rowSums(is.na(train))
test$missCount <- rowSums(is.na(test))

#set missing to -1, as done in other columns
train[is.na(train)]   <- -1
test[is.na(test)]   <- -1

#Zerocounts
train$zeros <- rowSums(train==0)
test$zeros <- rowSums(test==0)


cat("train data column names and details\n")
names(train)
#str(train)
#summary(train)
cat("test data column names and details\n")
names(test)
#str(test)
#summary(test)


# seperating out the elements of the date column for the train set
train$month <- as.integer(format(train$Original_Quote_Date, "%m"))
train$year <- as.integer(format(train$Original_Quote_Date, "%y"))
train$day <- weekdays(as.Date(train$Original_Quote_Date))

# removing the date column
train <- train[,-c(2)]

# seperating out the elements of the date column for the train set
test$month <- as.integer(format(test$Original_Quote_Date, "%m"))
test$year <- as.integer(format(test$Original_Quote_Date, "%y"))
test$day <- weekdays(as.Date(test$Original_Quote_Date))

# removing the date column
test <- test[,-c(2)]


feature.names <- names(train)[c(3:303)]
cat("Feature Names\n")
#feature.names

cat("assuming text variables are categorical & replacing them with numeric ids\n")
for (f in feature.names) {
  if (class(train[[f]])=="character") {
    levels <- unique(c(train[[f]], test[[f]]))
    train[[f]] <- as.integer(factor(train[[f]], levels=levels))
    test[[f]]  <- as.integer(factor(test[[f]],  levels=levels))
  }
}

#########Factor target for Conversion Flag
train$target <- as.factor(ifelse(train$QuoteConversion_Flag==0,
                                 "No","Yes"))
#backup train and test data
bak_train <- train
bak_test  <- test
#####################################
######## 50k data for Ensemble 
######## 50k data for Blending
######## 50k data for testing
#####################################
set.seed(8189)
#shuffle training data
train <- train[sample(nrow(train)),]

bucketSize <- 7000
ensembleData <- train[0:bucketSize,]
blenderData  <- train[(bucketSize+1):(bucketSize*2),]
testingData  <- train[(bucketSize*2+1):(bucketSize*3),]

# blenderData  <- train[150001:220000,]
# testingData  <- train[220001:260753,]

#check proportions in each category
prop.table(table(ensembleData$QuoteConversion_Flag))
prop.table(table(blenderData$QuoteConversion_Flag))
prop.table(table(testingData$QuoteConversion_Flag))

####################check for a single model first: Xgboost
#train on blenderDAta 
fitControl <- trainControl(## 10-fold CV
  method = "cv",
  number = 3,
  summaryFunction = twoClassSummary, 
  classProbs = TRUE
  ## repeated ten times
  #repeats = 10
)

xgbGrid <-  expand.grid(max_depth = c(6),
                        nrounds = c(2000),
                        eta = c(.02))

system.time(base_xgb <- train(target ~ ., 
                               data = blenderData[,c(3:304)],  #including target factor
                               method = "xgbTree",
                               trControl = fitControl,
                               verbose = 1,
                               metric = "ROC",
                               #preProc = c("center", "scale")
                               ## Now specify the exact models 
                               ## to evaluate:
                               tuneGrid = xgbGrid
                               #tuneLength = 3                
)
)


#predict on testData

preds <- predict(object=base_xgb, 
                 type='prob',
                 testingData[,c(3:303)])

auc <- roc(testingData$QuoteConversion_Flag, preds$Yes)
print(auc$auc)
#Single model score: .965
#> print(auc$auc)
#Area under the curve: 0.965
##########Lets ensemble and see how much we can improve
###########################Model-1:Xgboost

fitControl <- trainControl(## 10-fold CV
  method = "cv",
  number = 3,
  summaryFunction = twoClassSummary, 
  classProbs = TRUE
  ## repeated ten times
  #repeats = 10
)

xgbGrid <-  expand.grid(max_depth = c(6),
                        nrounds = c(3000),
                        eta = c(.02))

system.time(model_xgb <- train(target ~ ., 
                            data = ensembleData[,c(3:304)],  #including target factor
                            method = "xgbTree",
                            trControl = fitControl,
                            verbose = 1,
                            metric = "ROC",
                            #preProc = c("center", "scale")
                            ## Now specify the exact models 
                            ## to evaluate:
                            tuneGrid = xgbGrid
                            #tuneLength = 3                
)
)

# xgbFit
# plot(xgbFit)
# varImp(xgbFit)


##############Model 2: RF
fitControl <- trainControl(## 10-fold CV
  method = "cv",
  number = 3,
  summaryFunction = twoClassSummary, 
  classProbs = TRUE
  ## repeated ten times
  #repeats = 10
)

rfGrid <-  expand.grid(mtry = c(30))


system.time(model_rf <- train(target ~ ., 
                           data = ensembleData[,c(3:304)],
                           method = "rf",
                           trControl = fitControl,
                           #do.trace = T,
                           metric = "ROC",
                           ntree = 600,
                           #preProc = c("center", "scale")
                           ## Now specify the exact models 
                           ## to evaluate:
                           tuneGrid = rfGrid
                           #tuneLength = 3                
)
)

# rfFit
# plot(rfFit)
# 
# varImp(rfFit)

#########################Model-3:gbm
fitControl <- trainControl(## 10-fold CV
  method = "cv",
  number = 3,
  summaryFunction = twoClassSummary, 
  classProbs = TRUE
  ## repeated ten times
  #repeats = 10
)

gbmGrid <-  expand.grid(interaction.depth = c(6),
                        #n.trees = c(1000,1500,2000,3000,4000),
                        n.trees = c(2000),
                        shrinkage = 0.02,
                        n.minobsinnode = 10)
system.time(model_gbm <- train(target ~ ., 
                            data = ensembleData[,c(3:304)],
                            method = "gbm",
                            trControl = fitControl,
                            verbose = F,
                            metric = "ROC",
                            #preProc = c("center", "scale"),
                            ## Now specify the exact models 
                            ## to evaluate:
                            tuneGrid = gbmGrid)
)

# plot(gbmFit)
# 
# gbmFit

###################Model-4:Logistic Regression
fitControl <- trainControl(## 10-fold CV
  method = "cv",
  number = 3,
  summaryFunction = twoClassSummary, 
  classProbs = TRUE
  ## repeated ten times
  #repeats = 10
)

system.time(model_glm <- train(target ~ ., 
                               data = ensembleData[,c(3:304)],
                               method = "glm",
                               family = "binomial",
                               trControl = fitControl,
                               #verbose = T,
                               metric = "ROC",
                               preProc = c("center", "scale")
                               ## Now specify the exact models 
                               ## to evaluate:
                               #tuneGrid = gbmGrid)
))
model_glm

# plot(model_glm)
# Predict on testingDAta
preds <- predict(object=model_glm, 
                 type='prob',
                 newdata=testingData[,c(3:303)])

#get AUC score
roc <- roc(testingData$QuoteConversion_Flag, preds$Yes)
print(roc$auc)

###########Ensemble of all 3
#######Predict on Blenderdata
#predicts <- ???

blenderData$gbm_PROB <- predict(object=model_gbm, 
                                blenderData[,c(3:303)])
blenderData$rf_PROB <- predict(object=model_rf, 
                               blenderData[,c(3:303)])
blenderData$xgb_PROB <- predict(object=model_xgb, 
                                    blenderData[,c(3:303)])
blenderData$glm_PROB <- predict(object=model_glm, 
                                blenderData[,c(3:303)])


#
testingData$gbm_PROB <- predict(object=model_gbm, 
                                testingData[,c(3:303)])
testingData$rf_PROB <- predict(object=model_rf, 
                                testingData[,c(3:303)])
testingData$xgb_PROB <- predict(object=model_xgb, 
                                testingData[,c(3:303)])
testingData$glm_PROB <- predict(object=model_glm, 
                                testingData[,c(3:303)])



#########Final  Blended model
#predictors <- names(blenderData)[names(blenderData) != labelName]
#this includes "target" column
xgbGrid <-  expand.grid(max_depth = c(6),
                        nrounds = c(3000),
                        eta = c(.02))

final_blender_model <- train(target~. , 
                             data=blenderData[,c(3:303,304,305:308)], 
                             method='xgbTree',
                             tuneGrid = xgbGrid,
                             trControl=fitControl)


#predict on testingData
preds <- predict(object=final_blender_model, 
                 type='prob',
                 testingData[,c(3:303,305:308)])

#get AUC, by selecting 
auc <- roc(testingData$QuoteConversion_Flag, preds$Yes)
print(auc$auc)

#> print(auc$auc) # for gbm
#Area under the curve: 0.9554

# AUC for final xgbTree model
# > print(auc$auc)
# Area under the curve: 0.964
# >
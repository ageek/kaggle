# xgb_cv_baseline

setwd("/home/topo/ghub/kaggle/kaggle-2016/homesite-quote-conversion")
getwd()

library(readr)
library(xgboost)
# Parallel on Linux
require(doMC)
registerDoMC(cores=4)

#my favorite seed - Ramanujan Number
set.seed(1729)

cat("reading the train and test data\n")
train <- read_csv("./train.csv")
test  <- read_csv("./test.csv")

# There are some NAs in the integer columns so conversion to zero
train[is.na(train)]   <- 0
test[is.na(test)]   <- 0

#drop 2 constant columns
train$PropertyField6 <- NULL
train$GeographicField10A <- NULL

test$PropertyField6 <- NULL
test$GeographicField10A <- NULL

cat("train data column names and details\n")
names(train)
str(train)
#summary(train)
cat("test data column names and details\n")
names(test)
str(test)
#summary(test)


# seperating out the elements of the date column for the train set
train$month <- as.integer(format(train$Original_Quote_Date, "%m"))
train$year <- as.integer(format(train$Original_Quote_Date, "%y"))
train$day <- weekdays(as.Date(train$Original_Quote_Date))
train$Q <- quarters(as.Date(train$Original_Quote_Date))

# removing the date column
train <- train[,-c(2)]

# seperating out the elements of the date column for the train set
test$month <- as.integer(format(test$Original_Quote_Date, "%m"))
test$year <- as.integer(format(test$Original_Quote_Date, "%y"))
test$day <- weekdays(as.Date(test$Original_Quote_Date))
test$Q <- quarters(as.Date(test$Original_Quote_Date))
# removing the date column
test <- test[,-c(2)]


feature.names <- names(train)[c(3:300)]
cat("Feature Names\n")
feature.names

cat("assuming text variables are categorical & replacing them with numeric ids\n")
for (f in feature.names) {
  if (class(train[[f]])=="character") {
    levels <- unique(c(train[[f]], test[[f]]))
    train[[f]] <- as.integer(factor(train[[f]], levels=levels))
    test[[f]]  <- as.integer(factor(test[[f]],  levels=levels))
  }
}

cat("train data column names after slight feature engineering\n")
names(train)
cat("test data column names after slight feature engineering\n")
names(test)
tra<-train[,feature.names]

nrow(train)
set.seed(1729)
#set aside 50k for c
#h<-sample(nrow(train),50000)

#test data
#dval<-xgb.DMatrix(data=data.matrix(tra[h,]),
#                  label=train$QuoteConversion_Flag[h])

#train data
#dtrain<-xgb.DMatrix(data=data.matrix(tra[-h,]),
#                    label=train$QuoteConversion_Flag[-h])

#Use full data and let CV folds take care of validation data creation
dtrain<-xgb.DMatrix(data=data.matrix(tra),
                    label=train$QuoteConversion_Flag)

#watchlist <- list(test=dval,train=dtrain)

#param is basic/default only
param <- list(  objective           = "binary:logistic", 
                booster = "gbtree",
                eval_metric = "auc",
                eta                 = 0.01, #0.023, # 0.06, #0.01,
                max_depth           = 6, #changed from default of 8
                subsample           = 0.83, # 0.7
                colsample_bytree    = 0.9, # 0.7
                min_child_weight    = 3
)

# 4 fold CV
# set random seed, for reproducibility 
set.seed(1729)
# cross validation, with timing
nround.cv = 6000
system.time(bst.cv <- xgb.cv(param=param, 
                             data=dtrain, 
                             nfold=5,
                             print.every.n=10,
                             nrounds=nround.cv, 
                             prediction=TRUE, 
                             verbose=T))

# index of max AUC score
max.auc.idx = which.max(bst.cv$dt[, test.auc.mean]) 
max.auc.idx 

bst.cv$dt[max.auc.idx,]
#train.auc.mean train.auc.std test.auc.mean test.auc.std
#1:       0.979422      0.000495      0.964986     0.000835

# clf <- xgb.train(   params              = param, 
#                     data                = dtrain, 
#                     nrounds             = 1500, 
#                     verbose             = 1,  #1
#                     #early.stop.round    = 150,
#                     watchlist           = watchlist,
#                     maximize            = FALSE
# )
save(bst.cv, file="./xgb_cv_baseline_1.rda")
pred1 <- predict(bst.cv, data.matrix(test[,feature.names]))
submission <- data.frame(QuoteNumber=test$QuoteNumber, 
                         QuoteConversion_Flag=pred1)

cat("saving the submission file\n")
write_csv(submission, "xgb_stop_1_50k-validation_1.csv")

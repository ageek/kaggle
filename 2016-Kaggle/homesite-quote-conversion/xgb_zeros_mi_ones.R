# with zeros and minus-ones counts new columns added

# HQC kaggle challenge
# /home/topo/ghub/kaggle/kaggle-2016/homesite-quote-conversion

setwd("/home/topo/ghub/kaggle/kaggle-2016/homesite-quote-conversion")
getwd()
# Based on Ben Hamner script from Springleaf
# https://www.kaggle.com/benhamner/springleaf-marketing-response/random-forest-example

library(readr)
library(xgboost)

# Parallel on Linux
require(doMC)
registerDoMC(cores=4)

# my favorite seed - Ramanujan Number
# https://en.wikipedia.org/wiki/1729_%28number%29
set.seed(1729)

cat("reading the train and test data\n")
train <- read_csv("./train.csv")
test  <- read_csv("./test.csv")

### in train data
#In PersonalField84 and PropertyField29 , set NAs to -1
table(train$PersonalField84, exclude = NULL)
train$PersonalField84[is.na(train$PersonalField84)] <- -1
#recheck 
table(train$PersonalField84, exclude = NULL)

table(train$PropertyField29, exclude = NULL)
train$PropertyField29[is.na(train$PropertyField29)] <- -1
#recheck after conversion
table(train$PropertyField29, exclude = NULL)


### in test data
table(test$PersonalField84, exclude = NULL)
test$PersonalField84[is.na(test$PersonalField84)] <- -1
#recheck 
table(test$PersonalField84, exclude = NULL)

table(test$PropertyField29, exclude = NULL)
test$PropertyField29[is.na(test$PropertyField29)] <- -1
#recheck after conversion
table(test$PropertyField29, exclude = NULL)

###
# There are some NAs in the integer columns so convet to zero
train[is.na(train)]   <- -1
test[is.na(test)]   <- -1

### for train data
#count zeros and assing to new column
head(rowSums(train==0))

#cross check
table(train[1,]==0)

table(train[5,]==0)

train$zeroes <- rowSums(train==0)
head(train$zeroes)

#count -1s and assing to new column
head(rowSums(train==-1))

#cross check
table(train[1,]==-1)

table(train[5,]==-1)

train$ones <- rowSums(train==-1)
head(train$ones)
train$zeroes <- as.integer(train$zeroes)
train$ones <- as.integer(train$ones)

## repeat for test
dim(test)
table(test[1,]==0)

test$zeroes <- rowSums(test==0)
head(test$zeroes)

#every row has some 0s and some -1s
length(rowSums(test==-1))

test$ones <- rowSums(test==-1)
head(test$ones)
table(test[1,]==-1)

test$zeroes <- as.integer(test$zeroes)
test$ones <- as.integer(test$ones)

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
#train <- train[,-c(2)]

# seperating out the elements of the date column for the train set
test$month <- as.integer(format(test$Original_Quote_Date, "%m"))
test$year <- as.integer(format(test$Original_Quote_Date, "%y"))
test$day <- weekdays(as.Date(test$Original_Quote_Date))

# removing the date column
#test <- test[,-c(2)]

# # drop the 2 columns, which are constant
# colCount_train <- sapply(train, function(x) length(unique(x)))
# names(train[,which(colCount_train==1)])
# 
# train$PropertyField6 <- NULL
# train$GeographicField10A <- NULL
# 
# dim(train)
# 
# 
# colCount_test <- sapply(test, function(x) length(unique(x)))
# names(test[,which(colCount_test==1)])
# test$PropertyField6 <- NULL
# test$GeographicField10A <- NULL
# dim(test)
# 

# 2 more + 301 -2 removed = 301
#date col is not removed, so start from 4
feature.names <- names(train)[c(4:303)]
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

set.seed(1729)
nrow(train)
h<-sample(nrow(train),50000)

dval<-xgb.DMatrix(data=data.matrix(tra[h,]),
                  label=train$QuoteConversion_Flag[h])
#dtrain<-xgb.DMatrix(data=data.matrix(tra[-h,]),
#                 label=train$QuoteConversion_Flag[-h])
dtrain<-xgb.DMatrix(data=data.matrix(tra),
                    label=train$QuoteConversion_Flag)

watchlist <- list(val=dval,train=dtrain)

param <- list(  objective           = "binary:logistic", 
                booster = "gbtree",
                eval_metric = "auc",
                eta                 = 0.023, # 0.06, #0.01,
                max_depth           = 6, #changed from default of 8
                subsample           = 0.83, # 0.7
                colsample_bytree    = 0.77 # 0.7
                #num_parallel_tree   = 2
)

clf <- xgb.train(   params              = param, 
                    data                = dtrain, 
                    nrounds             = 1800, 
                    print.every.n       = 5,
                    verbose             = 1,  #1
                    #early.stop.round    = 150,
                    watchlist           = watchlist,
                    maximize            = FALSE
)

save(clf, file="./xgb_zeros_mi_ones_fulldata_training.rda")

pred1 <- predict(clf, data.matrix(test[,feature.names]))
submission <- data.frame(QuoteNumber=test$QuoteNumber, 
                         QuoteConversion_Flag=pred1)

cat("saving the submission file\n")
write_csv(submission, "xgb_zeros_mi_ones_fulldata_training_1.csv")
#gives LB score: 0.94562



# HQC kaggle challenge
# /home/topo/ghub/kaggle/kaggle-2016/homesite-quote-conversion
# ref : https://www.kaggle.com/sushize/homesite-quote-conversion/xgb-stop/run/104408/code
# LB score: .96817 AUC

setwd("/home/topo/ghub/kaggle/kaggle-2016/homesite-quote-conversion")
getwd()
library(readr)
library(xgboost)

#my favorite seed^^
set.seed(1718)

cat("reading the train and test data\n")
train <- read_csv("./train.csv")
test  <- read_csv("./test.csv")

# There are some NAs in the integer columns so conversion to zero
train[is.na(train)]   <- 0
test[is.na(test)]   <- 0

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

# removing the date column
train <- train[,-c(2)]

# seperating out the elements of the date column for the train set
test$month <- as.integer(format(test$Original_Quote_Date, "%m"))
test$year <- as.integer(format(test$Original_Quote_Date, "%y"))
test$day <- weekdays(as.Date(test$Original_Quote_Date))

# removing the date column
test <- test[,-c(2)]


feature.names <- names(train)[c(3:301)]
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
#validation lengh changed from 20k to 80k, but from train data only
h<-sample(nrow(train),80000)

dval<-xgb.DMatrix(data=data.matrix(tra[h,]),
                  label=train$QuoteConversion_Flag[h])
#dtrain<-xgb.DMatrix(data=data.matrix(tra[-h,]),label=train$QuoteConversion_Flag[-h])
dtrain<-xgb.DMatrix(data=data.matrix(tra),
                    label=train$QuoteConversion_Flag)

watchlist<-list(val=dval,train=dtrain)
param <- list(  objective           = "binary:logistic", 
                booster = "gbtree",
                eval_metric = "auc",
                eta                 = 0.023, # 0.06, #0.01,
                max_depth           = 6, #changed from default of 8
                subsample           = 0.83, # 0.7
                colsample_bytree    = 0.77 # 0.7
                #num_parallel_tree   = 2
                # alpha = 0.0001, 
                # lambda = 1
)

system.time(clf <- xgb.train(   params              = param, 
                    data                = dtrain, 
                    nrounds             = 1800, 
                    verbose             = 1,  #1
                    print.every.n       =10,
                    #early.stop.round    = 150,
                    #watchlist           = watchlist,
                    maximize            = FALSE
  )
)

#save the base model
save(clf, file="xgb_Shize_stop_3_base_for_96817_AUC.rda")

pred1 <- predict(clf, data.matrix(test[,feature.names]))
submission <- data.frame(QuoteNumber=test$QuoteNumber, 
                         QuoteConversion_Flag=pred1)
cat("saving the submission file\n")
write_csv(submission, "xgb_Shize_stop_3_base_for_96817_AUC.csv")

# LB score: .96802
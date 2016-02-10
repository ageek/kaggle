# add t-sne features to HQC kaggle
setwd("C:/Ahmed/ML/Kag2016/Homesite Quote Conversion/")
getwd()

library(Rtsne)
library(readr)
library(xgboost)
# Parallel on Linux
#require(doMC)
#registerDoMC(cores=4)


#my favorite seed^^
set.seed(1718)

cat("reading the train and test data\n")
train <- read_csv("./train.csv")
test  <- read_csv("./test.csv")

# There are some NAs in the integer columns so conversion to zero
train[is.na(train)]   <- 0
test[is.na(test)]   <- 0


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

#map train data from 299 dimensions to 2D using tsne
set.seed(1729)
#should combine train and test and then do tsne mapping

x <- rbind(train[,feature.names], test[,feature.names])
x <- as.matrix(x)
# tsne mapping for just train data took ~ 3hrs
system.time(tsne_out <- Rtsne(x, theta = 0.5, perplexity = 30))

save(tsne_out, file="./tsne_full_data.rda")

#add the new 2 features from tsne_out to tra
tra$tsne1 <- tsne_out$Y[,1]
tra$tsne2 <- tsne_out$Y[,2]


nrow(train)
set.seed(1718)
h<-sample(nrow(train),50000)

dval<-xgb.DMatrix(data=data.matrix(tra[h,]),
                  label=train$QuoteConversion_Flag[h])
dtrain<-xgb.DMatrix(data=data.matrix(tra[-h,]),
                    label=train$QuoteConversion_Flag[-h])
#dtrain<-xgb.DMatrix(data=data.matrix(tra),
#                    label=train$QuoteConversion_Flag)

watchlist <- list(val=dval,train=dtrain)
param <- list(  objective         = "binary:logistic", 
                booster           = "gbtree",
                eval_metric       = "auc",
                eta                  = 0.025, # 0.06, #0.01,
                max_depth           = 6, #changed from default of 8
                subsample           = 0.83, # 0.83, # 0.7
                colsample_bytree    = 0.9, # 0.7
                min_child_weight    = 10,
                max_delta_step     = 2,
                gamma = 0.1 
)

system.time(clf <- xgb.train(   params              = param, 
                                data                = dtrain, 
                                nrounds             = 3000, 
                                verbose             = 1,  #1
                                #early.stop.round    = 150,
                                print.every.n       = 10,
                                watchlist           = watchlist,
                                maximize            = FALSE
)
)

save(clf, file="")

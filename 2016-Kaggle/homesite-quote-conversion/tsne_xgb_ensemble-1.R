## add t-sne features to HQC kaggle
setwd("/home/topo/ghub/kaggle/kaggle-2016/homesite-quote-conversion")
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
set.seed(1718)
#should combine train and test and then do tsne mapping

x <- rbind(train[,feature.names], test[,feature.names])
x <- as.matrix(x)
# tsne mapping for just train data took ~ 3hrs
system.time(tsne_out <- Rtsne(x, 
                              theta = 0.5, 
                              perplexity = 30,
                              verbose = T))

save(tsne_out, file="./tsne_full_data_NA_as_0.rda")
# load tsne saved data
load(file = "./tsne_full_data_NA_as_0.rda")

# > length(tsne_out$Y[, 2])
# [1] 434589
# > length(tsne_out$Y[, 1])
# [1] 434589
trainSize <- dim(train[1])[1]

#add the new 2 features from tsne_out to train data, onto 2 new columns
#tsne1 and tsne2
tra$tsne1 <- tsne_out$Y[1:trainSize,1]
tra$tsne2 <- tsne_out$Y[1:trainSize,2]

#add the tsne test mappings to test data
test$tsne1 <- tsne_out$Y[(trainSize+1):length(tsne_out$Y[,1]), 1]
test$tsne2 <- tsne_out$Y[(trainSize+1):length(tsne_out$Y[,2]), 2]

# adjust feature.names to include tsne1 and tsne2

feature.names <- names(tra)

#continue with old process

h<-sample(nrow(train),50000)

dval<-xgb.DMatrix(data=data.matrix(tra[h,]),
                  label=train$QuoteConversion_Flag[h])
dtrain<-xgb.DMatrix(data=data.matrix(tra[-h,]),
                    label=train$QuoteConversion_Flag[-h])
#dtrain<-xgb.DMatrix(data=data.matrix(tra),
#                    label=train$QuoteConversion_Flag)

watchlist<-list(val=dval,train=dtrain)
param <- list(  objective           = "binary:logistic", 
                booster = "gbtree",
                eval_metric = "auc",
                eta                 = 0.025, # 0.06, #0.01,
                max_depth           = 6, #changed from default of 8
                subsample           = 0.75, # 0.7
                colsample_bytree    = 0.75, # 0.7
                gamma               = 1
                #num_parallel_tree   = 2
                # alpha = 0.0001, 
                # lambda = 1
)

system.time(clf <- xgb.train(   params              = param, 
                                data                = dtrain, 
                                nrounds             = 2000, 
                                verbose             = 1,  #1
                                print.every.n       = 10,
                                #early.stop.round    = 100,
                                watchlist           = watchlist,
                                maximize            = FALSE
)
)

#save the base model
save(clf, file="xgb_tsne_NA_as_0_added_6krnds.rda")

pred1 <- predict(clf, data.matrix(test[,feature.names]))
submission <- data.frame(QuoteNumber=test$QuoteNumber, 
                         QuoteConversion_Flag=pred1)
cat("saving the submission file\n")
write_csv(submission, "xgb_tsne_NA_as_0_added-2.csv")

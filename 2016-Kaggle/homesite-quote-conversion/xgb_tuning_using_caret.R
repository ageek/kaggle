# Xgb param Tuning using Caret

setwd("/home/topo/ghub/kaggle/kaggle-2016/homesite-quote-conversion")
getwd()
library(readr)
library(xgboost)
require(caret)

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

#use xgbTree in caret

set.seed(825)
#pick only 5k train data
trIndex <- sample(dim(train)[1], 50000, replace = F)

train$target <- as.factor(ifelse(train$QuoteConversion_Flag==0,
                                 "No","Yes"))
#check ratio, and compare with full data
prop.table(table(train[trIndex,]$target))
prop.table(table(train$target))


fitControl <- trainControl(## 10-fold CV
  method = "cv",
  number = 3,
  summaryFunction = twoClassSummary, 
  classProbs = TRUE
  ## repeated ten times
  #repeats = 10
)

xgbGrid <-  expand.grid(max_depth = 6,
                        nrounds = c(1500,1800,2200,2600,3000),
                        eta = c(.005),
                        gamma = 1, 
                        colsample_bytree = .8,
                        min_child_weight = c(8,10))

system.time(xgbFit <- train(target ~ ., 
                            data = train[trIndex,c(3:302)],
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
# user   system  elapsed 
# 3691.992    1.276  949.822

xgbFit

# eta   nrounds  ROC        Sens       Spec       ROC SD        Sens SD    
# 0.01  1500     0.9617251  0.9822524  0.6768516  0.0003758434  0.001284439
# 0.01  1800     0.9616328  0.9814178  0.6793347  0.0002799626  0.001702709
# 0.02  1500     0.9612488  0.9789877  0.6844099  0.0003861742  0.001702765
# 0.02  1800     0.9610336  0.9784231  0.6867851  0.0004585699  0.002105378

plot(xgbFit)
varImp(xgbFit)

plot(head(varImp(xgbFit, scale=F),30))

# xgbTree variable importance
# 
# only 20 most important variables shown (out of 254)
# 
# Overall
# PropertyField37  100.000
# SalesField5       71.903
# PersonalField9    40.240
# Field7            17.507
# PersonalField2    15.848
# PersonalField1    12.839
# SalesField4       10.102
# SalesField1B       9.378
# PersonalField10A   8.198
# SalesField1A       8.079
# PersonalField10B   5.486
# PropertyField34    3.875
# PersonalField12    3.601
# PersonalField26    2.756
# PersonalField13    2.176
# PersonalField4A    2.166
# PersonalField27    2.015
# PersonalField82    1.920
# CoverageField8     1.619
# PersonalField84    1.618
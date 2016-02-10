##t-SNE for top 20/30 features selected by xgboost , rf varImp() etc

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
##############
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
                              data = train[1:80000,c(3:304)],  #including target factor
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

base_xgb
xgb_imp <- varImp(base_xgb)
plot(base_xgb)
#Extract top 30 features for tSNE mapping
# > tt <- data.frame(Field=rownames(xgb_imp$importance), Value=xgb_imp$importance$Overall)
# > head(tt)
# Field     Value
# 1 PropertyField37 100.00000
# 2     SalesField5  82.85046
# 3  PersonalField9  55.87153
# 4           zeros  42.45390
# 5 PropertyField29  27.90825
# 6  PersonalField2  22.02065
# > 
top30Features <- as.character(head(tt$Field, 25))

###################tSNE mapping from ~30 to 2
require(Rtsne)
set.seed(1729)
#should combine train and test and then do tsne mapping
x <- rbind(train[,top30Features], test[,top30Features])
x <- as.matrix(x)

# tsne mapping for just train data took ~ 3hrs
system.time(tsne_out <- Rtsne(x, 
                              theta = 0.5, 
                              perplexity = 20,
                              max_iter = 500,
                              verbose = T,
                              check_duplicates = F))

save(tsne_out, file="./tsne_25_varImp_xgb_data.rda")

###add the new 2 features from tsne_out to train & test
train$tsne1 <- tsne_out$Y[1:dim(train)[1],1]
train$tsne2 <- tsne_out$Y[1:dim(train)[1],2]

###test
test$tsne1 <- tsne_out$Y[(1+dim(train)[1]):dim(tsne_out$Y)[1],1]
test$tsne2 <- tsne_out$Y[(1+dim(train)[1]):dim(tsne_out$Y)[1],2]

#########Plot tsne out to see whats the output looks like
require(ggplot2)
plotdata <- train[,c(2,305,306)]
ggplot(plotdata, aes(x=tsne1, y=tsne2, 
                     color=as.factor(QuoteConversion_Flag)))+
  geom_point()

# From the plot, it looks like we need more feaures than 25 and/or
# do tsne mapping from whole data, instead of a small chunk 
# that we used

###############################
# Now lets re-run the xgb and see the feature importance of tsne1and 
# their contribution to overall AUC score

fitControl <- trainControl(## 10-fold CV
  method = "cv",
  number = 3,
  summaryFunction = twoClassSummary, 
  classProbs = TRUE
  ## repeated ten times
  #repeats = 10
)

xgbGrid <-  expand.grid(max_depth = c(6),
                        nrounds = c(2000, 3000),
                        eta = c(.02))

system.time(tsne_xgb <- train(target ~ ., 
                              data = train[1:40000,c(3:306)],  #including target factor
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

tsne_xgb
tsne_xgb_imp <- varImp(tsne_xgb)
plot(tsne_xgb)

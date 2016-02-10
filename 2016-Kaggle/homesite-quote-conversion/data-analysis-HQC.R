# data munging on HQC Kaggle 
# https://www.kaggle.com/skylord/homesite-quote-conversion/digging-deeper-and-deeper/notebook

library(data.table)
library(dplyr)
library(tidyr)
library(ggplot2)
library(corrplot)

setwd("/home/topo/ghub/kaggle/kaggle-2016/homesite-quote-conversion")

train <- fread("./train.csv")
test <- fread("./test.csv")
#summary(train)

#str(train)
cat("\nNumber of Rows in Train: ",nrow(train),
    "Number of columns: ", ncol(train))
cat("\nNumber of Rows in Test: ",nrow(test),
    "Number of columns: ", ncol(test))


convQuotes <- (sum(train$QuoteConversion_Flag)/nrow(train))*100
cat("\nProportion of quotes that were converted: ", convQuotes, "%")

col_ct <- sapply(train, function(x) length(unique(x)))
colCnt.df <- data.frame(colName = names(train), colCount = col_ct)

table(col_ct==1)

cat("\nNumber of columns with constant values: ",sum(col_ct==1))

cat("\nName of constant columns: ", names(train)[which(col_ct==1)])
# OR

names(train[,which(col_ct==1)])

cat("\n\nRemoving the constant fields from train & test set....")
train <- train[, names(train)[which(col_ct == 1)] := NULL,
               with = FALSE]

cat("\nTrain dimensions: ", dim(train))
test <- test[, names(train)[which(col_ct == 1)] := NULL, with = FALSE]
cat("\nTest dimensions: ", dim(test))

#find numeric and char field

train_num <- train[,names(train)[which(sapply(train, is.numeric))], 
                   with = FALSE]
names(train_num)
sapply(train, is.character)
names(train)[which(sapply(train, is.character))]

table(sapply(train, is.character))

train_char <- train[,names(train)[which(sapply(train, is.character))], 
                    with = FALSE]

cat("Numerical column count : ", dim(train_num)[2], 
    "; Character column count : ", dim(train_char)[2])


# checking the characteristics of character columns
dim(train_num)
dim(train_char)

lapply(train_char, unique)

str(lapply(train_char, unique), vec.len = 4)

#fix the extra , in numbers
head(train$Field10)


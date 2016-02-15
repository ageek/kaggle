# Finding co-related features in HQC
require(dplyr)

#############flattencormatrix
cor.prob <- function (X, dfr = nrow(X) - 2) {
  R <- cor(X, use="pairwise.complete.obs")
  above <- row(R) < col(R)
  r2 <- R[above]^2
  Fstat <- r2 * dfr/(1 - r2)
  R[above] <- 1 - pf(Fstat, 1, dfr)
  R[row(R) == col(R)] <- NA
  R
}

## Use this to dump the cor.prob output to a 4 column matrix
## with row/column indices, correlation, and p-value.
## See StackOverflow question: http://goo.gl/fCUcQ
flattenSquareMatrix <- function(m) {
  if( (class(m) != "matrix") | (nrow(m) != ncol(m))) stop("Must be a square matrix.") 
  if(!identical(rownames(m), colnames(m))) stop("Row and column names must be equal.")
  ut <- upper.tri(m)
  data.frame(i = rownames(m)[row(m)[ut]],
             j = rownames(m)[col(m)[ut]],
             cor=t(m)[ut],
             p=m[ut])
}

###############
setwd("C:/Ahmed/ML/Kag2016/Homesite Quote Conversion/")
getwd()

library(readr)
library(xgboost)
library(caret)
# Parallel on Linux
#require(doMC)
#registerDoMC(cores=4)


#my favorite seed^^
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

#Also try dummyVars() for binary dummifier for categorical features
cat("assuming text variables are categorical & replacing them with numeric ids\n")
for (f in feature.names) {
  if (class(train[[f]])=="character") {
    levels <- unique(c(train[[f]], test[[f]]))
    train[[f]] <- as.integer(factor(train[[f]], levels=levels))
    test[[f]]  <- as.integer(factor(test[[f]],  levels=levels))
  }
}

names(train)

################cor-relation plot
#Find the top co-related features
require(corrgram)
train$target <- as.factor(ifelse(train$QuoteConversion_Flag==0,
                                 "No","Yes"))
set.seed(1199)
smalltrain <- train[sample(nrow(train), 5000, replace = F),]
prop.table(table(smalltrain$QuoteConversion_Flag))
prop.table(table(train$QuoteConversion_Flag))

#plot corrgram
corrgram(smalltrain)

##########pick the top 100 features by varImp and then do cor-plot among them

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
                              data = smalltrain[,c(3:304)],  #including target factor
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
save(base_xgb, file="./base_xgb_for_corelation.rda")

base_xgb
xgb_imp <- varImp(base_xgb)

############varImp on rF 
rfGrid <-  expand.grid(mtry = c(30))


system.time(model_rf <- train(target ~ ., 
                              data = smalltrain[,c(3:304)],
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

model_rf
rf_imp <- varImp(model_rf)


########top 100 from xgb_imp 
tt <- data.frame(Field=rownames(xgb_imp$importance), 
                 Value=xgb_imp$importance$Overall)
top200 <- as.character(head(tt$Field, 200))
top250 <- as.character(head(tt$Field, 250))
top290 <- as.character(head(tt$Field, 290))
top300 <- as.character(head(tt$Field, 300))

top100 <- as.character(head(tt$Field, 100))
top80 <- as.character(head(tt$Field, 80))
top60 <- as.character(head(tt$Field, 60))
top30 <- as.character(head(tt$Field, 30))
########find co-relation plot for top 30, 50, 80, 100 etc
require(corrgram)  #pass x, and ti'll calculate cor value
require(corrplot) #need to pass co-relation

corrgram(smalltrain[,top30], 
         order ="PCA",
         dir="left",
         cor.method = "spearman")

###using corrplot
cor(smalltrain[,top30])
corrplot(cor(smalltrain_20k[,top30]),
         #tl.pos = "n",  #stop pringting the text labels
         tl.srt = 45,
         order = "hclust")

#scale and center the data
# descrCor_pear <-  cor(scale(smalltrain,
#                             center=TRUE,
#                             scale=TRUE), method="pearson")

#######Using flattenCorMatrix and pick the top 30 co-related features
flat_cor_30 <- flattenSquareMatrix(cor(smalltrain[, top30]))
flat_cor_60 <- flattenSquareMatrix(cor(smalltrain[, top60]))
flat_cor_80 <- flattenSquareMatrix(cor(smalltrain[, top80]))
flat_cor_100 <- flattenSquareMatrix(cor(smalltrain[, top100]))
flat_cor_200 <- flattenSquareMatrix(cor(smalltrain[, top200]))

set.seed(1129)
smalltrain_20k <- train[sample(nrow(train), 20000, replace = F),]
smalltrain_50k <- train[sample(nrow(train), 50000, replace = F),]
smalltrain_100k <- train[sample(nrow(train), 100000, replace = F),]
smalltrain_200k <- train[sample(nrow(train), 200000, replace = F),]
smalltrain_all <- train[sample(nrow(train), nrow(train), replace = F),]


cor_all <- flattenSquareMatrix(cor(smalltrain_all[, top300])) %>%
  arrange(-abs(cor), p) %>%
  head(50)

# COLS_DIFF ('CoverageField1B', 'PropertyField21B'), 
# ('GeographicField6A', 'GeographicField8A'), 
# ('GeographicField6A', 'GeographicField13A'), 
# ('GeographicField8A', 'GeographicField11A'), 
# ('GeographicField8A', 'GeographicField13A'), 
# ('GeographicField11A', 'GeographicField13A')])

cor_all[cor_all$i == "PropertyField21B" |
          cor_all$j == "PropertyField21B"]

##############Using caret find columns to drop
require(caret)
zerovar <- nearZeroVar(smalltrain_100k)
names(smalltrain[,zerovar])

############
# calculate correlation matrix
correlationMatrix <- cor(smalltrain[,top30])
# summarize the correlation matrix
#print(correlationMatrix)

# find attributes that are highly corrected (ideally >0.75)
highlyCorrelated <- findCorrelation(correlationMatrix, cutoff=0.5)
# print indexes of highly correlated attributes

print(highlyCorrelated)
names(smalltrain[,top30])

names(smalltrain[,highlyCorrelated])[highlyCorrelated]


#####find co-relatedfeatures using Hmisc rcor()
# ++++++++++++++++++++++++++++
# flattenCorrMatrix
# ++++++++++++++++++++++++++++
# cormat : matrix of the correlation coefficients
# pmat : matrix of the correlation p-values
flattenCorrMatrix <- function(cormat, pmat) {
  ut <- upper.tri(cormat)
  data.frame(
    row = rownames(cormat)[row(cormat)[ut]],
    column = rownames(cormat)[col(cormat)[ut]],
    cor  =(cormat)[ut],
    p = pmat[ut]
  )
}

library(Hmisc)
res<-rcorr(as.matrix(mtcars[,1:7]))
flattenCorrMatrix(res$r, res$P)

flattenSquareMatrix(cor(mtcars[,1:7]))

#######do it for train[,top100] features and sort by p-values
# Hmis rcorr expects a matrix istead of data.frame
# http://r.789695.n4.nabble.com/How-to-resolve-the-following-error-list-object-cannot-be-coerced-to-type-double-td4642911.html
res <- rcorr(as.matrix((smalltrain_all[, top300])))

#pick top 50 highly co-related features
flattenCorrMatrix(res$r, res$P) %>%
  arrange(p,-cor, row) %>%
  head(50)
# 
# row             column                   cor       p
# 1    PropertyField21B    CoverageField1B 0.9963898 0
# 2   GeographicField6A  GeographicField8A 0.9962764 0
# 3     CoverageField1A   PropertyField21A 0.9957096 0
# 4   GeographicField7B GeographicField12B 0.9954205 0
# 5   GeographicField6A GeographicField11A 0.9942259 0
# 6   GeographicField8A GeographicField11A 0.9941798 0
# 7   GeographicField3A  GeographicField3B 0.9917246 0
# 8   GeographicField2B  GeographicField2A 0.9915598 0
# 9   GeographicField7A GeographicField12A 0.9912093 0
# 10 GeographicField52A GeographicField52B 0.9907508 0
# 11 GeographicField51B GeographicField52B 0.9901664 0
# 12 GeographicField51A GeographicField52A 0.9900521 0
# 13 GeographicField48A GeographicField48B 0.9899906 0
# 14 GeographicField51A GeographicField51B 0.9891976 0
# 15    CoverageField1A    CoverageField2A 0.9881034 0
# 16    PersonalField31    PersonalField45 0.9873087 0
# 17  GeographicField4B  GeographicField4A 0.9869324 0
# 18    PersonalField46    PersonalField32 0.9868597 0
# 19  GeographicField8B GeographicField13B 0.9866626 0
# 20    CoverageField2A   PropertyField21A 0.9863615 0
# 21    PersonalField4A    PersonalField4B 0.9863138 0
# 22    CoverageField1B    CoverageField2B 0.9862156 0
# 23       SalesField14       SalesField15 0.9861507 0
# 24  GeographicField8B GeographicField16B 0.9857408 0
# 25 GeographicField15A  GeographicField7A 0.9848734 0
# 26 GeographicField54B GeographicField54A 0.9848441 0
# 27   PropertyField21B    CoverageField2B 0.9840981 0
# 28 GeographicField19A GeographicField19B 0.9840472 0
# 29 GeographicField51B GeographicField52A 0.9827733 0
# 30 GeographicField59A GeographicField59B 0.9822793 0
# 31 GeographicField51A GeographicField52B 0.9813179 0
# 32   PropertyField39B   PropertyField39A 0.9807998 0
# 33 GeographicField44B GeographicField44A 0.9806492 0
# 34  GeographicField8B  GeographicField7B 0.9796915 0
# 35  GeographicField8B GeographicField12B 0.9792055 0
# 36 GeographicField50A GeographicField50B 0.9781138 0
# 37       SalesField11       SalesField12 0.9775008 0
# 38    PropertyField1A    PropertyField1B 0.9755111 0
# 39 GeographicField58B GeographicField58A 0.9748644 0
# 40 GeographicField57B GeographicField57A 0.9745218 0
# 41 GeographicField26B GeographicField26A 0.9720989 0
# 42 GeographicField41A GeographicField41B 0.9717051 0
# 43 GeographicField42B GeographicField42A 0.9713460 0
# 44  GeographicField7B GeographicField16B 0.9707382 0
# 45 GeographicField16A  GeographicField6A 0.9705604 0
# 46 GeographicField34A GeographicField34B 0.9695842 0
# 47 GeographicField16A  GeographicField8A 0.9691548 0
# 48 GeographicField12B GeographicField16B 0.9689001 0
# 49 GeographicField13B GeographicField12B 0.9682217 0
# 50    CoverageField4B    CoverageField1B 0.9681536 0


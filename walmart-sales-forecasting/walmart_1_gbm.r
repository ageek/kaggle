#
#
# Use gradient boosted tree's
#
# Rev1 - Join Data and use GBM
# RMLSE = 2, Using gbm.fit, 20 trees
# WMAE = 18413.44987
#
#
# When using more inputs,
#
rm(list=ls())
require(gbm)
require(dplyr)



# Mean Average Error, Weighted
# https://www.kaggle.com/c/walmart-recruiting-store-sales-forecasting/details/evaluation
computeWMAE <- function(Ysimulated, Yreal, XHoliday) {
	
	XWeight <- ifelse(XHoliday==TRUE,5,1)
	XWeight <- XWeight/sum(XWeight)
		 
	n <- length(Yreal)
	wmae <- sum(XWeight %*% abs(Ysimulated - Yreal))
	
	return (wmae)
}



computeRMSLE <- function(Ysimulated, Yreal) {
  
  #zero out negative elements  
  Ysimulated <- ifelse(Ysimulated<0,0,Ysimulated)
  Yreal <- ifelse(Yreal<0,0,Yreal)
  
  #initialize values
  rmsle <- 0.0
  n <- 0
  
  #perform calculations
  Ysimulated <- log(Ysimulated + 1)
  Yreal <- log(Yreal + 1)
  
  #for vectors, n is the length of the vector
  n <- length(Yreal)
  rmsle <- sqrt(sum((Ysimulated - Yreal)^2)/n)
  
  return (rmsle)
}


### Clean and make right category
#
# If sparse, don't use the mean.   Set it to the majority sparcicity value.
cleanInputDataForGBM <- function(X, transform_date=TRUE) {
	names(X);
	i_pos = length(X)
	for(i in 1:length(X)) {
		
		name = names(X)[i]
		print (name)
		col = X[,i]  
		
		index = which(is.na(col))
		
		if ( substr(name,1,3) == 'Cat'  ) {
			col[index] = "Unknown"
			X[,i] <- as.factor(col)
		}
		
		if ( substr(name,1,4) == 'Quan' ) {
			column_mean = mean(col, na.rm = TRUE)
			col[index] = column_mean
			X[,i] <- as.numeric(col)
		}
		
        #Date is 2014-01-01. Split into 3 columns
		if (transform_date == TRUE) {
    		if ( substr(name,1,4) == 'Date' ) {  	
    			#column_mean = mean(col, na.rm = TRUE)
    			#col[index] = column_mean
    			splitvec <- strsplit(as.character(col),'-',TRUE)
    			X[,i_pos+1] <- as.numeric(unlist(lapply(splitvec,"[[",1)))
    			colnames(X)[i_pos+1] = "Quant_Year"
    			X[,i_pos+2] <- as.numeric(unlist(lapply(splitvec,"[[",2)))
    			colnames(X)[i_pos+2] = "Quant_Month"
    			X[,i_pos+3] <- as.numeric(unlist(lapply(splitvec,"[[",3)))
    			colnames(X)[i_pos+3] = "Quant_Day"
    		}
		}
		
		result = is.factor(X[,i])
		print(result);
	}
	return (X)
}

cleanInputAsNumeric <- function(X) {
	names(X);
	for(i in 1:length(X)) {
		
		name = names(X)[i]
		print (name)
		col = X[,i]  
    	X[,i] <- as.numeric(col)	 
		result = is.factor(X[,i])
		print(result);
	}
	return (X)
}


# http://www.kaggle.com/c/walmart-recruiting-store-sales-forecasting
# train.csv - Store,Dept,Date,Weekly_Sales,IsHoliday
# - 45 stores * 143 days * 62 depts/per store (max 81 dept types)
# features.csv - Store,Date,Temperature,Fuel_Price,MarkDown1,MarkDown2,MarkDown3,MarkDown4,MarkDown5,CPI,Unemployment,IsHoliday
# - 45 stores * 182 days (3 years) = 8190
# stores.csv - Store,Type,Size
# - The type of store and its square footage.  Good change the footage is related to the sales anyways..
# 
# Predict for sales by dept.  Inner join store/days.  Use left join once more sophiticated
#

#idxCat <- c(13,558)
idxCat <- c(4,16)  #31st column is messed, 

train <- read.table(file="input/train.csv",header=TRUE, sep=",", na.strings=c("NA","NaN", " "))
feature <- read.table(file="input/features.csv",header=TRUE, sep=",", na.strings=c("NA","NaN", " "))

#ind <- sample(length(train[,1]),25000,FALSE)
#train_df <- tbl_df(train[ind,1:4])
train_df <- tbl_df(train[,1:4])
feature_df <- tbl_df(feature)
training <- inner_join(train_df, feature_df, by=c('Store','Date'))
training <- training[, c(4,3,2,5:14)] 
training$IsHoliday <- as.numeric(training$IsHoliday)
XtrainClean = cleanInputDataForGBM(training)
XtrainClean = XtrainClean[, c(3:16)]  


## Create levelsets for the NA's that are factors.   If numeric then abort if there is an NA

## Now run Test Data set, clean and continue.
test <- read.table(file="input/test.csv",header=TRUE, sep=",", na.strings=c("NA","NaN", " "))
#indt <- sample(length(test[,1]),25000,FALSE)
test_df <- tbl_df(test[,1:3])
test_df <- inner_join(test_df, feature_df, by=c('Store','Date'))
test_df <- test_df[, c(3,2,4:13)] 
XtestClean = cleanInputDataForGBM(test_df)
XtestClean = XtestClean[, c(2:15)]   


## GBM Parameters
ntrees <- 6000
depth <- 5
minObs <- 10
shrink <- 0.001
folds <- 10


Ynames <-   c('id', names(training)[1])

## Setup variables.
ntestrows = nrow(XtestClean)
ntrainrows = nrow(XtrainClean)
Yhattest =  matrix(nrow = ntestrows , ncol = 2, dimnames = list (1:ntestrows,Ynames ) )
Yhattrain =  matrix(nrow = ntrainrows , ncol = 2, dimnames = list (1:ntrainrows,Ynames ) )

X = XtrainClean
nColsOutput = 1

start=date()
start

Y <- as.numeric(training[,1])
#Y <- log(Y)  ## TBD how does this get reconciled?
Y[is.na(Y)] <- 0.0	
gdata <- cbind(Y,X)


#mo1gbm <- gbm(Y~. ,
#			        data=gdata,
#              distribution = "gaussian",
#              n.trees = ntrees,
#              shrinkage = shrink,
#              cv.folds = folds, 
#			        verbose = TRUE)
#mogbm = mo1gbm
#save(mogbm, file="mogbm.gbm")
load(file="./mogbm.gbm")

#fit the model
# mo2gbm <- gbm.fit(y=Y, x=X,
#                   verbose = TRUE,
#                   #data=gdata,
#                   distribution = "laplace",
#                   n.trees = ntrees,
#                   shrinkage = shrink,
#                   #cv.folds = folds
# )
# mogbm = mo2gbm

gbm.perf(mogbm,method="cv")
sqrt(min(mogbm$cv.error))
which.min(mogbm$cv.error)

Yhattest[,2] <- predict.gbm(mogbm, newdata=XtestClean, n.trees = ntrees)
Yhattrain[,2] <- predict.gbm(mogbm, newdata=XtrainClean, n.trees = ntrees) 	
end = date()
end

#Yhattest[,1] <- seq(1,ntestrows,1)
#Yhattrain[,1] <- seq(1,ntrainrows,1)
#save(Yhattest, file="Yhattest.pred")
#save(Yhattrain, file="Yhattrain.pred")


## Calculate total training error
YhattrainRMLSE <- Yhattrain[,2]
YtrainRMLSE <- as.matrix(training[,1])
YtrainRMLSE[is.na(YtrainRMLSE)] <- 0.0
rmsle <- computeRMSLE(YhattrainRMLSE, YtrainRMLSE)
rmsle
wmae <-  computeWMAE(YhattrainRMLSE, YtrainRMLSE, XtrainClean[,3])
wmae

Yerror = abs(YhattrainRMLSE -  YtrainRMLSE)
Yerror_all = cbind(Yerror, training)
sorted_error = Yerror_all[ order(-Yerror_all$Yerror), ]

#ggplot(sorted_error, aes(x=sorted_error$Date, y=max(Yerror), colour=supp)) + 
#  geom_errorbar(aes(ymin=max(Yerror)-se, ymax=max(Yerror)+se), width=.1) +
#  geom_line() +
#  geom_point()


#2. 

write.csv(Yhattrain, "walmart_1_jag_gbm_train.csv", row.names=FALSE)

submit_key = do.call(paste,c(test[,1:3], sep="_"))

Yhattest_final = cbind(submit_key, Yhattest[,2])

colnames(Yhattest_final)[1] = "Id"
colnames(Yhattest_final)[2] = "Weekly_Sales"
write.csv(Yhattest_final, "walmart_1_jag_gbm.csv", row.names=FALSE)


#########################################################
# Extra's
########################################################
# 1. Which columns look like other columns
# Take the correlatoin, and find where its greater that 0.9999
# Of course remove the 1 correlaion
# You must set EACH column to a numeric one
# Finally the 'diff' returns where its not a diagonol
# TODO return the exact columnnames

train_mat <- cbind(Y,XtrainClean)
trainingMatrix = as.matrix( train_mat )
trainingMatrix = cleanInputAsNumeric( train_mat)
trainingMatrix[is.na(trainingMatrix)] <- 0.0

corr <- cor(trainingMatrix)
idx <- which(corr > 0.9999, arr.ind = TRUE)
idxCopy <- idx[ apply(idx, 1, diff) > 0, ]


# 2. Plot error
# Output data
library(ggplot2)
library(calibrate)
library(grid)
library(stats)

stats <- function(x) {
  ans <- boxplot.stats(x)
  data.frame(ymin = ans$conf[1], ymax = ans$conf[2])
}

vgrid <- function(x,y) {
  viewport(layout.pos.row = x, layout.pos.col = y)
}



nCol = 15
start = 2
pushViewport(viewport(layout=grid.layout(1,nCol)))
for(iCol in start:(nCol+start-1) ){
  
  name = names(train_mat)[iCol]
  print(name)
  data_col = train_mat[,iCol]
  p <- ggplot(data=train_mat, aes(name, data_col )) + 
    geom_boxplot(notch = TRUE, notchwidth = 0.5) +
    stat_summary(fun.data = stats, geom = "linerange", colour = "skyblue", size = 5)
  q = list(p)
  print(q[[1]], vp=vgrid(1, iCol-start+1))
}


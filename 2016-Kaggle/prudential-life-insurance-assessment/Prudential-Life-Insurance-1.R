# https://www.kaggle.com/pchitta/prudential-life-insurance-assessment/caret-cv/code


library(readr)
library(xgboost) 
library(Hmisc)
library(caret)
library(e1071)
library("Metrics")

#library(doMC)
#registerDoMC(cores = 16)

set.seed(1729) 
dummyFirst=FALSE
carryImp=FALSE
rounds1 = 36
eta1 = 1
dp1 = 3
rounds2 = 501
adddummy=TRUE
model=TRUE
pca=TRUE
nbmvars=FALSE
fetEng=TRUE

param1 <- list(objective = "reg:linear", max.depth = 3, eta = 0.12, subsamp=.9)
#param2 <- list(objective = "reg:linear", max.depth = 1, eta = 1, subsamp=.5)
param2 <- list(  objective           = "reg:linear", eta = 0.1, max_depth =  6,
                subsample           = 0.8, # 0.7
                min_child_weight    = 25,
                colsample_bytree    = 0.7, # 0.7
                silent              = 0
)

SQWKfun = function(x = seq(1.5, 7.5, by = 1), pred) {
  preds = pred$predict
  true = pred$Response
  cuts = c(min(preds), x[1], x[2], x[3], x[4], x[5], x[6], x[7], max(preds))
  preds = as.numeric(Hmisc::cut2(preds, cuts))
  err = Metrics::ScoreQuadraticWeightedKappa(preds, true, 1, 8)
  return(-err)
}
#Catvars <- c("Product_Info_1", "Product_Info_2", "Product_Info_3", "Product_Info_5", "Product_Info_6", "Product_Info_7", "Employment_Info_2", "Employment_Info_3", "Employment_Info_5", "InsuredInfo_1", "InsuredInfo_2", "InsuredInfo_3", "InsuredInfo_4", "InsuredInfo_5", "InsuredInfo_6", "InsuredInfo_7", "Insurance_History_1", "Insurance_History_2", "Insurance_History_3", "Insurance_History_4", "Insurance_History_7", "Insurance_History_8", "Insurance_History_9", "Family_Hist_1", "Medical_History_2", "Medical_History_4", "Medical_History_5", "Medical_History_6", "Medical_History_7", "Medical_History_8", "Medical_History_9", "Medical_History_11", "Medical_History_12", "Medical_History_13", "Medical_History_14", "Medical_History_16", "Medical_History_17", "Medical_History_18", "Medical_History_19", "Medical_History_20", "Medical_History_21", "Medical_History_22", "Medical_History_23", "Medical_History_25", "Medical_History_26", "Medical_History_27", "Medical_History_28", "Medical_History_29", "Medical_History_30", "Medical_History_31", "Medical_History_33", "Medical_History_34", "Medical_History_35", "Medical_History_36", "Medical_History_37", "Medical_History_38", "Medical_History_39", "Medical_History_40", "Medical_History_41")
Catvars <- c("Product_Info_2", "Medical_History_23" )

train = read_csv("../input/train.csv")
test = read_csv("../input/test.csv")
feature.names <- names(train)[3:ncol(train)-1]

train$PI2char = as.factor(substr(train$Product_Info_2, 1,1))
train$PI2num = as.factor(substr(train$Product_Info_2, 2,2))
test$PI2char = as.factor(substr(test$Product_Info_2, 1,1))
test$PI2num = as.factor(substr(test$Product_Info_2, 2,2))

cat("Factor char fields\n")
for (f in feature.names) {
    levels <- unique(c(train[[f]], test[[f]]))
   
    if ((length(levels) > 2 & length(levels) < 33) | class(train[[f]])=="character") {
     cat(sprintf("factoring %s with %d levels\n", f, length(levels)))
     train[[f]] <- factor(train[[f]], levels=levels)
     test[[f]] <- factor(test[[f]], levels=levels)
    }
}
if(adddummy) {
test$Response <- NA
#All_Data <- rbind(train,test) 
dummies <- dummyVars(Response ~ ., data = train[,], sep = "_", levelsOnly = FALSE, fullRank = TRUE)
train1 <- as.data.frame(predict(dummies, newdata = train[,]))
test <- as.data.frame(predict(dummies, newdata = test[,]))
train <- cbind(train1, Response=train$Response)
feature.names <- names(train)[3:ncol(train)-1]
print(feature.names)
}

if(nbmvars) {
cat("NB medical keywords\n")

feature.names1 <- grep('Medical_H', feature.names, value=TRUE)
feature.names2 <- grep('Medical_H', feature.names, value=TRUE, invert=TRUE)

trainMK <- train[, c(feature.names1)]
testMK <- test[, feature.names1]
date()
nb <- naiveBayes(x=trainMK, y=factor(train$Response, labels="x"), laplace = 0)
date()
pred <- predict(nb, newdata=trainMK, type="raw")
train <- cbind(train[, c("Id", feature.names)], MKprob1=pred[, 1], MKprob2=pred[, 2], MKprob3=pred[, 3], MKprob4=pred[, 4], MKprob5=pred[, 5], MKprob6=pred[, 6], MKprob7=pred[, 7], MKprob8=pred[, 8], Response=train$Response)

pred <- predict(nb, newdata=testMK, type="raw")
test <- cbind(test[, c("Id", feature.names)], MKprob1=pred[, 1], MKprob2=pred[, 2], MKprob3=pred[, 3], MKprob4=pred[, 4], MKprob5=pred[, 5], MKprob6=pred[, 6], MKprob7=pred[, 7], MKprob8=pred[, 8])
}

if(pca) {
test$Response <- 0
All_Data <- rbind(train,test) 
feature.names <- names(train)[3:ncol(train)-1]
cat(sprintf("All_Data has %d rows and %d columns\n", nrow(All_Data), ncol(All_Data)))

cat("get rid of zero variance\n")
date()
preProcValues <- preProcess(All_Data, method = c("zv"))#, "medianImpute"
All_Data1 <- predict(preProcValues, All_Data)
#print(feature.names)
#summary(All_Data1)
#cat("do PCA\n")
#date()
#preProcValues <- preProcess(All_Data1[, feature.names], method = c("pca"))
#All_Data1 <- predict(preProcValues, All_Data1[, feature.names])
All_Data <- cbind(Id=All_Data$Id, All_Data1, Response=All_Data$Response)
print(table(All_Data$Response))
train <- All_Data[which(All_Data$Response > 0),]
test <- All_Data[which(All_Data$Response == 0),]
#feature.names <- names(train)[3:ncol(train)-1]
} 
if(fetEng) {
##----Feature engineering-------------------------------------------------------------------------
	#Quantile cut-off used to define custom variables 10 and 12 (step functions over BMI and BMI*Ins_Age)
	qbmic <- 0.8
	qbmic2 <- 0.9
	#Hand engineered features. Found by EDA (especially added variable plots), some parameters optimized
	#using cross validation. Nonlinear dependence on BMI and its interaction with age make intuitive sense.
	custom_var_1 <- as.numeric(All_Data$Medical_History_15 < 10.0)
	custom_var_1[is.na(custom_var_1)] <- 0.0 #impute these NAs with 0s, note that they were not median-imputed
	custom_var_3 <- as.numeric(All_Data$Product_Info_4 < 0.075)
	custom_var_4 <- as.numeric(All_Data$Product_Info_4 == 1)
	custom_var_6 <- (All_Data$BMI + 1.0)**2.0
	custom_var_7 <- (All_Data$BMI)**0.8
	custom_var_8 <- All_Data$Ins_Age**8.5
	custom_var_9 <- (All_Data$BMI*All_Data$Ins_Age)**2.5
	BMI_cutoff <- quantile(All_Data$BMI, qbmic)
	custom_var_10 <- as.numeric(All_Data$BMI > BMI_cutoff)
	custom_var_11 <- (All_Data$BMI*All_Data$Product_Info_4)**0.9
	ageBMI_cutoff <- quantile(All_Data$Ins_Age*All_Data$BMI, qbmic2)
	custom_var_12 <- as.numeric(All_Data$Ins_Age*All_Data$BMI > ageBMI_cutoff)
	custom_var_13 <- (All_Data$BMI*All_Data$Medical_Keyword_3 + 0.5)**3.0
	feature.names1 <- grep('Medical_K', feature.names, value=TRUE)
	custom_var_M <- rowSums(as.matrix(All_Data[, feature.names1]))
	cvResponse <- 0
	All_Data <- cbind(Id=All_Data$Id, All_Data[, feature.names], custom_var_1, custom_var_3, custom_var_4, custom_var_6, custom_var_7, custom_var_8, custom_var_9, custom_var_10, custom_var_11, custom_var_12, custom_var_13, custom_var_M, cvResponse, Response=All_Data$Response)
    train <- All_Data[which(All_Data$Response > 0),]
    test <- All_Data[which(All_Data$Response == 0),]
    feature.names <- names(train)[3:ncol(train)-1]	
#    print(feature.names)
}
print(dim(train))
print(dim(test))

feature.names <- names(train)[3:ncol(train)-1]

feature.names1 = feature.names
feature.names2 = feature.names

train[] <- lapply(train, as.numeric)
test[] <- lapply(test, as.numeric)

if (model) {

trainIndex <- createDataPartition(train$Response, p = .67, list = FALSE, times = 1)

#table(Pval$Response)
for (i in 1:1) {
Ptrain <- train[trainIndex, ]
Pval  <- train[-trainIndex, ]

param1 <- list(objective = "reg:linear", max.depth = round(dp1/i), eta = (eta1), subsamp=.5)
date()
cat("Fitting model 1 \n")
#fit <- train(x=data.matrix(train[,feature.names]), y=train$Response, #distribution="multinomial", 
#            method = "xgbTree", #nTrain = round(nrow(train) *0.8), 
#            trControl = fitControl,
#            tuneGrid = tune_grid,
#            metric = "Kappa", 
#            verbose = 1)
#print(summary(Ptrain))
#print(Ptrain)

dtrain <- xgb.DMatrix(data.matrix(Ptrain[, feature.names1]), label=Ptrain$Response)
vtrain <- xgb.DMatrix(data.matrix(train[,feature.names1]), label=train$Response)
dval <- xgb.DMatrix(data.matrix(Pval[,feature.names1]), label=Pval$Response)
dtest <- xgb.DMatrix(data.matrix(test[,feature.names1]))

Watchlist <- list(train=dtrain, test=dval)

fit <- xgb.train(data=dtrain, params=param1, nround=round(rounds1), watchlist=Watchlist, verbose=1, print.every.n = 1)
date()       
summary(fit)

importance_matrix <- xgb.importance(model = fit)
print(summary(importance_matrix))
str(importance_matrix)
if(carryImp) {
feature.names2 <- feature.names[c(as.numeric(importance_matrix$Feature[1:nrow(importance_matrix)])+1)]
print(feature.names2)
} else {
print(feature.names[c(as.numeric(importance_matrix$Feature[1:nrow(importance_matrix)])+1)])
}
#write_csv(importance_matrix, "Imp_Matrix.csv")
#xgb.plot.importance(importance_matrix = importance_matrix)

cat("Predict model 1\n")
#test$cvResponse <- predict(fit, newdata=data.matrix(test[,feature.names1]))
test$cvResponse <- predict(fit, newdata=dtest)

date()   

cat("Validation of model 1\n")
#train$cvResponse <- predict(fit, newdata=data.matrix(train[,feature.names1]))
train$cvResponse <- predict(fit, newdata=vtrain)
date()   

print(round((table(round(train$cvResponse),train$Response)/nrow(train))*100,1))

print(ScoreQuadraticWeightedKappa(as.numeric(round(train$cvResponse)),as.numeric(train$Response)))
}
# Now use the regression output and try to classify.... 
if(!dummyFirst) {
feature.names2 <- c(feature.names2, "cvResponse")
Ptrain <- train[trainIndex,]
Pval  <- train[-trainIndex,]
}

#trainIndex <- createDataPartition(train$Response, p = .5, list = FALSE, times = 1)
#Ptrain$cvResponse <- 8
#train$cvResponse <- 8
#Pval$cvResponse <- 8
#test$cvResponse <- 8

dtrain <- xgb.DMatrix(data.matrix(Ptrain[,feature.names2]), label=Ptrain$Response)
vtrain <- xgb.DMatrix(data.matrix(train[,feature.names2]), label=train$Response)
dval <- xgb.DMatrix(data.matrix(Pval[,feature.names2]), label=Pval$Response)
dtest <- xgb.DMatrix(data.matrix(test[,feature.names2]))

Watchlist <- list(train=dtrain, test=dval)

fit <- xgb.train(data=dtrain, params=param2, nround=rounds2,  watchlist=Watchlist, verbose=1, print.every.n = 50)

importance_matrix <- xgb.importance(model = fit)
print(head(importance_matrix))
print(feature.names2[c(as.numeric(importance_matrix$Feature[1:20])+1)])

write_csv(importance_matrix, "Imp_Matrix2.csv") #print(importance_matrix)

cat("Predict model 2\n")
#test$Response <- round(predict(fit, newdata=data.matrix(test[,feature.names])))
test$cvResponse1 <- predict(fit, newdata=dtest)
train$cvResponse1 <- predict(fit, newdata=vtrain)
Pval$cvResponse1 <- predict(fit, newdata=dval)

pred = data.frame(Id=Pval$Id, Response=Pval$Response, predict=Pval$cvResponse1)
optCuts = optim(seq(1.5, 7.5, by = 1), SQWKfun, pred = pred)
print(optCuts)
preds = as.numeric(Hmisc::cut2(test$cvResponse1, c(-Inf, optCuts$par, Inf)))
print(table(preds))
print(table(Pval$Response))
date()   
cat("saving the submission file\n")
submission <- data.frame(Id=test$Id, Response=preds)

#submission[submission$Response<1, "Response"] <- 1
#submission[submission$Response>8, "Response"] <- 8


write_csv(submission, "Pru_xgb_2reg_OptimCut_sub.csv")

cat("Validation predict model\n")
#train$cvResponse <- predict(fit, newdata=data.matrix(train[,feature.names1]))

date()   
preds = as.numeric(Hmisc::cut2(Pval$cvResponse1, c(-Inf, optCuts$par, Inf)))

print(round((table(preds,Pval$Response)/nrow(Pval))*100,1))

preds = as.numeric(Hmisc::cut2(train$cvResponse1, c(-Inf, optCuts$par, Inf)))

print(ScoreQuadraticWeightedKappa(round(Pval$cvResponse1),as.numeric(Pval$Response)))
val <- data.frame(Id=train$Id, cvResponse1=train$cvResponse, cvResponse2=train$cvResponse1, Response=train$Response, Predict=preds  ) #Response=train$Response, cvResponse=train$cvResponse, cvResponse1=train$cvResponse1,

write_csv(val, "Pru_xgbTree_val.csv")
xgb.dump(fit,"xgb_model.dump", with.stats = TRUE)

}

if (FALSE) {
fit <- xgboost(data        = data.matrix(train[,c(feature.names1)]), #,"cvResponse", "cvResponse1"
               label       = train$Response-1,
               eta         = 0.04,
               depth       = 6,
               nrounds     = 80,
               objective   = "multi:softmax", num_class = 8, verbose = 1,
               eval_metric = "merror")

test$cvResponse2 <- predict(fit, newdata=data.matrix(test[,c(feature.names1)]))+1
submission <- data.frame(Id=test$Id, Response=test$cvResponse2)
write_csv(submission, "Pru_xgbTree_3class_sub.csv")
train$cvResponse2 <- predict(fit, newdata=data.matrix(train[,c(feature.names1)]))+1

round((table(round(train$cvResponse2),train$Response)/nrow(train))*100,1)

ScoreQuadraticWeightedKappa(as.numeric(round(train$cvResponse2)),as.numeric(train$Response))
val <- data.frame(Id=train$Id, cvResponse2=train$cvResponse2  ) #Response=train$Response, cvResponse=train$cvResponse, cvResponse1=train$cvResponse1,

write_csv(val, "Pru_xgbTree_10t_val.csv")
}
#Done!
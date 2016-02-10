#glmnet for logistic regression

# HQC kaggle challenge
# /home/topo/ghub/kaggle/kaggle-2016/homesite-quote-conversion

setwd("/home/topo/ghub/kaggle/kaggle-2016/homesite-quote-conversion")
getwd()

library(readr)
library(glmnet)

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
summary(train)
cat("test data column names and details\n")
names(test)
str(test)
summary(test)


# seperating out the elements of the date column for the train set
train$month <- as.integer(format(train$Original_Quote_Date, "%m"))
train$year <- as.integer(format(train$Original_Quote_Date, "%y"))
train$day <- weekdays(as.Date(train$Original_Quote_Date))
train$Q <- quarters(as.Date(train$Original_Quote_Date))

# removing the date column
train <- train[,-c(2)]

# seperating out the elements of the date column for the train set
test$month <- as.integer(format(test$Original_Quote_Date, "%m"))
test$year <- as.integer(format(test$Original_Quote_Date, "%y"))
test$day <- weekdays(as.Date(test$Original_Quote_Date))
test$Q <- quarters(as.Date(test$Original_Quote_Date))

# removing the date column
test <- test[,-c(2)]

#changed to 302 to capture Q column
feature.names <- names(train)[c(3:302)]
cat("Feature Names\n")
feature.names

cat("assuming text variables are categorical & replacing them with numeric ids\n")
for (f in feature.names) {
  if (class(train[[f]])=="character") {
    levels <- unique(c(train[[f]], test[[f]]))
    #print the diff in train and test categories
    print(setdiff(train[[f]], test[[f]]))
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
dim(train)
dim(test)

# glmnet modeling=====================
# register 4 cores
require(doMC)
registerDoMC(cores = 4)

x = model.matrix(QuoteConversion_Flag~., data = train)
y = train$QuoteConversion_Flag

#alpha=0 means Ridge /L2 norm
#alpha=1, Lasso / L1 norm
fit.ridge=glmnet(x,y,alpha=0)
plot(fit.ridge, xvar="lambda", label=T)
cv.ridge=cv.glmnet(x,y, alpha=0)

save(cv.ridge, file="./cv-ridge.rda")
plot(cv.ridge)


# lasso model, L1 norm
fit.lasso=glmnet(x,y,alpha=1)
plot(fit.lasso, xvar="lambda", label=T)
cv.lasso=cv.glmnet(x,y, alpha=1)

save(cv.lasso, file="./cv-lasso.rda")
plot(cv.lasso)

#%age of dev explained - i.e %age varaince explained
# similar to R^2
plot(fit.lasso, xvar="dev", label=T)

coef(cv.lasso)

# from the plot its clear, around 22-25 are good enough to explain
# ~ 80% + deviance


glmmod<-glmnet(x,y,alpha=1,family='binomial')

#plot variable coefficients vs. shrinkage parameter lambda.
plot(glmmod,xvar="lambda")
grid()

cv.glmmod<-cv.glmnet(x,y,alpha=1)
plot(cv.glmmod)

#Note: 
# system hangs , as all 4 cores are used...remains so for 30 
# mins or more on 8G RAM, i5-4440 machine
# lasso model with alpha=1
cv.fit = cv.glmnet(x, y, alpha=1, 
                type.measure='auc', family = "binomial")

#save the model for later use
save(cv.fit, file = "./glm-cv-fit-lasso-1.rda")

# plots shows the best AUC can be achieved with around 156 predictors
# and the cv AUC value hovers around .95

plot(cv.fit)

#best lambda values are
cv.fit$lambda.min

#1st se lambda
cv.fit$lambda.1se

log(cv.fit$lambda.1se)
log(cv.fit$lambda.min)

# final prediction 
pred1 <- predict(cv.fit, newx=as.matrix(test[,feature.names]),
                 s = 'lambda.1se',
                 type='response')

submission <- data.frame(QuoteNumber=test$QuoteNumber, 
                         QuoteConversion_Flag=pred1)

cat("saving the submission file\n")
write_csv(submission, "xgb_stop_3.csv")

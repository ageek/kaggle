library(cvTools)
library(gbm)
########################################
############## TRAINING ################
########################################
load('data/train_2014.04.05.RData')

nam = names(data)
omitClass <- c(which(nam=="targetA"),which(nam=="targetB"),which(nam=="targetC"),which(nam=="targetD"),
               which(nam=="targetE"),which(nam=="targetF"),which(nam=="targetG"),
               which(nam=="customer_ID"),which(nam=="last"),which(nam=="location"))

omitOptions <- c(omitClass,which(nam=="willChange"))

targetOptions = c(which(nam=="targetA"),which(nam=="targetB"),which(nam=="targetC"),which(nam=="targetD"),
                 which(nam=="targetE"),which(nam=="targetF"),which(nam=="targetG"))

currentOptions <- c(which(nam=="A"),which(nam=="B"),which(nam=="C"),which(nam=="D"),
                    which(nam=="E"),which(nam=="F"),which(nam=="G"))

                    
set.seed(1234)
folds = 3
classTrees = 4000
optTrees = 1500
class_shrinkage = opt_shrinkage = 0.01
class_depth = opt_depth = 9
class_minobs = 20
opt_minobs = 10

customers = unique(data$customer_ID)
cvF <-  cvFolds(length(customers), K = folds, R = 1)

classifiers <- list()
pClass <- list()
models_options <- list()
for(i in 1:7)
{
  classifiers[[i]] <- list()
  pClass[[i]] <- list()
  models_options[[i]] <- list()
}

for(fold in 1:folds)
{
  valCustomers <- sort(cvF$subset[cvF$which==fold])
  val = data$customer_ID %in% valCustomers
  train = !val
  
  
  for(option in 1:7)
  { 
    ######### CLASSIFIER
    cat('Fold ',fold,', option ',option,', building the classifier...')
    data$willChange <- as.numeric(data[,targetOptions[option]] != data[,currentOptions[option]])
    gc(reset=T)
    classifiers[[option]][[fold]] = gbm(willChange~., data[train,-omitClass], 
                                        distribution="bernoulli",keep.data=F,verbose=F,n.cores=1,
                                        n.trees=classTrees,shrinkage=class_shrinkage,interaction.depth=class_depth,n.minobsinnode=class_minobs)
    pClass[[option]][[fold]] = predict(classifiers[[option]][[fold]],data[val,],type="response",n.trees=classTrees)
    cat('done\n')
    ######### OPTION
    cat('Fold ',fold,', option ',option,', building the predictor...')
    models_options[[option]][[fold]] = gbm(as.formula(paste(nam[targetOptions[option]],'~.')),
                                           data = data[val,-omitOptions[-option]][pClass[[option]][[fold]]>=0.2,],
                                           distribution="multinomial",keep.data=T,verbose=F,n.cores=1,
                                           n.trees=optTrees,shrinkage=opt_shrinkage,interaction.depth=opt_depth,n.minobsinnode=opt_minobs)
    cat('done\n')
    cat('saving...')
    save(classifiers,pClass,models_options,file='models_ind.RData')
    cat('done\n')
    gc(reset=T)
  }
}

########################################
############## TESTING #################
########################################
testClass = list()
for (option in 1:7)
{
  testClass[[option]] = 0
  for (fold in 1:folds)
    testClass[[option]] = testClass[[option]] +
    predict(classifiers[[option]][[fold]],test,type="response",n.trees=classTrees)
  testClass[[option]] = testClass[[option]]/folds
}

thr = rep(0.7,7)
thr[7] = 0.45
for (rep in 1:1)
{
  testOption = list()
  for (option in 1:7)
  {
    testOption[[option]] = 0
    for (fold in 1:folds)
      testOption[[option]] = testOption[[option]] + 
      predict(models_options[[option]][[fold]],test[testClass[[option]]>=thr[option],],type="response",n.trees=optTrees)
    testOption[[option]] <- apply(testOption[[option]]/folds,1,which.max)
    if (option %in% c(1,2,5,6))
      testOption[[option]] = testOption[[option]]-1
  }
  for(option in 1:7)
  {
    test[testClass[[option]]>=thr[option],currentOptions[option]] = testOption[[option]]
  }
}

whichLast = which(test$last==1)
finalTest = sprintf('%s%s%s%s%s%s%s',
                    test$A[whichLast],
                    test$B[whichLast],
                    test$C[whichLast],
                    test$D[whichLast],
                    test$E[whichLast],
                    test$F[whichLast],
                    test$G[whichLast])

submission = data.frame(customer_ID=test$customer_ID[whichLast],plan=finalTest)

write.csv(submission,file="submissionTest.csv",quote=F,row.names=F)
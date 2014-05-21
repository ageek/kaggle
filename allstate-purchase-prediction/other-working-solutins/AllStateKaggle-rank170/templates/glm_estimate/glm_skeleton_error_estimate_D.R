
# Estimation modeles

list_prob <- seq(start.check, end.check, step.check)

result <- data.frame()

for(prob in list_prob) {
  
  cat("Taille train : ", prob, "\n")
  
  tmp <- get.base.train.test(dataTrainBase, y.variable, prob)
  dataTrain <- tmp$train
  
  # Evaluation modeles  
  print("Entrainement modele GLM 1")
  model_1 <- glm(
    formula_1
    , family = binomial, data=dataTrain, trace = TRUE)
  
  print("Entrainement modele GLM 2")
  model_2 <- glm(
    formula_2
    , family = binomial, data=dataTrain, trace = TRUE)
  
  print("Entrainement modele GLM 3")
  model_3 <- glm(
    formula_3
    , family = binomial, data=dataTrain, trace = TRUE)
  
  dataTest$predict_glm_1 <- predict(model_1, newdata=dataTest)
  dataTest$predict_glm_2 <- predict(model_2, newdata=dataTest)
  dataTest$predict_glm_3 <- predict(model_3, newdata=dataTest)
  
  dataTest$predicted_glm_D <- factor(max.col(dataTest[,c("predict_glm_1","predict_glm_2","predict_glm_3")]))
  
  dataTrain$predict_glm_1 <- predict(model_1, newdata=dataTrain)
  dataTrain$predict_glm_2 <- predict(model_2, newdata=dataTrain)
  dataTrain$predict_glm_3 <- predict(model_3, newdata=dataTrain)
  
  dataTrain$predicted_glm_D <- factor(max.col(dataTrain[,c("predict_glm_1","predict_glm_2","predict_glm_3")]))
  
  
  print("Error GLM Test:")
  print(prediction_error(dataTest$real_D, dataTest$predicted_glm_D))
  
  print("Error GLM Train:")
  print(prediction_error(dataTrain$real_D, dataTrain$predicted_glm_D))
  
  
  result <- add.result(
    result.set=result,
    size.train=prob,
    train.set=dataTrain,
    test.set=dataTest,
    type.model="glm",
    type.set=type,
    value.to.test="1",
    letter=y.letter,
    real.column="real_D",
    predicted.column="predicted_glm_D",
    deviance=model_1$deviance
  )
  
  result <- add.result(
    result.set=result,
    size.train=prob,
    train.set=dataTrain,
    test.set=dataTest,
    type.model="glm",
    type.set=type,
    value.to.test="2",
    letter=y.letter,
    real.column="real_D",
    predicted.column="predicted_glm_D",
    deviance=model_2$deviance
  )
  
  result <- add.result(
    result.set=result,
    size.train=prob,
    train.set=dataTrain,
    test.set=dataTest,
    type.model="glm",
    type.set=type,
    value.to.test="3",
    letter=y.letter,
    real.column="real_D",
    predicted.column="predicted_glm_D",
    deviance=model_3$deviance
  )
    
  result <- add.result(
    result.set=result,
    size.train=prob,
    train.set=dataTrain,
    test.set=dataTest,
    type.model="glm",
    type.set=type,
    value.to.test="ALL",
    letter=y.letter,
    real.column="real_D",
    predicted.column="predicted_glm_D",
    deviance=NA
  )
  
}

# Sauvegarde CR erreurs
print(result)

write.csv(result, csv.output.filename)


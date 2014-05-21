
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
  
  print("Entrainement modele GLM 4")
  model_4 <- glm(
    formula_4
    , family = binomial, data=dataTrain, trace = TRUE)
  
  dataTest$predict_glm_1 <- predict(model_1, newdata=dataTest)
  dataTest$predict_glm_2 <- predict(model_2, newdata=dataTest)
  dataTest$predict_glm_3 <- predict(model_3, newdata=dataTest)
  dataTest$predict_glm_4 <- predict(model_4, newdata=dataTest)
  
  dataTest$predicted_glm_G <- factor(max.col(dataTest[,c("predict_glm_1","predict_glm_2","predict_glm_3","predict_glm_4")]))
  
  dataTrain$predict_glm_1 <- predict(model_1, newdata=dataTrain)
  dataTrain$predict_glm_2 <- predict(model_2, newdata=dataTrain)
  dataTrain$predict_glm_3 <- predict(model_3, newdata=dataTrain)
  dataTrain$predict_glm_4 <- predict(model_4, newdata=dataTrain)
  
  dataTrain$predicted_glm_G <- factor(max.col(dataTrain[,c("predict_glm_1","predict_glm_2","predict_glm_3","predict_glm_4")]))
  
  print("Error GLM Test:")
  print(prediction_error(dataTest$real_G, dataTest$predicted_glm_G))
  
  print("Error GLM Train:")
  print(prediction_error(dataTrain$real_G, dataTrain$predicted_glm_G))
  
  
  result <- add.result(
    result.set=result,
    size.train=prob,
    train.set=dataTrain,
    test.set=dataTest,
    type.model="glm",
    type.set=type,
    value.to.test="1",
    letter=y.letter,
    real.column="real_G",
    predicted.column="predicted_glm_G",
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
    real.column="real_G",
    predicted.column="predicted_glm_G",
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
    real.column="real_G",
    predicted.column="predicted_glm_G",
    deviance=model_3$deviance
  )
  
  result <- add.result(
    result.set=result,
    size.train=prob,
    train.set=dataTrain,
    test.set=dataTest,
    type.model="glm",
    type.set=type,
    value.to.test="4",
    letter=y.letter,
    real.column="real_G",
    predicted.column="predicted_glm_G",
    deviance=model_4$deviance
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
    real.column="real_G",
    predicted.column="predicted_glm_G",
    deviance=NA
  )
  
}

# Sauvegarde CR erreurs
print(result)

write.csv(result, csv.output.filename)


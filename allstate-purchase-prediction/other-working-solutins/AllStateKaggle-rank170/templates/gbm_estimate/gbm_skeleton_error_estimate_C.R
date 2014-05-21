
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
    , family = binomial, data=dataTrain)
  
  print("Entrainement modele GLM 2")
  model_2 <- glm(
    formula_2
    , family = binomial, data=dataTrain)
  
  print("Entrainement modele GLM 3")
  model_3 <- glm(
    formula_3
    , family = binomial, data=dataTrain)
  
  print("Entrainement modele GLM 4")
  model_4 <- glm(
    formula_4
    , family = binomial, data=dataTrain)
  
  dataTest$predict_glm_1 <- predict(model_1, newdata=dataTest)
  dataTest$predict_glm_2 <- predict(model_2, newdata=dataTest)
  dataTest$predict_glm_3 <- predict(model_3, newdata=dataTest)
  dataTest$predict_glm_4 <- predict(model_4, newdata=dataTest)
  
  dataTest$predicted_glm_C <- factor(max.col(dataTest[,c("predict_glm_1","predict_glm_2","predict_glm_3", "predict_glm_4")]))
  
  dataTrain$predict_glm_1 <- predict(model_1, newdata=dataTrain)
  dataTrain$predict_glm_2 <- predict(model_2, newdata=dataTrain)
  dataTrain$predict_glm_3 <- predict(model_3, newdata=dataTrain)
  dataTrain$predict_glm_4 <- predict(model_4, newdata=dataTrain)
  
  dataTrain$predicted_glm_C <- factor(max.col(dataTrain[,c("predict_glm_1","predict_glm_2", "predict_glm_3", "predict_glm_4")]))
  
  
  print("Error GLM Test:")
  print(prediction_error(dataTest$real_C, dataTest$predicted_glm_C))
  
  print("Error GLM Train:")
  print(prediction_error(dataTrain$real_C, dataTrain$predicted_glm_C))
  
  result <- rbind(result, data.frame(
    size.train=prob, 
    error.glm.test=prediction_error(dataTest$real_C, dataTest$predicted_glm_C),
    error.glm.train=prediction_error(dataTrain$real_C, dataTrain$predicted_glm_C),
    error.glm.test.1=prediction_error(dataTest$real_C == "1", dataTest$predicted_glm_C == "1"),
    error.glm.train.1=prediction_error(dataTrain$real_C == "1", dataTrain$predicted_glm_C == "1"),
    error.glm.test.2=prediction_error(dataTest$real_C == "2", dataTest$predicted_glm_C == "2"),
    error.glm.train.2=prediction_error(dataTrain$real_C == "2", dataTrain$predicted_glm_C == "2"),
    error.glm.test.3=prediction_error(dataTest$real_C == "3", dataTest$predicted_glm_C == "3"),
    error.glm.train.3=prediction_error(dataTrain$real_C == "3", dataTrain$predicted_glm_C == "3"),
    error.glm.test.4=prediction_error(dataTest$real_C == "4", dataTest$predicted_glm_C == "4"),
    error.glm.train.4=prediction_error(dataTrain$real_C == "4", dataTrain$predicted_glm_C == "4")
  )
  )
  
}

# Sauvegarde CR erreurs
print(result)

write.csv(result, csv.output.filename)


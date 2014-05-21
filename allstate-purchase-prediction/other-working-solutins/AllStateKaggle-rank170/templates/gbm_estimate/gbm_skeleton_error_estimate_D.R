
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
  
  
  dataTest$predict_glm_1 <- predict(model_1, newdata=dataTest)
  dataTest$predict_glm_2 <- predict(model_2, newdata=dataTest)
  dataTest$predict_glm_3 <- predict(model_3, newdata=dataTest)
  
  dataTest$predicted_glm_D <- factor(max.col(dataTest[,c("predict_glm_1","predict_glm_2","predict_glm_3")]))
  
  dataTrain$predict_glm_1 <- predict(model_1, newdata=dataTrain)
  dataTrain$predict_glm_2 <- predict(model_2, newdata=dataTrain)
  dataTrain$predict_glm_3 <- predict(model_3, newdata=dataTrain)
  
  dataTrain$predicted_glm_D <- factor(max.col(dataTrain[,c("predict_glm_1","predict_glm_2", "predict_glm_3")]))
  
  
  print("Error GLM Test:")
  print(prediction_error(dataTest$real_D, dataTest$predicted_glm_D))
  
  print("Error GLM Train:")
  print(prediction_error(dataTrain$real_D, dataTrain$predicted_glm_D))
  
  result <- rbind(result, data.frame(
    size.train=prob, 
    error.glm.test=prediction_error(dataTest$real_D, dataTest$predicted_glm_D),
    error.glm.train=prediction_error(dataTrain$real_D, dataTrain$predicted_glm_D),
    error.glm.test.1=prediction_error(dataTest$real_D == "1", dataTest$predicted_glm_D == "1"),
    error.glm.train.1=prediction_error(dataTrain$real_D == "1", dataTrain$predicted_glm_D == "1"),
    error.glm.test.2=prediction_error(dataTest$real_D == "2", dataTest$predicted_glm_D == "2"),
    error.glm.train.2=prediction_error(dataTrain$real_D == "2", dataTrain$predicted_glm_D == "2"),
    error.glm.test.3=prediction_error(dataTest$real_D == "3", dataTest$predicted_glm_D == "3"),
    error.glm.train.3=prediction_error(dataTrain$real_D == "3", dataTrain$predicted_glm_D == "3")
  )
  )
  
}

# Sauvegarde CR erreurs
print(result)

write.csv(result, csv.output.filename)


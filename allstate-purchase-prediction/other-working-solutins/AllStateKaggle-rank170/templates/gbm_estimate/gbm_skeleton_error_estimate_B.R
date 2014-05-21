
# Estimation modeles

list_prob <- seq(start.check, end.check, step.check)

result <- data.frame()

for(prob in list_prob) {
  
  cat("Taille train : ", prob, "\n")
  
  tmp <- get.base.train.test(dataTrainBase, y.variable, prob)
  dataTrain <- tmp$train
  
  # Evaluation modeles
  print("Entrainement modele GLM 0")
  model_0 <- glm(
    formula_0
    , family = binomial, data=dataTrain)
  
  print("Entrainement modele GLM 1")
  model_1 <- glm(
    formula_1
    , family = binomial, data=dataTrain)
  
  
  dataTest$predict_glm_0 <- predict(model_0, newdata=dataTest)
  dataTest$predict_glm_1 <- predict(model_1, newdata=dataTest)
  
  dataTest$predicted_glm_B <- factor(max.col(dataTest[,c("predict_glm_0","predict_glm_1")])-1)
  
  dataTrain$predict_glm_0 <- predict(model_0, newdata=dataTrain)
  dataTrain$predict_glm_1 <- predict(model_1, newdata=dataTrain)
  
  dataTrain$predicted_glm_B <- factor(max.col(dataTrain[,c("predict_glm_0","predict_glm_1")])-1)
  
  
  print("Error GLM Test:")
  print(prediction_error(dataTest$real_B, dataTest$predicted_glm_B))
  
  print("Error GLM Train:")
  print(prediction_error(dataTrain$real_B, dataTrain$predicted_glm_B))
  
  result <- rbind(result, data.frame(
    size.train=prob, 
    error.glm.test=prediction_error(dataTest$real_B, dataTest$predicted_glm_B),
    error.glm.train=prediction_error(dataTrain$real_B, dataTrain$predicted_glm_B),
    error.glm.test.0=prediction_error(dataTest$real_B == "0", dataTest$predicted_glm_B == "0"),
    error.glm.train.0=prediction_error(dataTrain$real_B == "0", dataTrain$predicted_glm_B == "0"),
    error.glm.test.1=prediction_error(dataTest$real_B == "1", dataTest$predicted_glm_B == "1"),
    error.glm.train.1=prediction_error(dataTrain$real_B == "1", dataTrain$predicted_glm_B == "1")
  )
  )
  
}

# Sauvegarde CR erreurs
print(result)

write.csv(result, csv.output.filename)


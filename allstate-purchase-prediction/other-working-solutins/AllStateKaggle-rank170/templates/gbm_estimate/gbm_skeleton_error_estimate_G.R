
# Estimation modeles

list_prob <- seq(start.check, end.check, step.check)

result <- data.frame()

for(prob in list_prob) {
  
  cat("Taille train : ", prob, "\n")
  
  tmp <- get.base.train.test(dataTrainBase, y.variable, prob)
  dataTrain <- tmp$train
  
  # Evaluation modeles
  print("Entrainement modele GBM")
  model_gbm <- gbm(
    formula_gbm, data=dataTrain, n.trees=1000, verbose=TRUE)
  
  prediction_test <- predict(model_gbm, newdata=dataTest, n.trees=1000)
  
  dataTest$predicted_glm_G <- max.col(data.frame(prediction_test))
  
  prediction_train <- predict(model_gbm, newdata=dataTrain, n.trees=1000)
  
  dataTrain$predicted_glm_G <- max.col(data.frame(prediction_train))
  
  
  print("Error GLM Test:")
  print(prediction_error(dataTest$real_G, dataTest$predicted_glm_G))
  
  print("Error GLM Train:")
  print(prediction_error(dataTrain$real_G, dataTrain$predicted_glm_G))
  
  result <- rbind(result, data.frame(
    size.train=prob, 
    error.glm.test=prediction_error(dataTest$real_G, dataTest$predicted_glm_G),
    error.glm.train=prediction_error(dataTrain$real_G, dataTrain$predicted_glm_G),
    error.glm.test.1=prediction_error(dataTest$real_G == "1", dataTest$predicted_glm_G == "1"),
    error.glm.train.1=prediction_error(dataTrain$real_G == "1", dataTrain$predicted_glm_G == "1"),
    error.glm.test.2=prediction_error(dataTest$real_G == "2", dataTest$predicted_glm_G == "2"),
    error.glm.train.2=prediction_error(dataTrain$real_G == "2", dataTrain$predicted_glm_G == "2"),
    error.glm.test.3=prediction_error(dataTest$real_G == "3", dataTest$predicted_glm_G == "3"),
    error.glm.train.3=prediction_error(dataTrain$real_G == "3", dataTrain$predicted_glm_G == "3"),
    error.glm.test.4=prediction_error(dataTest$real_G == "4", dataTest$predicted_glm_G == "4"),
    error.glm.train.4=prediction_error(dataTrain$real_G == "4", dataTrain$predicted_glm_G == "4")
  )
  )
  
}

# Sauvegarde CR erreurs
print(result)

write.csv(result, csv.output.filename)


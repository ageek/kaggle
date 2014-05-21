
# Estimation modeles

list_prob <- seq(start.check, end.check, step.check)

result <- data.frame()

for(prob in list_prob) {
  cat("Taille train : ", prob, "\n")
  
  tmp <- get.base.train.test(dataTrainBase, y.variable, prob)
  dataTrain <- tmp$train
  
  # Evaluation modeles
  print("Entrainement modele RF")
  model_rf <- randomForest(
    formula_rf, 
    data=dataTrain,
    ntree=150,
    importance=TRUE,
    do.trace=TRUE
  )
  
  prediction_test <- predict(model_rf, newdata=dataTest)
  
  dataTest$predicted_rf_B <- prediction_test
  
  prediction_train <- predict(model_rf, newdata=dataTrain)
  
  dataTrain$predicted_rf_B <- prediction_train
  
  print("Error RF Test:")
  print(prediction_error(dataTest$real_B, dataTest$predicted_rf_B))
  
  print("Error RF Train:")
  print(prediction_error(dataTrain$real_B, dataTrain$predicted_rf_B))
  
  df.importance <- data.frame(model_rf$importance)
  write.csv(x=df.importance, file=file.path("DATA","OUTPUT","model_rf_importance_B.csv"))
  
  result <- rbind(result, data.frame(
    size.train=prob, 
    error.rf.test=prediction_error(dataTest$real_B, dataTest$predicted_rf_B),
    error.rf.train=prediction_error(dataTrain$real_B, dataTrain$predicted_rf_B),
    error.rf.test.0=prediction_error(dataTest$real_B == "0", dataTest$predicted_rf_B == "0"),
    error.rf.train.0=prediction_error(dataTrain$real_B == "0", dataTrain$predicted_rf_B == "0"),
    error.rf.test.1=prediction_error(dataTest$real_B == "1", dataTest$predicted_rf_B == "1"),
    error.rf.train.1=prediction_error(dataTrain$real_B == "1", dataTrain$predicted_rf_B == "1")
  )
  )
  
}

# Sauvegarde CR erreurs
print(result)

write.csv(result, csv.output.filename)


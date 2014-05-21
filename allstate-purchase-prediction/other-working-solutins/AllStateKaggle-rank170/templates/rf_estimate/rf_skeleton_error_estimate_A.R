library(randomForest)

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
  
  dataTest$predicted_rf_A <- prediction_test
  
  prediction_train <- predict(model_rf, newdata=dataTrain)
  
  dataTrain$predicted_rf_A <- prediction_train
  
  print("Error RF Test:")
  print(prediction_error(dataTest$real_A, dataTest$predicted_rf_A))
  
  print("Error RF Train:")
  print(prediction_error(dataTrain$real_A, dataTrain$predicted_rf_A))
  
  df.importance <- data.frame(model_rf$importance)
  write.csv(x=df.importance, file=file.path("DATA","OUTPUT","model_rf_importance_A.csv"))
  
  result <- rbind(result, data.frame(
    size.train=prob, 
    error.rf.test=prediction_error(dataTest$real_A, dataTest$predicted_rf_A),
    error.rf.train=prediction_error(dataTrain$real_A, dataTrain$predicted_rf_A),
    error.rf.test.0=prediction_error(dataTest$real_A == "0", dataTest$predicted_rf_A == "0"),
    error.rf.train.0=prediction_error(dataTrain$real_A == "0", dataTrain$predicted_rf_A == "0"),
    error.rf.test.1=prediction_error(dataTest$real_A == "1", dataTest$predicted_rf_A == "1"),
    error.rf.train.1=prediction_error(dataTrain$real_A == "1", dataTrain$predicted_rf_A == "1"),
    error.rf.test.2=prediction_error(dataTest$real_A == "2", dataTest$predicted_rf_A == "2"),
    error.rf.train.2=prediction_error(dataTrain$real_A == "2", dataTrain$predicted_rf_A == "2")
  )
  )
  
}

# Sauvegarde CR erreurs
print(result)

write.csv(result, csv.output.filename)



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
  
  dataTest$predicted_rf_C <- prediction_test
  
  prediction_train <- predict(model_rf, newdata=dataTrain)
  
  dataTrain$predicted_rf_C <- prediction_train
  
  print("Error RF Test:")
  print(prediction_error(dataTest$real_C, dataTest$predicted_rf_C))
  
  print("Error RF Train:")
  print(prediction_error(dataTrain$real_C, dataTrain$predicted_rf_C))
  
  df.importance <- data.frame(model_rf$importance)
  write.csv(x=df.importance, file=file.path("DATA","OUTPUT","model_rf_importance_C.csv"))
    
  result <- rbind(result, data.frame(
    size.train=prob, 
    error.rf.test=prediction_error(dataTest$real_C, dataTest$predicted_rf_C),
    error.rf.train=prediction_error(dataTrain$real_C, dataTrain$predicted_rf_C),
    error.rf.test.1=prediction_error(dataTest$real_C == "1", dataTest$predicted_rf_C == "1"),
    error.rf.train.1=prediction_error(dataTrain$real_C == "1", dataTrain$predicted_rf_C == "1"),
    error.rf.test.2=prediction_error(dataTest$real_C == "2", dataTest$predicted_rf_C == "2"),
    error.rf.train.2=prediction_error(dataTrain$real_C == "2", dataTrain$predicted_rf_C == "2"),
    error.rf.test.3=prediction_error(dataTest$real_C == "3", dataTest$predicted_rf_C == "3"),
    error.rf.train.3=prediction_error(dataTrain$real_C == "3", dataTrain$predicted_rf_C == "3"),
    error.rf.test.4=prediction_error(dataTest$real_C == "4", dataTest$predicted_rf_C == "4"),
    error.rf.train.4=prediction_error(dataTrain$real_C == "4", dataTrain$predicted_rf_C == "4")
  )
  )
  
}

# Sauvegarde CR erreurs
print(result)

write.csv(result, csv.output.filename)


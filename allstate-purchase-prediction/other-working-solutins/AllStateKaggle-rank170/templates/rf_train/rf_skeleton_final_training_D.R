# Entrainement final
print("Entrainement modele RF final D")
model_rf_final_D <- randomForest(
  formula_rf, 
  data=dataTrainBase,
  ntree=150,
  importance=TRUE,
  do.trace=TRUE
)

prediction_train <- predict(model_rf, newdata=dataTrainBase)

dataTrainBase$predicted_rf_D <- prediction_train

print(table(dataTrainBase$predicted_rf_D))

# Sauvegarde des modeles
save(model_rf_final_D, file=RData.output.filename)

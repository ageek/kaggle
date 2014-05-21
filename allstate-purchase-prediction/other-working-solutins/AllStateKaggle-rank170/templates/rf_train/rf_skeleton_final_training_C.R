# Entrainement final
print("Entrainement modele RF final C")
model_rf_final_C <- randomForest(
  formula_rf, 
  data=dataTrainBase,
  ntree=150,
  importance=TRUE,
  do.trace=TRUE
)

prediction_train <- predict(model_rf, newdata=dataTrainBase)

dataTrainBase$predicted_rf_C <- prediction_train

print(table(dataTrainBase$predicted_rf_C))

# Sauvegarde des modeles
save(model_rf_final_C, file=RData.output.filename)

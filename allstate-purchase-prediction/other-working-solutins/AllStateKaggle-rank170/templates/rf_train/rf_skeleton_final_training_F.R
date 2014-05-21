# Entrainement final
print("Entrainement modele RF final F")
model_rf_final_F <- randomForest(
  formula_rf, 
  data=dataTrainBase,
  ntree=150,
  importance=TRUE,
  do.trace=TRUE
)

prediction_train <- predict(model_rf, newdata=dataTrainBase)

dataTrainBase$predicted_rf_F <- prediction_train

print(table(dataTrainBase$predicted_rf_F))

# Sauvegarde des modeles
save(model_rf_final_F, file=RData.output.filename)

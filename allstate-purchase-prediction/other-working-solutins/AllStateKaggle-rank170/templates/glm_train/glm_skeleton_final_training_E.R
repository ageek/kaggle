dataAll <- rbind(dataTrainBase, dataTest)

# Entrainement final
print("Entrainement modele GLM 0 final")
model_0_final_E <- glm(
  formula_0
  , family = binomial, data=dataAll, trace=TRUE)

print("Entrainement modele GLM 1 final")
model_1_final_E <- glm(
  formula_1
  , family = binomial, data=dataAll, trace=TRUE)

dataAll$predict_glm_0 <- predict(model_0_final_E, newdata=dataAll)
dataAll$predict_glm_1 <- predict(model_1_final_E, newdata=dataAll)

dataAll$predicted_glm_E <- factor(max.col(dataAll[,c("predict_glm_0","predict_glm_1")])-1)

print(table(dataAll$predicted_glm_E))

# Sauvegarde des modeles
save(model_0_final_E, model_1_final_E, file=RData.output.filename)

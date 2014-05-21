dataAll <- rbind(dataTrainBase, dataTest)

# Entrainement final
print("Entrainement modele GLM 0 final")
model_0_final_B <- glm(
  formula_0
  , family = binomial, data=dataAll, trace=TRUE)

print("Entrainement modele GLM 1 final")
model_1_final_B <- glm(
  formula_1
  , family = binomial, data=dataAll, trace=TRUE)

dataAll$predict_glm_0 <- predict(model_0_final_B, newdata=dataAll)
dataAll$predict_glm_1 <- predict(model_1_final_B, newdata=dataAll)

dataAll$predicted_glm_B <- factor(max.col(dataAll[,c("predict_glm_0","predict_glm_1")])-1)

print(table(dataAll$predicted_glm_B))

# Sauvegarde des modeles
save(model_0_final_B, model_1_final_B, file=RData.output.filename)

dataAll <- rbind(dataTrainBase, dataTest)

# Entrainement final
print("Entrainement modele GLM 0 final")
model_0_final_F <- glm(
  formula_0
  , family = binomial, data=dataAll, trace=TRUE)

print("Entrainement modele GLM 1 final")
model_1_final_F <- glm(
  formula_1
  , family = binomial, data=dataAll, trace=TRUE)

print("Entrainement modele GLM 2 final")
model_2_final_F <- glm(
  formula_2
  , family = binomial, data=dataAll, trace=TRUE)

print("Entrainement modele GLM 3 final")
model_3_final_F <- glm(
  formula_3
  , family = binomial, data=dataAll, trace=TRUE)

dataAll$predict_glm_0 <- predict(model_0_final_F, newdata=dataAll)
dataAll$predict_glm_1 <- predict(model_1_final_F, newdata=dataAll)
dataAll$predict_glm_2 <- predict(model_2_final_F, newdata=dataAll)
dataAll$predict_glm_3 <- predict(model_3_final_F, newdata=dataAll)

dataAll$predicted_glm_F <- factor(max.col(dataAll[,c("predict_glm_0","predict_glm_1","predict_glm_2","predict_glm_3")])-1)

print(table(dataAll$predicted_glm_F))

# Sauvegarde des modeles
save(model_0_final_F, model_1_final_F, model_2_final_F, model_3_final_F, file=RData.output.filename)

dataAll <- rbind(dataTrainBase, dataTest)

# Entrainement final
print("Entrainement modele GLM 1 final")
model_1_final_D <- glm(
  formula_1
  , family = binomial, data=dataAll, trace=TRUE)

print("Entrainement modele GLM 2 final")
model_2_final_D <- glm(
  formula_2
  , family = binomial, data=dataAll, trace=TRUE)

print("Entrainement modele GLM 3 final")
model_3_final_D <- glm(
  formula_3
  , family = binomial, data=dataAll, trace=TRUE)

dataAll$predict_glm_1 <- predict(model_1_final_D, newdata=dataAll)
dataAll$predict_glm_2 <- predict(model_2_final_D, newdata=dataAll)
dataAll$predict_glm_3 <- predict(model_3_final_D, newdata=dataAll)

dataAll$predicted_glm_D <- factor(max.col(dataAll[,c("predict_glm_1","predict_glm_2","predict_glm_3")]))

print(table(dataAll$predicted_glm_D))

# Sauvegarde des modeles
save(model_1_final_D, model_2_final_D, model_3_final_D, file=RData.output.filename)

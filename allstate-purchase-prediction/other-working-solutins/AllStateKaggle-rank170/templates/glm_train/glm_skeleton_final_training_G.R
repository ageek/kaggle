dataAll <- rbind(dataTrainBase, dataTest)

# Entrainement final
print("Entrainement modele GLM 1 final")
model_1_final_G <- glm(
  formula_1
  , family = binomial, data=dataAll, trace=TRUE)

print("Entrainement modele GLM 2 final")
model_2_final_G <- glm(
  formula_2
  , family = binomial, data=dataAll, trace=TRUE)

print("Entrainement modele GLM 3 final")
model_3_final_G <- glm(
  formula_3
  , family = binomial, data=dataAll, trace=TRUE)

print("Entrainement modele GLM 4 final")
model_4_final_G <- glm(
  formula_4
  , family = binomial, data=dataAll, trace=TRUE)

dataAll$predict_glm_1 <- predict(model_1_final_G, newdata=dataAll)
dataAll$predict_glm_2 <- predict(model_2_final_G, newdata=dataAll)
dataAll$predict_glm_3 <- predict(model_3_final_G, newdata=dataAll)
dataAll$predict_glm_4 <- predict(model_4_final_G, newdata=dataAll)

dataAll$predicted_glm_G <- factor(max.col(dataAll[,c("predict_glm_1","predict_glm_2","predict_glm_3","predict_glm_4")]))

print(table(dataAll$predicted_glm_G))

# Sauvegarde des modeles
save(model_1_final_G, model_2_final_G, model_3_final_G, model_4_final_G, file=RData.output.filename)

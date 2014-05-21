library(e1071)

# Estimation modeles

list_prob <- seq(start.check, end.check, step.check)

result <- data.frame()

for(prob in list_prob) {
  
  cat("Taille train : ", prob, "\n")
  
  tmp <- get.base.train.test(dataTrainBase, y.variable, prob)
  dataTrain <- tmp$train
  
  # Evaluation modeles
  debut <- Sys.time()
  print("Entrainement modele SVM Linear")
  model_svm_linear <- svm(
    formula_svm_linear
    , kernel = "linear", data=dataTrain, cost=.05)
  fin <- Sys.time()
  print(fin-debut)

  debut <- Sys.time()
  print("Entrainement modele SVM Radial")
  model_svm_radial <- svm(
    formula_svm_radial
    , kernel = "radial", data=dataTrain, cost=.05)
  fin <- Sys.time()
  print(fin-debut)
  
  debut <- Sys.time()
  print("Entrainement modele SVM Poly")
  model_svm_polynomial <- svm(
    formula_svm_polynomial
    , kernel = "polynomial", data=dataTrain, cost=.05, degree=2)
  fin <- Sys.time()
  print(fin-debut)
  
  dataTest$predicted_svm_linear_G <- predict(model_svm_linear, newdata=dataTest)
  dataTrain$predicted_svm_linear_G <- predict(model_svm_linear, newdata=dataTrain)
  
  dataTest$predicted_svm_radial_G <- predict(model_svm_radial, newdata=dataTest)
  dataTrain$predicted_svm_radial_G <- predict(model_svm_radial, newdata=dataTrain)  

  dataTest$predicted_svm_polynomial_G <- predict(model_svm_polynomial, newdata=dataTest)
  dataTrain$predicted_svm_polynomial_G <- predict(model_svm_polynomial, newdata=dataTrain)  

  print("Error SVM Linear Test:")
  print(prediction_error(dataTest$real_G, dataTest$predicted_svm_linear_G))
  print("Error SVM Radial Test:")
  print(prediction_error(dataTest$real_G, dataTest$predicted_svm_radial_G))
  print("Error SVM Polynomial Test:")
  print(prediction_error(dataTest$real_G, dataTest$predicted_svm_polynomial_G))
  
  print("Error SVL Linear Train:")
  print(prediction_error(dataTrain$real_G, dataTrain$predicted_svm_linear_G))
  print("Error SVM Radial Train:")
  print(prediction_error(dataTrain$real_G, dataTrain$predicted_svm_radial_G))
  print("Error SVM Polynomial Train:")
  print(prediction_error(dataTrain$real_G, dataTrain$predicted_svm_polynomial_G))
  
  result <- rbind(result, data.frame(
    size.train=prob, 
    error.glm.test=prediction_error(dataTest$real_G, dataTest$predicted_glm_G),
    error.glm.train=prediction_error(dataTrain$real_G, dataTrain$predicted_glm_G),
    error.glm.test.1=prediction_error(dataTest$real_G == "1", dataTest$predicted_glm_G == "1"),
    error.glm.train.1=prediction_error(dataTrain$real_G == "1", dataTrain$predicted_glm_G == "1"),
    error.glm.test.2=prediction_error(dataTest$real_G == "2", dataTest$predicted_glm_G == "2"),
    error.glm.train.2=prediction_error(dataTrain$real_G == "2", dataTrain$predicted_glm_G == "2"),
    error.glm.test.3=prediction_error(dataTest$real_G == "3", dataTest$predicted_glm_G == "3"),
    error.glm.train.3=prediction_error(dataTrain$real_G == "3", dataTrain$predicted_glm_G == "3"),
    error.glm.test.4=prediction_error(dataTest$real_G == "4", dataTest$predicted_glm_G == "4"),
    error.glm.train.4=prediction_error(dataTrain$real_G == "4", dataTrain$predicted_glm_G == "4")
  )
  )
  
}

# Sauvegarde CR erreurs
print(result)

write.csv(result, csv.output.filename)


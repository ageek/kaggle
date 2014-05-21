library(caret)
library(randomForest)

# fonctions
source(file.path("templates", "functions.R"))

# Chargement des données d'entrainement
source(file.path("templates", "get_data_glm_model.R"))

# Funcions
predict_A <- function(data) {
  load(file=file.path("DATA","OUTPUT","first_model_glm_all_clusters_A.RData"))
  
  tmp <- data.frame(
    predict_glm_0 = predict(model_0_final_A, newdata=data),
    predict_glm_1 = predict(model_1_final_A, newdata=data),
    predict_glm_2 = predict(model_2_final_A, newdata=data)
  )
  
  return(factor(max.col(tmp[,c("predict_glm_0","predict_glm_1", "predict_glm_2")])-1))
  
}

predict_B <- function(data) {
  load(file=file.path("DATA","OUTPUT","first_model_glm_all_clusters_B.RData"))
  
  tmp <- data.frame(
    predict_glm_0 = predict(model_0_final_B, newdata=data),
    predict_glm_1 = predict(model_1_final_B, newdata=data)
  )
  
  return(factor(max.col(tmp[,c("predict_glm_0","predict_glm_1")])-1))
  
}

predict_C <- function(data) {
  load(file=file.path("DATA","OUTPUT","first_model_glm_all_clusters_C.RData"))
  
  tmp <- data.frame(
    predict_glm_1 = predict(model_1_final_C, newdata=data),
    predict_glm_2 = predict(model_2_final_C, newdata=data),
    predict_glm_3 = predict(model_3_final_C, newdata=data),
    predict_glm_4 = predict(model_4_final_C, newdata=data)
  )
  
  return(factor(max.col(tmp[,c("predict_glm_1","predict_glm_2", "predict_glm_3", 'predict_glm_4')])))
  
}

predict_D <- function(data) {
  load(file=file.path("DATA","OUTPUT","first_model_glm_all_clusters_D.RData"))
  
  tmp <- data.frame(
    predict_glm_1 = predict(model_1_final_D, newdata=data),
    predict_glm_2 = predict(model_2_final_D, newdata=data),
    predict_glm_3 = predict(model_3_final_D, newdata=data)
  )
  
  return(factor(max.col(tmp[,c("predict_glm_1","predict_glm_2", "predict_glm_3")])))
  
}

predict_E <- function(data) {
  load(file=file.path("DATA","OUTPUT","first_model_glm_all_clusters_E.RData"))
  
  tmp <- data.frame(
    predict_glm_0 = predict(model_0_final_E, newdata=data),
    predict_glm_1 = predict(model_1_final_E, newdata=data)
  )
  
  return(factor(max.col(tmp[,c("predict_glm_0","predict_glm_1")])-1))
  
}

predict_F <- function(data) {
  load(file=file.path("DATA","OUTPUT","first_model_glm_all_clusters_F.RData"))
  
  tmp <- data.frame(
    predict_glm_0 = predict(model_0_final_F, newdata=data),
    predict_glm_1 = predict(model_1_final_F, newdata=data),
    predict_glm_2 = predict(model_2_final_F, newdata=data),
    predict_glm_3 = predict(model_3_final_F, newdata=data)
  )
  
  return(factor(max.col(tmp[,c("predict_glm_0","predict_glm_1","predict_glm_2","predict_glm_3")])-1))
  
}

predict_G <- function(data) {
  load(file=file.path("DATA","OUTPUT","first_model_glm_all_clusters_G.RData"))
  
  tmp <- data.frame(
    predict_glm_1 = predict(model_1_final_G, newdata=data),
    predict_glm_2 = predict(model_2_final_G, newdata=data),
    predict_glm_3 = predict(model_3_final_G, newdata=data),
    predict_glm_4 = predict(model_4_final_G, newdata=data)
  )
  
  return(factor(max.col(tmp[,c("predict_glm_1","predict_glm_2","predict_glm_3","predict_glm_4")])))
  
}

predict_ALL <- function(data) {
  print("predicting A...")
  data$predicted_A <- predict_A(data)
  print("predicting B...")
  data$predicted_B <- predict_B(data)
  print("predicting C...")
  data$predicted_C <- predict_C(data)
  print("predicting D...")
  data$predicted_D <- predict_D(data)
  print("predicting E...")
  data$predicted_E <- predict_E(data)
  print("predicting F...")
  data$predicted_F <- predict_F(data)
  print("predicting G...")
  data$predicted_G <- predict_G(data)
  
  return(data)
}

# Separation train, test
set.seed(42)
data <- train.data
tmp <- get.base.train.test(data, "real_G", .8)

dataTrainBase <- tmp$train
dataTestBase <- tmp$test

dataTrainBase <- predict_ALL(dataTrainBase)
dataTestBase <- predict_ALL(dataTestBase)

write.csv(dataTrainBase, file=file.path("DATA","train_first_model_glm_all_clusters_prediction_v6.csv"))
write.csv(dataTestBase, file=file.path("DATA","test_first_model_glm_all_clusters_prediction_v6.csv"))

# Separation train, test
set.seed(42)
dataTest <- get.data.glm.model.test()
dataTest <- normalize.test.data(dataTest)

# Prediction globale
dataTest <- predict_ALL(dataTest)

dataTest$predicted_ABCDEF <- paste(
  as.character(dataTest$predicted_A),
  as.character(dataTest$predicted_B),
  as.character(dataTest$predicted_C),
  as.character(dataTest$predicted_D),
  as.character(dataTest$predicted_E),
  as.character(dataTest$predicted_F),
  sep=""
)

dataTest$predicted_ABCDEFG <- paste(
  as.character(dataTest$predicted_A),
  as.character(dataTest$predicted_B),
  as.character(dataTest$predicted_C),
  as.character(dataTest$predicted_D),
  as.character(dataTest$predicted_E),
  as.character(dataTest$predicted_F),
  as.character(dataTest$predicted_G),
  sep=""
)

dataTest$plan <- dataTest$predicted_ABCDEFG

df.submission <- cbind(rownames(dataTest), dataTest$plan)
colnames(df.submission) <- c("customer_ID","plan")
submission.filename <- file.path("DATA", "first_model_glm_all_clusters_submission_v6.csv")
write.table(df.submission, file = submission.filename, quote = FALSE, sep=",", row.names = FALSE, col.names=TRUE)

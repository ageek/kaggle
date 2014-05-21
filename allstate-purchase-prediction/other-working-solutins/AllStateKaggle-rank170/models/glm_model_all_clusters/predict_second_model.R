source(file.path("templates", "functions.R"))

# Préparation des données
# train.data <- read.csv(file=file.path("DATA","TMP", "glm_train_data.csv"))
# train.data <- normalize.train.data(train.data, with.location=TRUE, with.risk.factor=TRUE)

test.data <- read.csv(file=file.path("DATA","TMP", "glm_test_data.csv"))

test.data.with.location.with.risk.factor <- normalize.test.data(test.data, with.location=TRUE, with.risk.factor=TRUE)
test.data.with.location.without.risk.factor <- normalize.test.data(test.data, with.location=TRUE, with.risk.factor=FALSE)
test.data.without.location.with.risk.factor <- normalize.test.data(test.data, with.location=FALSE, with.risk.factor=TRUE)
test.data.without.location.without.risk.factor <- normalize.test.data(test.data, with.location=FALSE, with.risk.factor=FALSE)

############################# prediction with location with risk factor ########################
# A with location with risk
print("prediction with location with risk factor A")
load(file.path("DATA","OUTPUT","first_model_glm_all_clusters_with_location_with_risk_factor_A.RData"))

test.data.with.location.with.risk.factor$predict_A_0 <- predict(
    model_0_final_A, newdata=test.data.with.location.with.risk.factor
  )

test.data.with.location.with.risk.factor$predict_A_1 <- predict(
  model_1_final_A, newdata=test.data.with.location.with.risk.factor
)

test.data.with.location.with.risk.factor$predict_A_2 <- predict(
  model_2_final_A, newdata=test.data.with.location.with.risk.factor
)

test.data.with.location.with.risk.factor$predict_A <- 
  factor(max.col(
    test.data.with.location.with.risk.factor[,c("predict_A_0","predict_A_1", "predict_A_2")])-1)

rm(list=c("model_0_final_A", "model_1_final_A", "model_2_final_A"))

# B with location with risk
print("prediction with location with risk factor B")
load(file.path("DATA","OUTPUT","first_model_glm_all_clusters_with_location_with_risk_factor_B.RData"))

test.data.with.location.with.risk.factor$predict_B_0 <- predict(
  model_0_final_B, newdata=test.data.with.location.with.risk.factor
)

test.data.with.location.with.risk.factor$predict_B_1 <- predict(
  model_1_final_B, newdata=test.data.with.location.with.risk.factor
)

test.data.with.location.with.risk.factor$predict_B <- 
  factor(max.col(
    test.data.with.location.with.risk.factor[,c("predict_B_0","predict_B_1")])-1)

rm(list=c("model_0_final_B", "model_1_final_B"))

# C with location with risk
print("prediction with location with risk factor C")
load(file.path("DATA","OUTPUT","first_model_glm_all_clusters_with_location_with_risk_factor_C.RData"))

test.data.with.location.with.risk.factor$predict_C_1 <- predict(
  model_1_final_C, newdata=test.data.with.location.with.risk.factor
)

test.data.with.location.with.risk.factor$predict_C_2 <- predict(
  model_2_final_C, newdata=test.data.with.location.with.risk.factor
)

test.data.with.location.with.risk.factor$predict_C_3 <- predict(
  model_3_final_C, newdata=test.data.with.location.with.risk.factor
)

test.data.with.location.with.risk.factor$predict_C_4 <- predict(
  model_4_final_C, newdata=test.data.with.location.with.risk.factor
)

test.data.with.location.with.risk.factor$predict_C <- 
  factor(max.col(
    test.data.with.location.with.risk.factor[,c("predict_C_1","predict_C_2", "predict_C_3", "predict_C_4")]))

rm(list=c("model_1_final_C", "model_2_final_C", "model_3_final_C", "model_4_final_C"))

# D with location with risk
print("prediction with location with risk factor D")
load(file.path("DATA","OUTPUT","first_model_glm_all_clusters_with_location_with_risk_factor_D.RData"))

test.data.with.location.with.risk.factor$predict_D_1 <- predict(
  model_1_final_D, newdata=test.data.with.location.with.risk.factor
)

test.data.with.location.with.risk.factor$predict_D_2 <- predict(
  model_2_final_D, newdata=test.data.with.location.with.risk.factor
)

test.data.with.location.with.risk.factor$predict_D_3 <- predict(
  model_3_final_D, newdata=test.data.with.location.with.risk.factor
)

test.data.with.location.with.risk.factor$predict_D <- 
  factor(max.col(
    test.data.with.location.with.risk.factor[,c("predict_D_1","predict_D_2", "predict_D_3")]))

rm(list=c("model_1_final_D", "model_2_final_D", "model_3_final_D"))

# E with location with risk
print("prediction with location with risk factor E")
load(file.path("DATA","OUTPUT","first_model_glm_all_clusters_with_location_with_risk_factor_E.RData"))

test.data.with.location.with.risk.factor$predict_E_0 <- predict(
  model_0_final_E, newdata=test.data.with.location.with.risk.factor
)

test.data.with.location.with.risk.factor$predict_E_1 <- predict(
  model_1_final_E, newdata=test.data.with.location.with.risk.factor
)

test.data.with.location.with.risk.factor$predict_E <- 
  factor(max.col(
    test.data.with.location.with.risk.factor[,c("predict_E_0","predict_E_1")])-1)

rm(list=c("model_0_final_E", "model_1_final_E"))

# F with location with risk
print("prediction with location with risk factor F")
load(file.path("DATA","OUTPUT","first_model_glm_all_clusters_with_location_with_risk_factor_F.RData"))

test.data.with.location.with.risk.factor$predict_F_0 <- predict(
  model_0_final_F, newdata=test.data.with.location.with.risk.factor
)

test.data.with.location.with.risk.factor$predict_F_1 <- predict(
  model_1_final_F, newdata=test.data.with.location.with.risk.factor
)

test.data.with.location.with.risk.factor$predict_F_2 <- predict(
  model_2_final_F, newdata=test.data.with.location.with.risk.factor
)

test.data.with.location.with.risk.factor$predict_F_3 <- predict(
  model_3_final_F, newdata=test.data.with.location.with.risk.factor
)

test.data.with.location.with.risk.factor$predict_F <- 
  factor(max.col(
    test.data.with.location.with.risk.factor[,c("predict_F_0","predict_F_1","predict_F_2","predict_F_3")])-1)

rm(list=c("model_0_final_F", "model_1_final_F", "model_2_final_F", "model_3_final_F"))

# G with location with risk
print("prediction with location with risk factor G")
load(file.path("DATA","OUTPUT","first_model_glm_all_clusters_with_location_with_risk_factor_G.RData"))

test.data.with.location.with.risk.factor$predict_G_1 <- predict(
  model_1_final_G, newdata=test.data.with.location.with.risk.factor
)

test.data.with.location.with.risk.factor$predict_G_2 <- predict(
  model_2_final_G, newdata=test.data.with.location.with.risk.factor
)

test.data.with.location.with.risk.factor$predict_G_3 <- predict(
  model_3_final_G, newdata=test.data.with.location.with.risk.factor
)

test.data.with.location.with.risk.factor$predict_G_4 <- predict(
  model_4_final_G, newdata=test.data.with.location.with.risk.factor
)

test.data.with.location.with.risk.factor$predict_G <- 
  factor(max.col(
    test.data.with.location.with.risk.factor[,c("predict_G_1","predict_G_2","predict_G_3","predict_G_4")]))

rm(list=c("model_1_final_G", "model_2_final_G", "model_3_final_G", "model_4_final_G"))

# final with location with risk factor
print("prediction with location with risk factor ABCDEFG")
test.data.with.location.with.risk.factor$predict_ABCDEFG <-
  with(test.data.with.location.with.risk.factor,
       paste(
         as.character(predict_A),
         as.character(predict_B),
         as.character(predict_C),
         as.character(predict_D),
         as.character(predict_E),
         as.character(predict_F),
         as.character(predict_G),
         sep=""
         )
       )

############################# prediction with location without risk factor ########################
# A with location without risk
print("prediction with location without risk factor A")
load(file.path("DATA","OUTPUT","first_model_glm_all_clusters_with_location_without_risk_factor_A.RData"))

test.data.with.location.without.risk.factor$predict_A_0 <- predict(
  model_0_final_A, newdata=test.data.with.location.without.risk.factor
)

test.data.with.location.without.risk.factor$predict_A_1 <- predict(
  model_1_final_A, newdata=test.data.with.location.without.risk.factor
)

test.data.with.location.without.risk.factor$predict_A_2 <- predict(
  model_2_final_A, newdata=test.data.with.location.without.risk.factor
)

test.data.with.location.without.risk.factor$predict_A <- 
  factor(max.col(
    test.data.with.location.without.risk.factor[,c("predict_A_0","predict_A_1", "predict_A_2")])-1)

rm(list=c("model_0_final_A", "model_1_final_A", "model_2_final_A"))

# B with location without risk
print("prediction with location without risk factor B")
load(file.path("DATA","OUTPUT","first_model_glm_all_clusters_with_location_without_risk_factor_B.RData"))

test.data.with.location.without.risk.factor$predict_B_0 <- predict(
  model_0_final_B, newdata=test.data.with.location.without.risk.factor
)

test.data.with.location.without.risk.factor$predict_B_1 <- predict(
  model_1_final_B, newdata=test.data.with.location.without.risk.factor
)

test.data.with.location.without.risk.factor$predict_B <- 
  factor(max.col(
    test.data.with.location.without.risk.factor[,c("predict_B_0","predict_B_1")])-1)

rm(list=c("model_0_final_B", "model_1_final_B"))

# C with location without risk
print("prediction with location without risk factor C")
load(file.path("DATA","OUTPUT","first_model_glm_all_clusters_with_location_without_risk_factor_C.RData"))

test.data.with.location.without.risk.factor$predict_C_1 <- predict(
  model_1_final_C, newdata=test.data.with.location.without.risk.factor
)

test.data.with.location.without.risk.factor$predict_C_2 <- predict(
  model_2_final_C, newdata=test.data.with.location.without.risk.factor
)

test.data.with.location.without.risk.factor$predict_C_3 <- predict(
  model_3_final_C, newdata=test.data.with.location.without.risk.factor
)

test.data.with.location.without.risk.factor$predict_C_4 <- predict(
  model_4_final_C, newdata=test.data.with.location.without.risk.factor
)

test.data.with.location.without.risk.factor$predict_C <- 
  factor(max.col(
    test.data.with.location.without.risk.factor[,c("predict_C_1","predict_C_2", "predict_C_3", "predict_C_4")]))

rm(list=c("model_1_final_C", "model_2_final_C", "model_3_final_C", "model_4_final_C"))

# D with location without risk
print("prediction with location without risk factor D")
load(file.path("DATA","OUTPUT","first_model_glm_all_clusters_with_location_without_risk_factor_D.RData"))

test.data.with.location.without.risk.factor$predict_D_1 <- predict(
  model_1_final_D, newdata=test.data.with.location.without.risk.factor
)

test.data.with.location.without.risk.factor$predict_D_2 <- predict(
  model_2_final_D, newdata=test.data.with.location.without.risk.factor
)

test.data.with.location.without.risk.factor$predict_D_3 <- predict(
  model_3_final_D, newdata=test.data.with.location.without.risk.factor
)

test.data.with.location.without.risk.factor$predict_D <- 
  factor(max.col(
    test.data.with.location.without.risk.factor[,c("predict_D_1","predict_D_2", "predict_D_3")]))

rm(list=c("model_1_final_D", "model_2_final_D", "model_3_final_D"))

# E with location without risk
print("prediction with location without risk factor E")
load(file.path("DATA","OUTPUT","first_model_glm_all_clusters_with_location_without_risk_factor_E.RData"))

test.data.with.location.without.risk.factor$predict_E_0 <- predict(
  model_0_final_E, newdata=test.data.with.location.without.risk.factor
)

test.data.with.location.without.risk.factor$predict_E_1 <- predict(
  model_1_final_E, newdata=test.data.with.location.without.risk.factor
)

test.data.with.location.without.risk.factor$predict_E <- 
  factor(max.col(
    test.data.with.location.without.risk.factor[,c("predict_E_0","predict_E_1")])-1)

rm(list=c("model_0_final_E", "model_1_final_E"))

# F with location without risk
print("prediction with location without risk factor F")
load(file.path("DATA","OUTPUT","first_model_glm_all_clusters_with_location_without_risk_factor_F.RData"))

test.data.with.location.without.risk.factor$predict_F_0 <- predict(
  model_0_final_F, newdata=test.data.with.location.without.risk.factor
)

test.data.with.location.without.risk.factor$predict_F_1 <- predict(
  model_1_final_F, newdata=test.data.with.location.without.risk.factor
)

test.data.with.location.without.risk.factor$predict_F_2 <- predict(
  model_2_final_F, newdata=test.data.with.location.without.risk.factor
)

test.data.with.location.without.risk.factor$predict_F_3 <- predict(
  model_3_final_F, newdata=test.data.with.location.without.risk.factor
)

test.data.with.location.without.risk.factor$predict_F <- 
  factor(max.col(
    test.data.with.location.without.risk.factor[,c("predict_F_0","predict_F_1","predict_F_2","predict_F_3")])-1)

rm(list=c("model_0_final_F", "model_1_final_F", "model_2_final_F", "model_3_final_F"))

# G with location without risk
print("prediction with location without risk factor G")
load(file.path("DATA","OUTPUT","first_model_glm_all_clusters_with_location_without_risk_factor_G.RData"))

test.data.with.location.without.risk.factor$predict_G_1 <- predict(
  model_1_final_G, newdata=test.data.with.location.without.risk.factor
)

test.data.with.location.without.risk.factor$predict_G_2 <- predict(
  model_2_final_G, newdata=test.data.with.location.without.risk.factor
)

test.data.with.location.without.risk.factor$predict_G_3 <- predict(
  model_3_final_G, newdata=test.data.with.location.without.risk.factor
)

test.data.with.location.without.risk.factor$predict_G_4 <- predict(
  model_4_final_G, newdata=test.data.with.location.without.risk.factor
)

test.data.with.location.without.risk.factor$predict_G <- 
  factor(max.col(
    test.data.with.location.without.risk.factor[,c("predict_G_1","predict_G_2","predict_G_3","predict_G_4")]))

rm(list=c("model_1_final_G", "model_2_final_G", "model_3_final_G", "model_4_final_G"))

# final with location without risk factor
print("prediction with location without risk factor ABCDEFG")
test.data.with.location.without.risk.factor$predict_ABCDEFG <-
  with(test.data.with.location.without.risk.factor,
       paste(
         as.character(predict_A),
         as.character(predict_B),
         as.character(predict_C),
         as.character(predict_D),
         as.character(predict_E),
         as.character(predict_F),
         as.character(predict_G),
         sep=""
       )
  )

############################# prediction without location with risk factor ########################
# A without location with risk
print("prediction without location with risk factor A")
load(file.path("DATA","OUTPUT","first_model_glm_all_clusters_without_location_with_risk_factor_A.RData"))

test.data.without.location.with.risk.factor$predict_A_0 <- predict(
  model_0_final_A, newdata=test.data.without.location.with.risk.factor
)

test.data.without.location.with.risk.factor$predict_A_1 <- predict(
  model_1_final_A, newdata=test.data.without.location.with.risk.factor
)

test.data.without.location.with.risk.factor$predict_A_2 <- predict(
  model_2_final_A, newdata=test.data.without.location.with.risk.factor
)

test.data.without.location.with.risk.factor$predict_A <- 
  factor(max.col(
    test.data.without.location.with.risk.factor[,c("predict_A_0","predict_A_1", "predict_A_2")])-1)

rm(list=c("model_0_final_A", "model_1_final_A", "model_2_final_A"))

# B without location with risk
print("prediction without location with risk factor B")
load(file.path("DATA","OUTPUT","first_model_glm_all_clusters_without_location_with_risk_factor_B.RData"))

test.data.without.location.with.risk.factor$predict_B_0 <- predict(
  model_0_final_B, newdata=test.data.without.location.with.risk.factor
)

test.data.without.location.with.risk.factor$predict_B_1 <- predict(
  model_1_final_B, newdata=test.data.without.location.with.risk.factor
)

test.data.without.location.with.risk.factor$predict_B <- 
  factor(max.col(
    test.data.without.location.with.risk.factor[,c("predict_B_0","predict_B_1")])-1)

rm(list=c("model_0_final_B", "model_1_final_B"))

# C without location with risk
print("prediction without location with risk factor C")
load(file.path("DATA","OUTPUT","first_model_glm_all_clusters_without_location_with_risk_factor_C.RData"))

test.data.without.location.with.risk.factor$predict_C_1 <- predict(
  model_1_final_C, newdata=test.data.without.location.with.risk.factor
)

test.data.without.location.with.risk.factor$predict_C_2 <- predict(
  model_2_final_C, newdata=test.data.without.location.with.risk.factor
)

test.data.without.location.with.risk.factor$predict_C_3 <- predict(
  model_3_final_C, newdata=test.data.without.location.with.risk.factor
)

test.data.without.location.with.risk.factor$predict_C_4 <- predict(
  model_4_final_C, newdata=test.data.without.location.with.risk.factor
)

test.data.without.location.with.risk.factor$predict_C <- 
  factor(max.col(
    test.data.without.location.with.risk.factor[,c("predict_C_1","predict_C_2", "predict_C_3", "predict_C_4")]))

rm(list=c("model_1_final_C", "model_2_final_C", "model_3_final_C", "model_4_final_C"))

# D without location with risk
print("prediction without location with risk factor D")
load(file.path("DATA","OUTPUT","first_model_glm_all_clusters_without_location_with_risk_factor_D.RData"))

test.data.without.location.with.risk.factor$predict_D_1 <- predict(
  model_1_final_D, newdata=test.data.without.location.with.risk.factor
)

test.data.without.location.with.risk.factor$predict_D_2 <- predict(
  model_2_final_D, newdata=test.data.without.location.with.risk.factor
)

test.data.without.location.with.risk.factor$predict_D_3 <- predict(
  model_3_final_D, newdata=test.data.without.location.with.risk.factor
)

test.data.without.location.with.risk.factor$predict_D <- 
  factor(max.col(
    test.data.without.location.with.risk.factor[,c("predict_D_1","predict_D_2", "predict_D_3")]))

rm(list=c("model_1_final_D", "model_2_final_D", "model_3_final_D"))

# E without location with risk
print("prediction without location with risk factor E")
load(file.path("DATA","OUTPUT","first_model_glm_all_clusters_without_location_with_risk_factor_E.RData"))

test.data.without.location.with.risk.factor$predict_E_0 <- predict(
  model_0_final_E, newdata=test.data.without.location.with.risk.factor
)

test.data.without.location.with.risk.factor$predict_E_1 <- predict(
  model_1_final_E, newdata=test.data.without.location.with.risk.factor
)

test.data.without.location.with.risk.factor$predict_E <- 
  factor(max.col(
    test.data.without.location.with.risk.factor[,c("predict_E_0","predict_E_1")])-1)

rm(list=c("model_0_final_E", "model_1_final_E"))

# F without location with risk
print("prediction without location with risk factor F")
load(file.path("DATA","OUTPUT","first_model_glm_all_clusters_without_location_with_risk_factor_F.RData"))

test.data.without.location.with.risk.factor$predict_F_0 <- predict(
  model_0_final_F, newdata=test.data.without.location.with.risk.factor
)

test.data.without.location.with.risk.factor$predict_F_1 <- predict(
  model_1_final_F, newdata=test.data.without.location.with.risk.factor
)

test.data.without.location.with.risk.factor$predict_F_2 <- predict(
  model_2_final_F, newdata=test.data.without.location.with.risk.factor
)

test.data.without.location.with.risk.factor$predict_F_3 <- predict(
  model_3_final_F, newdata=test.data.without.location.with.risk.factor
)

test.data.without.location.with.risk.factor$predict_F <- 
  factor(max.col(
    test.data.without.location.with.risk.factor[,c("predict_F_0","predict_F_1","predict_F_2","predict_F_3")])-1)

rm(list=c("model_0_final_F", "model_1_final_F", "model_2_final_F", "model_3_final_F"))

# G without location with risk
print("prediction without location with risk factor G")
load(file.path("DATA","OUTPUT","first_model_glm_all_clusters_without_location_with_risk_factor_G.RData"))

test.data.without.location.with.risk.factor$predict_G_1 <- predict(
  model_1_final_G, newdata=test.data.without.location.with.risk.factor
)

test.data.without.location.with.risk.factor$predict_G_2 <- predict(
  model_2_final_G, newdata=test.data.without.location.with.risk.factor
)

test.data.without.location.with.risk.factor$predict_G_3 <- predict(
  model_3_final_G, newdata=test.data.without.location.with.risk.factor
)

test.data.without.location.with.risk.factor$predict_G_4 <- predict(
  model_4_final_G, newdata=test.data.without.location.with.risk.factor
)

test.data.without.location.with.risk.factor$predict_G <- 
  factor(max.col(
    test.data.without.location.with.risk.factor[,c("predict_G_1","predict_G_2","predict_G_3","predict_G_4")]))

rm(list=c("model_1_final_G", "model_2_final_G", "model_3_final_G", "model_4_final_G"))

# final without location with risk factor
print("prediction without location with risk factor ABCDEFG")
test.data.without.location.with.risk.factor$predict_ABCDEFG <-
  with(test.data.without.location.with.risk.factor,
       paste(
         as.character(predict_A),
         as.character(predict_B),
         as.character(predict_C),
         as.character(predict_D),
         as.character(predict_E),
         as.character(predict_F),
         as.character(predict_G),
         sep=""
       )
  )


############################# prediction without location without risk factor ########################
# A without location without risk
print("prediction without location without risk factor A")
load(file.path("DATA","OUTPUT","first_model_glm_all_clusters_without_location_without_risk_factor_A.RData"))

test.data.without.location.without.risk.factor$predict_A_0 <- predict(
  model_0_final_A, newdata=test.data.without.location.without.risk.factor
)

test.data.without.location.without.risk.factor$predict_A_1 <- predict(
  model_1_final_A, newdata=test.data.without.location.without.risk.factor
)

test.data.without.location.without.risk.factor$predict_A_2 <- predict(
  model_2_final_A, newdata=test.data.without.location.without.risk.factor
)

test.data.without.location.without.risk.factor$predict_A <- 
  factor(max.col(
    test.data.without.location.without.risk.factor[,c("predict_A_0","predict_A_1", "predict_A_2")])-1)

rm(list=c("model_0_final_A", "model_1_final_A", "model_2_final_A"))

# B without location without risk
print("prediction without location without risk factor B")
load(file.path("DATA","OUTPUT","first_model_glm_all_clusters_without_location_without_risk_factor_B.RData"))

test.data.without.location.without.risk.factor$predict_B_0 <- predict(
  model_0_final_B, newdata=test.data.without.location.without.risk.factor
)

test.data.without.location.without.risk.factor$predict_B_1 <- predict(
  model_1_final_B, newdata=test.data.without.location.without.risk.factor
)

test.data.without.location.without.risk.factor$predict_B <- 
  factor(max.col(
    test.data.without.location.without.risk.factor[,c("predict_B_0","predict_B_1")])-1)

rm(list=c("model_0_final_B", "model_1_final_B"))

# C without location without risk
print("prediction without location without risk factor C")
load(file.path("DATA","OUTPUT","first_model_glm_all_clusters_without_location_without_risk_factor_C.RData"))

test.data.without.location.without.risk.factor$predict_C_1 <- predict(
  model_1_final_C, newdata=test.data.without.location.without.risk.factor
)

test.data.without.location.without.risk.factor$predict_C_2 <- predict(
  model_2_final_C, newdata=test.data.without.location.without.risk.factor
)

test.data.without.location.without.risk.factor$predict_C_3 <- predict(
  model_3_final_C, newdata=test.data.without.location.without.risk.factor
)

test.data.without.location.without.risk.factor$predict_C_4 <- predict(
  model_4_final_C, newdata=test.data.without.location.without.risk.factor
)

test.data.without.location.without.risk.factor$predict_C <- 
  factor(max.col(
    test.data.without.location.without.risk.factor[,c("predict_C_1","predict_C_2", "predict_C_3", "predict_C_4")]))

rm(list=c("model_1_final_C", "model_2_final_C", "model_3_final_C", "model_4_final_C"))

# D without location without risk
print("prediction without location without risk factor D")
load(file.path("DATA","OUTPUT","first_model_glm_all_clusters_without_location_without_risk_factor_D.RData"))

test.data.without.location.without.risk.factor$predict_D_1 <- predict(
  model_1_final_D, newdata=test.data.without.location.without.risk.factor
)

test.data.without.location.without.risk.factor$predict_D_2 <- predict(
  model_2_final_D, newdata=test.data.without.location.without.risk.factor
)

test.data.without.location.without.risk.factor$predict_D_3 <- predict(
  model_3_final_D, newdata=test.data.without.location.without.risk.factor
)

test.data.without.location.without.risk.factor$predict_D <- 
  factor(max.col(
    test.data.without.location.without.risk.factor[,c("predict_D_1","predict_D_2", "predict_D_3")]))

rm(list=c("model_1_final_D", "model_2_final_D", "model_3_final_D"))

# E without location without risk
print("prediction without location without risk factor E")
load(file.path("DATA","OUTPUT","first_model_glm_all_clusters_without_location_without_risk_factor_E.RData"))

test.data.without.location.without.risk.factor$predict_E_0 <- predict(
  model_0_final_E, newdata=test.data.without.location.without.risk.factor
)

test.data.without.location.without.risk.factor$predict_E_1 <- predict(
  model_1_final_E, newdata=test.data.without.location.without.risk.factor
)

test.data.without.location.without.risk.factor$predict_E <- 
  factor(max.col(
    test.data.without.location.without.risk.factor[,c("predict_E_0","predict_E_1")])-1)

rm(list=c("model_0_final_E", "model_1_final_E"))

# F without location without risk
print("prediction without location without risk factor F")
load(file.path("DATA","OUTPUT","first_model_glm_all_clusters_without_location_without_risk_factor_F.RData"))

test.data.without.location.without.risk.factor$predict_F_0 <- predict(
  model_0_final_F, newdata=test.data.without.location.without.risk.factor
)

test.data.without.location.without.risk.factor$predict_F_1 <- predict(
  model_1_final_F, newdata=test.data.without.location.without.risk.factor
)

test.data.without.location.without.risk.factor$predict_F_2 <- predict(
  model_2_final_F, newdata=test.data.without.location.without.risk.factor
)

test.data.without.location.without.risk.factor$predict_F_3 <- predict(
  model_3_final_F, newdata=test.data.without.location.without.risk.factor
)

test.data.without.location.without.risk.factor$predict_F <- 
  factor(max.col(
    test.data.without.location.without.risk.factor[,c("predict_F_0","predict_F_1","predict_F_2","predict_F_3")])-1)

rm(list=c("model_0_final_F", "model_1_final_F", "model_2_final_F", "model_3_final_F"))

# G without location without risk
print("prediction without location without risk factor G")
load(file.path("DATA","OUTPUT","first_model_glm_all_clusters_without_location_without_risk_factor_G.RData"))

test.data.without.location.without.risk.factor$predict_G_1 <- predict(
  model_1_final_G, newdata=test.data.without.location.without.risk.factor
)

test.data.without.location.without.risk.factor$predict_G_2 <- predict(
  model_2_final_G, newdata=test.data.without.location.without.risk.factor
)

test.data.without.location.without.risk.factor$predict_G_3 <- predict(
  model_3_final_G, newdata=test.data.without.location.without.risk.factor
)

test.data.without.location.without.risk.factor$predict_G_4 <- predict(
  model_4_final_G, newdata=test.data.without.location.without.risk.factor
)

test.data.without.location.without.risk.factor$predict_G <- 
  factor(max.col(
    test.data.without.location.without.risk.factor[,c("predict_G_1","predict_G_2","predict_G_3","predict_G_4")]))

rm(list=c("model_1_final_G", "model_2_final_G", "model_3_final_G", "model_4_final_G"))

# final without location without risk factor
print("prediction without location without risk factor ABCDEFG")
test.data.without.location.without.risk.factor$predict_ABCDEFG <-
  with(test.data.without.location.without.risk.factor,
       paste(
         as.character(predict_A),
         as.character(predict_B),
         as.character(predict_C),
         as.character(predict_D),
         as.character(predict_E),
         as.character(predict_F),
         as.character(predict_G),
         sep=""
       )
  )

# information
df.with.location.with.risk.factor <- data.frame(
  customer_ID=as.numeric(as.character(rownames(test.data.with.location.with.risk.factor))),
  plan=as.character(test.data.with.location.with.risk.factor$predict_ABCDEFG)
  )

df.with.location.without.risk.factor <- data.frame(
  customer_ID=as.numeric(as.character(rownames(test.data.with.location.without.risk.factor))),
  plan=as.character(test.data.with.location.without.risk.factor$predict_ABCDEFG)
)

df.without.location.with.risk.factor <- data.frame(
  customer_ID=as.numeric(as.character(rownames(test.data.without.location.with.risk.factor))),
  plan=as.character(test.data.without.location.with.risk.factor$predict_ABCDEFG)
)

df.without.location.without.risk.factor <- data.frame(
  customer_ID=as.numeric(as.character(rownames(test.data.without.location.without.risk.factor))),
  plan=as.character(test.data.without.location.without.risk.factor$predict_ABCDEFG)
)

df.result <- rbind(
  df.with.location.with.risk.factor,
  df.with.location.without.risk.factor,
  df.without.location.with.risk.factor,
  df.without.location.without.risk.factor
  )

df.result <- df.result[order(df.result$customer_ID),]

submission.filename <- file.path("DATA","SUBMISSION","glm_location_risk_submission.csv")
write.table(
  x=df.result, 
  file=submission.filename, 
  quote=FALSE,
  sep=",",
  row.names=FALSE
  )



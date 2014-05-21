library(caret)

add.result <- function(
  result.set,
  size.train,
  train.set,
  test.set,
  type.model,
  type.set,
  value.to.test,
  letter,
  real.column,
  predicted.column,
  deviance
) {
  
  if(value.to.test == "ALL") {
    result <- rbind(result, data.frame(
      size.train=size.train,
      nrow.train=nrow(train.set),  
      nrow.test=nrow(test.set),  
      type.model=type.model,
      type.set=type.set,
      letter.to.test=letter,
      value.to.test=value.to.test,
      deviance=NA,
      error.test=prediction_error(test.set[,c(real.column)], test.set[,c(predicted.column)]),
      error.train=prediction_error(train.set[,c(real.column)], train.set[,c(predicted.column)]),
      nb.ok.test=sum((test.set[,c(real.column)]) == (test.set[,c(predicted.column)])),
      nb.ko.test=sum((test.set[,c(real.column)]) != (test.set[,c(predicted.column)])),
      nb.ok.train=sum((train.set[,c(real.column)]) == (train.set[,c(predicted.column)])),
      nb.ko.train=sum((train.set[,c(real.column)]) != (train.set[,c(predicted.column)]))
    ))
    
  } else {
    result <- rbind(result, data.frame(
      size.train=size.train,
      nrow.train=nrow(train.set),  
      nrow.test=nrow(test.set),  
      type.model=type.model,
      type.set=type.set,
      letter.to.test=letter,
      value.to.test=value.to.test,
      deviance=deviance,
      error.test=prediction_error(test.set[,c(real.column)] == value.to.test, test.set[,c(predicted.column)] == value.to.test),
      error.train=prediction_error(train.set[,c(real.column)] == value.to.test, train.set[,c(predicted.column)] == value.to.test),
      nb.ok.test=sum((test.set[,c(real.column)] == value.to.test) == (test.set[,c(predicted.column)] == value.to.test)),
      nb.ko.test=sum((test.set[,c(real.column)] == value.to.test) != (test.set[,c(predicted.column)] == value.to.test)),
      nb.ok.train=sum((train.set[,c(real.column)] == value.to.test) == (train.set[,c(predicted.column)] == value.to.test)),
      nb.ko.train=sum((train.set[,c(real.column)] == value.to.test) != (train.set[,c(predicted.column)] == value.to.test))
    ))
    
  }    
  
  return(result)
}

normalize.data <- function(data, with.location=FALSE, with.risk.factor=FALSE) {
  rownames(data) <- as.character(data$customer_ID)
  
  # Suppression lignes
  data <- data[,colnames(data) != "customer_ID"]
  data <- data[,colnames(data) != "X"]
  data <- data[,colnames(data) != "row_names"]
  data <- data[,colnames(data) != "location"]
  
  # Gestion risk_factor
  if(with.risk.factor) {
    data <- subset(data, ! is.na(risk_factor))
    data$risk_factor <- factor(data$risk_factor)
  } else {
    data <- data[is.na(data$risk_factor),]
    data <- data[,! grepl("risk_factor", colnames(data))]    
  }
  
  # Suppression variables location
  if(! with.location) {
    data <- data[, ! grepl("location", colnames(data))]
  }
  
  # Suppression variables count location
  data <- data[,! grepl("_count", colnames(data))]
  
  # nb_views
  data$nb_views <- factor(ifelse(data$nb_views <= 3, as.character(data$nb_views), "3+"))
  
  # state factor
  data$state <- factor(data$state)
  
  # day
  data$day <- factor(data$day)
  
  # group_size
  data$group_size <- factor(data$group_size, ordered=TRUE)
  
  # homeowner
  data$homeowner <- factor(ifelse(data$homeowner == 1, "Yes", "No"))
  
  # car_age
  data$car_age <- data$car_age
  
  # car_value
  data$car_value <- factor(ifelse(data$car_value == "", "NotAvailable", data$car_value))
    
  # age_youngest
  data$age_youngest <- data$age_youngest
  
  # age_oldest
  data$age_oldest <- data$age_oldest
  
  # married_couple
  data$married_couple <- factor(ifelse(data$married_couple == 1, "Yes", "No"))
  
  # C_previous
  data$C_previous <- factor(ifelse(is.na(data$C_previous), "NotAvailable", data$C_previous))
  
  # duration_previous
  data$duration_previous <- ifelse(is.na(data$duration_previous), 5, data$duration_previous)
  
  # last_cost
  data$last_cost <- data$last_cost
  
  # enlever shopping_pt
  data <- data[, ! grepl("shopping_pt", colnames(data))]
  
  # A
  data$last_A <- factor(data$last_A)
#   data$shopping_pt_2_A <- factor(data$shopping_pt_2_A)
#   data$shopping_pt_3_A <- factor(data$shopping_pt_3_A)
#   data$shopping_pt_min_cost_A <- factor(data$shopping_pt_min_cost_A)
  
  # B
  data$last_B <- factor(data$last_B)
#   data$shopping_pt_2_B <- factor(data$shopping_pt_2_B)
#   data$shopping_pt_3_B <- factor(data$shopping_pt_3_B)
#   data$shopping_pt_min_cost_B <- factor(data$shopping_pt_min_cost_B)
  
  # C
  data$last_C <- factor(data$last_C)
#   data$shopping_pt_2_C <- factor(data$shopping_pt_2_C)
#   data$shopping_pt_3_C <- factor(data$shopping_pt_3_C)
#   data$shopping_pt_min_cost_C <- factor(data$shopping_pt_min_cost_C)
  
  # D
  data$last_D <- factor(data$last_D)
#   data$shopping_pt_2_D <- factor(data$shopping_pt_2_D)
#   data$shopping_pt_3_D <- factor(data$shopping_pt_3_D)
#   data$shopping_pt_min_cost_D <- factor(data$shopping_pt_min_cost_D)
  
  # E
  data$last_E <- factor(data$last_E)
#   data$shopping_pt_2_E <- factor(data$shopping_pt_2_E)
#   data$shopping_pt_3_E <- factor(data$shopping_pt_3_E)
#   data$shopping_pt_min_cost_E <- factor(data$shopping_pt_min_cost_E)
  
  # F
  data$last_F <- factor(data$last_F)
#   data$shopping_pt_2_F <- factor(data$shopping_pt_2_F)
#   data$shopping_pt_3_F <- factor(data$shopping_pt_3_F)
#   data$shopping_pt_min_cost_F <- factor(data$shopping_pt_min_cost_F)
  
  # G
  data$last_G <- factor(data$last_G)
#   data$shopping_pt_2_G <- factor(data$shopping_pt_2_G)
#   data$shopping_pt_3_G <- factor(data$shopping_pt_3_G)
#   data$shopping_pt_min_cost_G <- factor(data$shopping_pt_min_cost_G)
  
  return(data)
}

normalize.train.data <- function(data, with.location=FALSE, with.risk.factor=FALSE) {
  
  data <- normalize.data(data, with.location, with.risk.factor)
  
  data$real_A <- factor(data$real_A)
  data$real_B <- factor(data$real_B)
  data$real_C <- factor(data$real_C)
  data$real_D <- factor(data$real_D)
  data$real_E <- factor(data$real_E)
  data$real_F <- factor(data$real_F)
  data$real_G <- factor(data$real_G)
  
  return(data)
}

normalize.test.data <- function(data, with.location=FALSE, with.risk.factor=FALSE) {
  
  if(with.location) {
    data <- data[! is.na(data$A0_location_pct),]
  } else {
    data <- data[is.na(data$A0_location_pct),]    
  }
  
  data <- normalize.data(data, with.location, with.risk.factor)
  
  return(data)
  
}


evaluation.prediction.ABCDEFG <- function(data) {
  data$prediction_ABCDEFG <- with(data, paste(
    as.character(prediction_A),
    as.character(prediction_B),
    as.character(prediction_C),
    as.character(prediction_D),
    as.character(prediction_E),
    as.character(prediction_F),
    as.character(prediction_G),
    sep = ""
  )
  )
  
  return(data)
  
}

evaluation.real.ABCDEFG <- function(data) {
  data$real_ABCDEFG <- with(data, paste(
    as.character(real_A),
    as.character(real_B),
    as.character(real_C),
    as.character(real_D),
    as.character(real_E),
    as.character(real_F),
    as.character(real_G),
    sep = ""
  )
  )
  
  return(data)
}

evaluation.transition.A <- function(data) {
  data$transition_A_vers_0 <- NA
  data$transition_A_vers_1 <- NA
  data$transition_A_vers_2 <- NA
  
  cat("Evaluation transitions A vers 0...\n")
  data$transition_A_vers_0[data$last_A == 0] <- predict(model_A_0_0, newdata=data[data$last_A == 0,])
  data$transition_A_vers_0[data$last_A == 1] <- predict(model_A_1_0, newdata=data[data$last_A == 1,])
  data$transition_A_vers_0[data$last_A == 2] <- predict(model_A_2_0, newdata=data[data$last_A == 2,])
  
  cat("Evaluation transitions A vers 1...\n")
  data$transition_A_vers_1[data$last_A == 0] <- predict(model_A_0_1, newdata=data[data$last_A == 0,])
  data$transition_A_vers_1[data$last_A == 1] <- predict(model_A_1_1, newdata=data[data$last_A == 1,])
  data$transition_A_vers_1[data$last_A == 2] <- predict(model_A_2_1, newdata=data[data$last_A == 2,])
  
  cat("Evaluation transitions A vers 2...\n")
  data$transition_A_vers_2[data$last_A == 0] <- predict(model_A_0_2, newdata=data[data$last_A == 0,])
  data$transition_A_vers_2[data$last_A == 1] <- predict(model_A_1_2, newdata=data[data$last_A == 1,])
  data$transition_A_vers_2[data$last_A == 2] <- predict(model_A_2_2, newdata=data[data$last_A == 2,])

  cat("Prediction A...\n")
  data$prediction_A <- factor(max.col(data[,c("transition_A_vers_0","transition_A_vers_1","transition_A_vers_2")])-1)
  
  return(data)
}

evaluation.transition.B <- function(data) {
  data$transition_B_vers_0 <- NA
  data$transition_B_vers_1 <- NA
  
  cat("Evaluation transitions B vers 0...\n")
  data$transition_B_vers_0[data$last_B == 0] <- predict(model_B_0_0, newdata=data[data$last_B == 0,])
  data$transition_B_vers_0[data$last_B == 1] <- predict(model_B_1_0, newdata=data[data$last_B == 1,])
  
  cat("Evaluation transitions B vers 1...\n")
  data$transition_B_vers_1[data$last_B == 0] <- predict(model_B_0_1, newdata=data[data$last_B == 0,])
  data$transition_B_vers_1[data$last_B == 1] <- predict(model_B_1_1, newdata=data[data$last_B == 1,])
    
  cat("Prediction B...\n")
  data$prediction_B <- factor(max.col(data[,c("transition_B_vers_0","transition_B_vers_1")])-1)
  
  return(data)
}

evaluation.transition.C <- function(data) {
  data$transition_C_vers_1 <- NA
  data$transition_C_vers_2 <- NA
  data$transition_C_vers_3 <- NA
  data$transition_C_vers_4 <- NA
  
  cat("Evaluation transitions C vers 1...\n")
  data$transition_C_vers_1[data$last_C == 1] <- predict(model_C_1_1, newdata=data[data$last_C == 1,])
  data$transition_C_vers_1[data$last_C == 2] <- predict(model_C_2_1, newdata=data[data$last_C == 2,])
  data$transition_C_vers_1[data$last_C == 3] <- predict(model_C_3_1, newdata=data[data$last_C == 3,])
  data$transition_C_vers_1[data$last_C == 4] <- predict(model_C_4_1, newdata=data[data$last_C == 4,])
  
  cat("Evaluation transitions C vers 2...\n")
  data$transition_C_vers_2[data$last_C == 1] <- predict(model_C_1_2, newdata=data[data$last_C == 1,])
  data$transition_C_vers_2[data$last_C == 2] <- predict(model_C_2_2, newdata=data[data$last_C == 2,])
  data$transition_C_vers_2[data$last_C == 3] <- predict(model_C_3_2, newdata=data[data$last_C == 3,])
  data$transition_C_vers_2[data$last_C == 4] <- predict(model_C_4_2, newdata=data[data$last_C == 4,])
  
  cat("Evaluation transitions C vers 3...\n")
  data$transition_C_vers_3[data$last_C == 1] <- predict(model_C_1_3, newdata=data[data$last_C == 1,])
  data$transition_C_vers_3[data$last_C == 2] <- predict(model_C_2_3, newdata=data[data$last_C == 2,])
  data$transition_C_vers_3[data$last_C == 3] <- predict(model_C_3_3, newdata=data[data$last_C == 3,])
  data$transition_C_vers_3[data$last_C == 4] <- predict(model_C_4_3, newdata=data[data$last_C == 4,])

  cat("Evaluation transitions C vers 4...\n")
  data$transition_C_vers_4[data$last_C == 1] <- predict(model_C_1_4, newdata=data[data$last_C == 1,])
  data$transition_C_vers_4[data$last_C == 2] <- predict(model_C_2_4, newdata=data[data$last_C == 2,])
  data$transition_C_vers_4[data$last_C == 3] <- predict(model_C_3_4, newdata=data[data$last_C == 3,])
  data$transition_C_vers_4[data$last_C == 4] <- predict(model_C_4_4, newdata=data[data$last_C == 4,])
  
  cat("Prediction C...\n")
  data$prediction_C <- factor(max.col(data[,c("transition_C_vers_1","transition_C_vers_2","transition_C_vers_3","transition_C_vers_4")]))
  
  return(data)
}

evaluation.transition.D <- function(data) {
  data$transition_D_vers_1 <- NA
  data$transition_D_vers_2 <- NA
  data$transition_D_vers_3 <- NA
  
  cat("Evaluation transitions D vers 1...\n")
  data$transition_D_vers_1[data$last_D == 1] <- predict(model_D_1_1, newdata=data[data$last_D == 1,])
  data$transition_D_vers_1[data$last_D == 2] <- predict(model_D_2_1, newdata=data[data$last_D == 2,])
  data$transition_D_vers_1[data$last_D == 3] <- predict(model_D_3_1, newdata=data[data$last_D == 3,])
  
  cat("Evaluation transitions D vers 2...\n")
  data$transition_D_vers_2[data$last_D == 1] <- predict(model_D_1_2, newdata=data[data$last_D == 1,])
  data$transition_D_vers_2[data$last_D == 2] <- predict(model_D_2_2, newdata=data[data$last_D == 2,])
  data$transition_D_vers_2[data$last_D == 3] <- predict(model_D_3_2, newdata=data[data$last_D == 3,])

  cat("Evaluation transitions D vers 3...\n")
  data$transition_D_vers_3[data$last_D == 1] <- predict(model_D_1_3, newdata=data[data$last_D == 1,])
  data$transition_D_vers_3[data$last_D == 2] <- predict(model_D_2_3, newdata=data[data$last_D == 2,])
  data$transition_D_vers_3[data$last_D == 3] <- predict(model_D_3_3, newdata=data[data$last_D == 3,])
  
  cat("Prediction D...\n")
  data$prediction_D <- factor(max.col(data[,c("transition_D_vers_1","transition_D_vers_2","transition_D_vers_3")]))
  
  return(data)
}

evaluation.transition.E <- function(data) {
  data$transition_E_vers_0 <- NA
  data$transition_E_vers_1 <- NA
  
  cat("Evaluation transitions E vers 0...\n")
  data$transition_E_vers_0[data$last_E == 0] <- predict(model_E_0_0, newdata=data[data$last_E == 0,])
  data$transition_E_vers_0[data$last_E == 1] <- predict(model_E_1_0, newdata=data[data$last_E == 1,])
  
  cat("Evaluation transitions E vers 1...\n")
  data$transition_E_vers_1[data$last_E == 0] <- predict(model_E_0_1, newdata=data[data$last_E == 0,])
  data$transition_E_vers_1[data$last_E == 1] <- predict(model_E_1_1, newdata=data[data$last_E == 1,])
    
  cat("Prediction E...\n")
  data$prediction_E <- factor(max.col(data[,c("transition_E_vers_0","transition_E_vers_1")])-1)
  
  return(data)
}

evaluation.transition.F <- function(data) {
  data$transition_F_vers_0 <- NA
  data$transition_F_vers_1 <- NA
  data$transition_F_vers_2 <- NA
  data$transition_F_vers_3 <- NA
  
  cat("Evaluation transitions F vers 0...\n")
  data$transition_F_vers_0[data$last_F == 0] <- predict(model_F_0_0, newdata=data[data$last_F == 0,])
  data$transition_F_vers_0[data$last_F == 1] <- predict(model_F_1_0, newdata=data[data$last_F == 1,])
  data$transition_F_vers_0[data$last_F == 2] <- predict(model_F_2_0, newdata=data[data$last_F == 2,])
  data$transition_F_vers_0[data$last_F == 3] <- predict(model_F_3_0, newdata=data[data$last_F == 3,])
  
  cat("Evaluation transitions F vers 1...\n")
  data$transition_F_vers_1[data$last_F == 0] <- predict(model_F_0_1, newdata=data[data$last_F == 0,])
  data$transition_F_vers_1[data$last_F == 1] <- predict(model_F_1_1, newdata=data[data$last_F == 1,])
  data$transition_F_vers_1[data$last_F == 2] <- predict(model_F_2_1, newdata=data[data$last_F == 2,])
  data$transition_F_vers_1[data$last_F == 3] <- predict(model_F_3_1, newdata=data[data$last_F == 3,])
    
  cat("Evaluation transitions F vers 2...\n")
  data$transition_F_vers_2[data$last_F == 0] <- predict(model_F_0_2, newdata=data[data$last_F == 0,])
  data$transition_F_vers_2[data$last_F == 1] <- predict(model_F_1_2, newdata=data[data$last_F == 1,])
  data$transition_F_vers_2[data$last_F == 2] <- predict(model_F_2_2, newdata=data[data$last_F == 2,])
  data$transition_F_vers_2[data$last_F == 3] <- predict(model_F_3_2, newdata=data[data$last_F == 3,])
  
  cat("Evaluation transitions F vers 3...\n")
  data$transition_F_vers_3[data$last_F == 0] <- predict(model_F_0_3, newdata=data[data$last_F == 0,])
  data$transition_F_vers_3[data$last_F == 1] <- predict(model_F_1_3, newdata=data[data$last_F == 1,])
  data$transition_F_vers_3[data$last_F == 2] <- predict(model_F_2_3, newdata=data[data$last_F == 2,])
  data$transition_F_vers_3[data$last_F == 3] <- predict(model_F_3_3, newdata=data[data$last_F == 3,])
  
  cat("Prediction F...\n")
  data$prediction_F <- factor(max.col(data[,c("transition_F_vers_0","transition_F_vers_1", "transition_F_vers_2", "transition_F_vers_3")])-1)
  
  return(data)
}

evaluation.transition.G <- function(data) {
  data$transition_G_vers_1 <- NA
  data$transition_G_vers_2 <- NA
  data$transition_G_vers_3 <- NA
  data$transition_G_vers_4 <- NA
  
  cat("Evaluation transitions G vers 1...\n")
  data$transition_G_vers_1[data$last_G == 1] <- predict(model_G_1_1, newdata=data[data$last_G == 1,])
  data$transition_G_vers_1[data$last_G == 2] <- predict(model_G_2_1, newdata=data[data$last_G == 2,])
  data$transition_G_vers_1[data$last_G == 3] <- predict(model_G_3_1, newdata=data[data$last_G == 3,])
  data$transition_G_vers_1[data$last_G == 4] <- predict(model_G_4_1, newdata=data[data$last_G == 4,])
  
  cat("Evaluation transitions G vers 2...\n")
  data$transition_G_vers_2[data$last_G == 1] <- predict(model_G_1_2, newdata=data[data$last_G == 1,])
  data$transition_G_vers_2[data$last_G == 2] <- predict(model_G_2_2, newdata=data[data$last_G == 2,])
  data$transition_G_vers_2[data$last_G == 3] <- predict(model_G_3_2, newdata=data[data$last_G == 3,])
  data$transition_G_vers_2[data$last_G == 4] <- predict(model_G_4_2, newdata=data[data$last_G == 4,])
  
  cat("Evaluation transitions G vers 3...\n")
  data$transition_G_vers_3[data$last_G == 1] <- predict(model_G_1_3, newdata=data[data$last_G == 1,])
  data$transition_G_vers_3[data$last_G == 2] <- predict(model_G_2_3, newdata=data[data$last_G == 2,])
  data$transition_G_vers_3[data$last_G == 3] <- predict(model_G_3_3, newdata=data[data$last_G == 3,])
  data$transition_G_vers_3[data$last_G == 4] <- predict(model_G_4_3, newdata=data[data$last_G == 4,])
  
  cat("Evaluation transitions G vers 4...\n")  
  data$transition_G_vers_4[data$last_G == 1] <- predict(model_G_1_4, newdata=data[data$last_G == 1,])
  data$transition_G_vers_4[data$last_G == 2] <- predict(model_G_2_4, newdata=data[data$last_G == 2,])
  data$transition_G_vers_4[data$last_G == 3] <- predict(model_G_3_4, newdata=data[data$last_G == 3,])
  data$transition_G_vers_4[data$last_G == 4] <- predict(model_G_4_4, newdata=data[data$last_G == 4,])
  
  cat("Prediction G...\n")
  data$prediction_G <- factor(max.col(data[,c("transition_G_vers_1","transition_G_vers_2", "transition_G_vers_3", "transition_G_vers_4")]))
  
  return(data)
}

load.model.transition.A <- function() {
  load(file.path("DATA","TRANSITION", "transition_0_vers_0_A.RData"))
  model_A_0_0 <<- model
  load(file.path("DATA","TRANSITION", "transition_0_vers_1_A.RData"))
  model_A_0_1 <<- model
  load(file.path("DATA","TRANSITION", "transition_0_vers_2_A.RData"))
  model_A_0_2 <<- model
  
  load(file.path("DATA","TRANSITION", "transition_1_vers_0_A.RData"))
  model_A_1_0 <<- model
  load(file.path("DATA","TRANSITION", "transition_1_vers_1_A.RData"))
  model_A_1_1 <<- model
  load(file.path("DATA","TRANSITION", "transition_1_vers_2_A.RData"))
  model_A_1_2 <<- model
  
  load(file.path("DATA","TRANSITION", "transition_2_vers_0_A.RData"))
  model_A_2_0 <<- model
  load(file.path("DATA","TRANSITION", "transition_2_vers_1_A.RData"))
  model_A_2_1 <<- model
  load(file.path("DATA","TRANSITION", "transition_2_vers_2_A.RData"))
  model_A_2_2 <<- model
  
  rm(list=c("model"))
}


load.model.transition.B <- function() {
  load(file.path("DATA","TRANSITION", "transition_0_vers_0_B.RData"))
  model_B_0_0 <<- model
  load(file.path("DATA","TRANSITION", "transition_0_vers_1_B.RData"))
  model_B_0_1 <<- model
  
  load(file.path("DATA","TRANSITION", "transition_1_vers_0_B.RData"))
  model_B_1_0 <<- model
  load(file.path("DATA","TRANSITION", "transition_1_vers_1_B.RData"))
  model_B_1_1 <<- model  
  
  rm(list=c("model"))
}

load.model.transition.C <- function() {
  load(file.path("DATA","TRANSITION", "transition_1_vers_1_C.RData"))
  model_C_1_1 <<- model
  load(file.path("DATA","TRANSITION", "transition_1_vers_2_C.RData"))
  model_C_1_2 <<- model
  load(file.path("DATA","TRANSITION", "transition_1_vers_3_C.RData"))
  model_C_1_3 <<- model
  load(file.path("DATA","TRANSITION", "transition_1_vers_4_C.RData"))
  model_C_1_4 <<- model
  
  load(file.path("DATA","TRANSITION", "transition_2_vers_1_C.RData"))
  model_C_2_1 <<- model
  load(file.path("DATA","TRANSITION", "transition_2_vers_2_C.RData"))
  model_C_2_2 <<- model
  load(file.path("DATA","TRANSITION", "transition_2_vers_3_C.RData"))
  model_C_2_3 <<- model
  load(file.path("DATA","TRANSITION", "transition_2_vers_4_C.RData"))
  model_C_2_4 <<- model

  load(file.path("DATA","TRANSITION", "transition_3_vers_1_C.RData"))
  model_C_3_1 <<- model
  load(file.path("DATA","TRANSITION", "transition_3_vers_2_C.RData"))
  model_C_3_2 <<- model
  load(file.path("DATA","TRANSITION", "transition_3_vers_3_C.RData"))
  model_C_3_3 <<- model
  load(file.path("DATA","TRANSITION", "transition_3_vers_4_C.RData"))
  model_C_3_4 <<- model

  load(file.path("DATA","TRANSITION", "transition_4_vers_1_C.RData"))
  model_C_4_1 <<- model
  load(file.path("DATA","TRANSITION", "transition_4_vers_2_C.RData"))
  model_C_4_2 <<- model
  load(file.path("DATA","TRANSITION", "transition_4_vers_3_C.RData"))
  model_C_4_3 <<- model
  load(file.path("DATA","TRANSITION", "transition_4_vers_4_C.RData"))
  model_C_4_4 <<- model
  
  rm(list=c("model"))
}

load.model.transition.D <- function() {
  load(file.path("DATA","TRANSITION", "transition_1_vers_1_D.RData"))
  model_D_1_1 <<- model
  load(file.path("DATA","TRANSITION", "transition_1_vers_2_D.RData"))
  model_D_1_2 <<- model
  load(file.path("DATA","TRANSITION", "transition_1_vers_3_D.RData"))
  model_D_1_3 <<- model
  
  load(file.path("DATA","TRANSITION", "transition_2_vers_1_D.RData"))
  model_D_2_1 <<- model
  load(file.path("DATA","TRANSITION", "transition_2_vers_2_D.RData"))
  model_D_2_2 <<- model
  load(file.path("DATA","TRANSITION", "transition_2_vers_3_D.RData"))
  model_D_2_3 <<- model

  load(file.path("DATA","TRANSITION", "transition_3_vers_1_D.RData"))
  model_D_3_1 <<- model
  load(file.path("DATA","TRANSITION", "transition_3_vers_2_D.RData"))
  model_D_3_2 <<- model
  load(file.path("DATA","TRANSITION", "transition_3_vers_3_D.RData"))
  model_D_3_3 <<- model
  
  rm(list=c("model"))
}

load.model.transition.E <- function() {
  load(file.path("DATA","TRANSITION", "transition_0_vers_0_E.RData"))
  model_E_0_0 <<- model
  load(file.path("DATA","TRANSITION", "transition_0_vers_1_E.RData"))
  model_E_0_1 <<- model
  
  load(file.path("DATA","TRANSITION", "transition_1_vers_0_E.RData"))
  model_E_1_0 <<- model
  load(file.path("DATA","TRANSITION", "transition_1_vers_1_E.RData"))
  model_E_1_1 <<- model
    
  rm(list=c("model"))
}

load.model.transition.F <- function() {
  load(file.path("DATA","TRANSITION", "transition_0_vers_0_F.RData"))
  model_F_0_0 <<- model
  load(file.path("DATA","TRANSITION", "transition_0_vers_1_F.RData"))
  model_F_0_1 <<- model
  load(file.path("DATA","TRANSITION", "transition_0_vers_2_F.RData"))
  model_F_0_2 <<- model
  load(file.path("DATA","TRANSITION", "transition_0_vers_3_F.RData"))
  model_F_0_3 <<- model
  
  load(file.path("DATA","TRANSITION", "transition_1_vers_0_F.RData"))
  model_F_1_0 <<- model
  load(file.path("DATA","TRANSITION", "transition_1_vers_1_F.RData"))
  model_F_1_1 <<- model
  load(file.path("DATA","TRANSITION", "transition_1_vers_2_F.RData"))
  model_F_1_2 <<- model
  load(file.path("DATA","TRANSITION", "transition_1_vers_3_F.RData"))
  model_F_1_3 <<- model
  
  load(file.path("DATA","TRANSITION", "transition_2_vers_0_F.RData"))
  model_F_2_0 <<- model
  load(file.path("DATA","TRANSITION", "transition_2_vers_1_F.RData"))
  model_F_2_1 <<- model
  load(file.path("DATA","TRANSITION", "transition_2_vers_2_F.RData"))
  model_F_2_2 <<- model
  load(file.path("DATA","TRANSITION", "transition_2_vers_3_F.RData"))
  model_F_2_3 <<- model
  
  load(file.path("DATA","TRANSITION", "transition_3_vers_0_F.RData"))
  model_F_3_0 <<- model
  load(file.path("DATA","TRANSITION", "transition_3_vers_1_F.RData"))
  model_F_3_1 <<- model
  load(file.path("DATA","TRANSITION", "transition_3_vers_2_F.RData"))
  model_F_3_2 <<- model
  load(file.path("DATA","TRANSITION", "transition_3_vers_3_F.RData"))
  model_F_3_3 <<- model
  
  rm(list=c("model"))
}

load.model.transition.G <- function() {
  load(file.path("DATA","TRANSITION", "transition_1_vers_1_G.RData"))
  model_G_1_1 <<- model
  load(file.path("DATA","TRANSITION", "transition_1_vers_2_G.RData"))
  model_G_1_2 <<- model
  load(file.path("DATA","TRANSITION", "transition_1_vers_3_G.RData"))
  model_G_1_3 <<- model
  load(file.path("DATA","TRANSITION", "transition_1_vers_4_G.RData"))
  model_G_1_4 <<- model
  
  load(file.path("DATA","TRANSITION", "transition_2_vers_1_G.RData"))
  model_G_2_1 <<- model
  load(file.path("DATA","TRANSITION", "transition_2_vers_2_G.RData"))
  model_G_2_2 <<- model
  load(file.path("DATA","TRANSITION", "transition_2_vers_3_G.RData"))
  model_G_2_3 <<- model
  load(file.path("DATA","TRANSITION", "transition_2_vers_4_G.RData"))
  model_G_2_4 <<- model
  
  load(file.path("DATA","TRANSITION", "transition_3_vers_1_G.RData"))
  model_G_3_1 <<- model
  load(file.path("DATA","TRANSITION", "transition_3_vers_2_G.RData"))
  model_G_3_2 <<- model
  load(file.path("DATA","TRANSITION", "transition_3_vers_3_G.RData"))
  model_G_3_3 <<- model
  load(file.path("DATA","TRANSITION", "transition_3_vers_4_G.RData"))
  model_G_3_4 <<- model
  
  load(file.path("DATA","TRANSITION", "transition_4_vers_1_G.RData"))
  model_G_4_1 <<- model
  load(file.path("DATA","TRANSITION", "transition_4_vers_2_G.RData"))
  model_G_4_2 <<- model
  load(file.path("DATA","TRANSITION", "transition_4_vers_3_G.RData"))
  model_G_4_3 <<- model
  load(file.path("DATA","TRANSITION", "transition_4_vers_4_G.RData"))
  model_G_4_4 <<- model
  
  rm(list=c("model"))
}

get.train.test.transition.A <- function(data, p=.5, debut, fin) {
  set.seed(42)
  
  data <- subset(data, last_A == debut)
  
  trainIndex <- createDataPartition(data$real_A == fin, p = p,
                                    list = FALSE,
                                    times = 1)
  
  train <- data[trainIndex,]
  test <- data[-trainIndex,]
  
  train$y <- with(train, real_A == fin)
  test$y <- with(test, real_A == fin)
  
  train <- train[, ! grepl("real_", colnames(train))]
  test <- test[, ! grepl("real_", colnames(test))]
  
  train <- train[, ! grepl("last_A", colnames(train))]
  test <- test[, ! grepl("last_A", colnames(test))]
  
  train <- train[, ! grepl("percent_transition_F_", colnames(train))]
  test <- test[, ! grepl("percent_transition_F_", colnames(test))]
  
  train <- train[, ! grepl("percent_transition_G_", colnames(train))]
  test <- test[, ! grepl("percent_transition_G_", colnames(test))]
  
  return(list(train=train, test=test))
  
}


get.train.test.transition.B <- function(data, p=.5, debut, fin) {
  set.seed(42)
  
  data <- subset(data, last_B == debut)
  
  trainIndex <- createDataPartition(data$real_B == fin, p = p,
                                    list = FALSE,
                                    times = 1)
  
  train <- data[trainIndex,]
  test <- data[-trainIndex,]
  
  train$y <- with(train, real_B == fin)
  test$y <- with(test, real_B == fin)
  
  train <- train[, ! grepl("real_", colnames(train))]
  test <- test[, ! grepl("real_", colnames(test))]
  
  train <- train[, ! grepl("last_B", colnames(train))]
  test <- test[, ! grepl("last_B", colnames(test))]
  
  train <- train[, ! grepl("percent_transition_F_", colnames(train))]
  test <- test[, ! grepl("percent_transition_F_", colnames(test))]
  
  train <- train[, ! grepl("percent_transition_G_", colnames(train))]
  test <- test[, ! grepl("percent_transition_G_", colnames(test))]
  
  return(list(train=train, test=test))
  
}

get.train.test.transition.C <- function(data, p=.5, debut, fin) {
  set.seed(42)
  
  data <- subset(data, last_C == debut)
  
  trainIndex <- createDataPartition(data$real_C == fin, p = p,
                                    list = FALSE,
                                    times = 1)
  
  train <- data[trainIndex,]
  test <- data[-trainIndex,]
  
  train$y <- with(train, real_C == fin)
  test$y <- with(test, real_C == fin)
  
  train <- train[, ! grepl("real_", colnames(train))]
  test <- test[, ! grepl("real_", colnames(test))]
  
  train <- train[, ! grepl("last_C", colnames(train))]
  test <- test[, ! grepl("last_C", colnames(test))]
  
  train <- train[, ! grepl("percent_transition_F_", colnames(train))]
  test <- test[, ! grepl("percent_transition_F_", colnames(test))]
  
  train <- train[, ! grepl("percent_transition_G_", colnames(train))]
  test <- test[, ! grepl("percent_transition_G_", colnames(test))]
  
  return(list(train=train, test=test))
  
}

get.train.test.transition.D <- function(data, p=.5, debut, fin) {
  set.seed(42)
  
  data <- subset(data, last_D == debut)
  
  trainIndex <- createDataPartition(data$real_D == fin, p = p,
                                    list = FALSE,
                                    times = 1)
  
  train <- data[trainIndex,]
  test <- data[-trainIndex,]
  
  train$y <- with(train, real_D == fin)
  test$y <- with(test, real_D == fin)
  
  train <- train[, ! grepl("real_", colnames(train))]
  test <- test[, ! grepl("real_", colnames(test))]
  
  train <- train[, ! grepl("last_D", colnames(train))]
  test <- test[, ! grepl("last_D", colnames(test))]
  
  train <- train[, ! grepl("percent_transition_F_", colnames(train))]
  test <- test[, ! grepl("percent_transition_F_", colnames(test))]
  
  train <- train[, ! grepl("percent_transition_G_", colnames(train))]
  test <- test[, ! grepl("percent_transition_G_", colnames(test))]
  
  return(list(train=train, test=test))
  
}

get.train.test.transition.E <- function(data, p=.5, debut, fin) {
  set.seed(42)
  
  data <- subset(data, last_E == debut)
  
  trainIndex <- createDataPartition(data$real_E == fin, p = p,
                                    list = FALSE,
                                    times = 1)
  
  train <- data[trainIndex,]
  test <- data[-trainIndex,]
  
  train$y <- with(train, real_E == fin)
  test$y <- with(test, real_E == fin)
  
  train <- train[, ! grepl("real_", colnames(train))]
  test <- test[, ! grepl("real_", colnames(test))]
  
  train <- train[, ! grepl("last_E", colnames(train))]
  test <- test[, ! grepl("last_E", colnames(test))]
  
  train <- train[, ! grepl("percent_transition_F_", colnames(train))]
  test <- test[, ! grepl("percent_transition_F_", colnames(test))]
  
  train <- train[, ! grepl("percent_transition_G_", colnames(train))]
  test <- test[, ! grepl("percent_transition_G_", colnames(test))]
  
  return(list(train=train, test=test))
  
}

get.train.test.transition.F <- function(data, p=.5, debut, fin) {
  set.seed(42)
  
  data <- subset(data, last_F == debut)
  
  trainIndex <- createDataPartition(data$real_F == fin, p = p,
                                    list = FALSE,
                                    times = 1)
  
  train <- data[trainIndex,]
  test <- data[-trainIndex,]
  
  train$y <- with(train, real_F == fin)
  test$y <- with(test, real_F == fin)
  
  train <- train[, ! grepl("real_", colnames(train))]
  test <- test[, ! grepl("real_", colnames(test))]
  
  train <- train[, ! grepl("last_F", colnames(train))]
  test <- test[, ! grepl("last_F", colnames(test))]
  
  train <- train[, ! grepl("percent_transition_G_", colnames(train))]
  test <- test[, ! grepl("percent_transition_G_", colnames(test))]
  
  return(list(train=train, test=test))
  
}

get.train.test.transition.G <- function(data, p=.5, debut, fin) {
  set.seed(42)
  
  data <- subset(data, last_G == debut)
  
  trainIndex <- createDataPartition(data$real_G == fin, p = p,
                                    list = FALSE,
                                    times = 1)
  
  train <- data[trainIndex,]
  test <- data[-trainIndex,]
  
  train$y <- with(train, real_G == fin)
  test$y <- with(test, real_G == fin)
  
  train <- train[, ! grepl("real_", colnames(train))]
  test <- test[, ! grepl("real_", colnames(test))]
  
  train <- train[, ! grepl("last_G", colnames(train))]
  test <- test[, ! grepl("last_G", colnames(test))]
  
  train <- train[, ! grepl("percent_transition_F_", colnames(train))]
  test <- test[, ! grepl("percent_transition_F_", colnames(test))]
  
  return(list(train=train, test=test))
  
}

get.base.train.test <- function(data, column.name, p) {
  trainIndex <- createDataPartition(data[,c(column.name)], p = p,
                                    list = FALSE,
                                    times = 1)
  
  return(list(
    train=data[trainIndex,],
    test=data[-trainIndex,]
  ))
  
}

prediction_error <- function(true_data, predicted_data) {
  
  ok_prediction <- sum(true_data == predicted_data)
  ko_prediction <- sum(true_data != predicted_data)
  
  return ((ko_prediction)/(ok_prediction+ko_prediction))
}


num.errors <- function(vector_A, vector_B) {
  nchar_A <- nchar(vector_A)[1]
  nchar_B <- nchar(vector_B)[1]
  
  stopifnot(nchar_A == nchar_B)
  stopifnot(length(vector_A) == length(vector_B))
  
  tmp <- rep(0, length(vector_A))
  
  for(i in 1:nchar_A) {
    tmp <- tmp + ifelse(substr(vector_A,i,i) == substr(vector_B,i,i), 0, 1)
  }
  
  return(tmp)
}

compute.ABCDEF <- function(data) {
  
  data$predicted_ABCDEF <- paste(
    as.character(data$predicted_A),
    as.character(data$predicted_B),
    as.character(data$predicted_C),
    as.character(data$predicted_D),
    as.character(data$predicted_E),
    as.character(data$predicted_F),
    sep = ""
  )
  
  data$real_ABCDEF <- paste(
    as.character(data$real_A),
    as.character(data$real_B),
    as.character(data$real_C),
    as.character(data$real_D),
    as.character(data$real_E),
    as.character(data$real_F),
    sep = ""
  )
  
  return(data)
}

compute.ABCDEFG <- function(data) {
  
  data$predicted_ABCDEFG <- paste(
    as.character(data$predicted_A),
    as.character(data$predicted_B),
    as.character(data$predicted_C),
    as.character(data$predicted_D),
    as.character(data$predicted_E),
    as.character(data$predicted_F),
    as.character(data$predicted_G),
    sep = ""
  )
  
  data$real_ABCDEFG <- paste(
    as.character(data$real_A),
    as.character(data$real_B),
    as.character(data$real_C),
    as.character(data$real_D),
    as.character(data$real_E),
    as.character(data$real_F),
    as.character(data$real_G),
    sep = ""
  )
  
  return(data)
}

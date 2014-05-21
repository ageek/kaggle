source("reboot_data.R")

error.pred <- function(real, predict) {
  nb.ko <- sum(real != predict)
  nb.all <- length(real)
  
  return(nb.ko/nb.all)
}

# cost
load(file.path("last_model", "model_glm_cost_restricted.RData"))
data.train.normalized$real_cost <- predict(model.cost.restricted, newdata=data.train.normalized)

# A
load(file.path("last_model", "model_glm_A_restricted_cascade.RData"))

data.train.normalized$predicted_A_0 <- predict(model.A.0.restricted, newdata=data.train.normalized, type="response")
data.train.normalized$predicted_A_1 <- predict(model.A.1.restricted, newdata=data.train.normalized, type="response")
data.train.normalized$predicted_A_2 <- predict(model.A.2.restricted, newdata=data.train.normalized, type="response")

data.train.normalized$predicted_A <- max.col(data.train.normalized[,c("predicted_A_0","predicted_A_1","predicted_A_2")])-1

cat("Error A : ", with(data.train.normalized, error.pred(real_A, predicted_A)), "\n")

# B
load(file.path("last_model", "model_glm_B_restricted_cascade.RData"))

data.train.normalized$predicted_B_0 <- predict(model.B.0.restricted, newdata=data.train.normalized, type="response")
data.train.normalized$predicted_B_1 <- predict(model.B.1.restricted, newdata=data.train.normalized, type="response")

data.train.normalized$predicted_B <- max.col(data.train.normalized[,c("predicted_B_0","predicted_B_1")])-1

cat("Error B : ", with(data.train.normalized, error.pred(real_B, predicted_B)), "\n")

# C
load(file.path("last_model", "model_glm_C_restricted_cascade.RData"))

data.train.normalized$predicted_C_1 <- predict(model.C.1.restricted, newdata=data.train.normalized, type="response")
data.train.normalized$predicted_C_2 <- predict(model.C.2.restricted, newdata=data.train.normalized, type="response")
data.train.normalized$predicted_C_3 <- predict(model.C.3.restricted, newdata=data.train.normalized, type="response")
data.train.normalized$predicted_C_4 <- predict(model.C.4.restricted, newdata=data.train.normalized, type="response")

data.train.normalized$predicted_C <- max.col(data.train.normalized[,c("predicted_C_1","predicted_C_2","predicted_C_3","predicted_C_4")])

cat("Error C : ", with(data.train.normalized, error.pred(real_C, predicted_C)), "\n")

# D
load(file.path("last_model", "model_glm_D_restricted_cascade.RData"))

data.train.normalized$predicted_D_1 <- predict(model.D.1.restricted, newdata=data.train.normalized, type="response")
data.train.normalized$predicted_D_2 <- predict(model.D.2.restricted, newdata=data.train.normalized, type="response")
data.train.normalized$predicted_D_3 <- predict(model.D.3.restricted, newdata=data.train.normalized, type="response")

data.train.normalized$predicted_D <- max.col(data.train.normalized[,c("predicted_D_1","predicted_D_2","predicted_D_3")])

cat("Error D : ", with(data.train.normalized, error.pred(real_D, predicted_D)), "\n")

# E
load(file.path("last_model", "model_glm_E_restricted_cascade.RData"))

data.train.normalized$predicted_E_0 <- predict(model.E.0.restricted, newdata=data.train.normalized, type="response")
data.train.normalized$predicted_E_1 <- predict(model.E.1.restricted, newdata=data.train.normalized, type="response")

data.train.normalized$predicted_E <- max.col(data.train.normalized[,c("predicted_E_0","predicted_E_1")]) - 1

cat("Error E : ", with(data.train.normalized, error.pred(real_E, predicted_E)), "\n")

# F
load(file.path("last_model", "model_glm_F_restricted_cascade.RData"))

data.train.normalized$predicted_F_0 <- predict(model.F.0.restricted, newdata=data.train.normalized, type="response")
data.train.normalized$predicted_F_1 <- predict(model.F.1.restricted, newdata=data.train.normalized, type="response")
data.train.normalized$predicted_F_2 <- predict(model.F.2.restricted, newdata=data.train.normalized, type="response")
data.train.normalized$predicted_F_3 <- predict(model.F.3.restricted, newdata=data.train.normalized, type="response")

data.train.normalized$predicted_F <- max.col(data.train.normalized[,c("predicted_F_0","predicted_F_1","predicted_F_2","predicted_F_3")]) - 1

cat("Error F : ", with(data.train.normalized, error.pred(real_F, predicted_F)), "\n")

# G
load(file.path("last_model", "model_glm_G_restricted_cascade.RData"))
load(file.path("last_model", "model_glm_G_restricted_NY_cascade.RData"))

data.train.normalized$predicted_G_1 <- ifelse(data.train.normalized$state == "NY",predict(model.G.1.restricted.NY, newdata=data.train.normalized, type="response"), predict(model.G.1.restricted, newdata=data.train.normalized, type="response"))
data.train.normalized$predicted_G_2 <- ifelse(data.train.normalized$state == "NY",predict(model.G.2.restricted.NY, newdata=data.train.normalized, type="response"), predict(model.G.2.restricted, newdata=data.train.normalized, type="response"))
data.train.normalized$predicted_G_3 <- ifelse(data.train.normalized$state == "NY",predict(model.G.3.restricted.NY, newdata=data.train.normalized, type="response"), predict(model.G.3.restricted, newdata=data.train.normalized, type="response"))
data.train.normalized$predicted_G_4 <- ifelse(data.train.normalized$state == "NY",predict(model.G.4.restricted.NY, newdata=data.train.normalized, type="response"), predict(model.G.4.restricted, newdata=data.train.normalized, type="response"))

data.train.normalized$predicted_G <- max.col(data.train.normalized[,c("predicted_G_1","predicted_G_2","predicted_G_3","predicted_G_4")])

cat("Error G : ", with(data.train.normalized, error.pred(real_G, predicted_G)), "\n")

# ABCDEFG
data.train.normalized$real_ABCDEFG <- with(
  data.train.normalized,
  paste(
    as.character(real_A),
    as.character(real_B),
    as.character(real_C),
    as.character(real_D),
    as.character(real_E),
    as.character(real_F),
    as.character(real_G),
    sep=""
  )
)
    
data.train.normalized$predicted_ABCDEFG <- with(
  data.train.normalized,
  paste(
    as.character(predicted_A),
    as.character(predicted_B),
    as.character(predicted_C),
    as.character(predicted_D),
    as.character(predicted_E),
    as.character(predicted_F),
    as.character(predicted_G),
    sep=""
  )
)

data.train.normalized$error_on_A <- with(data.train.normalized,(real_A != predicted_A))
data.train.normalized$error_on_B <- with(data.train.normalized,(real_B != predicted_B))
data.train.normalized$error_on_C <- with(data.train.normalized,(real_C != predicted_C))
data.train.normalized$error_on_D <- with(data.train.normalized,(real_D != predicted_D))
data.train.normalized$error_on_E <- with(data.train.normalized,(real_E != predicted_E))
data.train.normalized$error_on_F <- with(data.train.normalized,(real_F != predicted_F))
data.train.normalized$error_on_G <- with(data.train.normalized,(real_G != predicted_G))

data.train.normalized$nb.errors <- with(
  data.train.normalized,
  ifelse(error_on_A, 1, 0) +
    ifelse(error_on_B, 1, 0) +
    ifelse(error_on_C, 1, 0) +
    ifelse(error_on_D, 1, 0) +
    ifelse(error_on_E, 1, 0) +
    ifelse(error_on_F, 1, 0) +
    ifelse(error_on_G, 1, 0)
)

cat("Error ABCDEFG : ", with(data.train.normalized, error.pred(real_ABCDEFG, predicted_ABCDEFG)), "\n")

data.train.normalized.error.1 <- subset(data.train.normalized, nb.errors == 1)

data.train.normalized.error.1$error.on <- NA
data.train.normalized.error.1$error.on <- with(data.train.normalized.error.1, ifelse(error_on_A, "A", error.on))
data.train.normalized.error.1$error.on <- with(data.train.normalized.error.1, ifelse(error_on_B, "B", error.on))
data.train.normalized.error.1$error.on <- with(data.train.normalized.error.1, ifelse(error_on_C, "C", error.on))
data.train.normalized.error.1$error.on <- with(data.train.normalized.error.1, ifelse(error_on_D, "D", error.on))
data.train.normalized.error.1$error.on <- with(data.train.normalized.error.1, ifelse(error_on_E, "E", error.on))
data.train.normalized.error.1$error.on <- with(data.train.normalized.error.1, ifelse(error_on_F, "F", error.on))
data.train.normalized.error.1$error.on <- with(data.train.normalized.error.1, ifelse(error_on_G, "G", error.on))
data.train.normalized.error.1$error.on <- factor(data.train.normalized.error.1$error.on)

library(ggplot2)
ggplot(data.train.normalized.error.1) + geom_bar(aes(x=error.on)) + facet_wrap(~state)
ggplot(subset(data.train.normalized.error.1, state %in% c("FL","NY","OH","PA","WA"))) + geom_bar(aes(x=error.on)) + facet_wrap(~state)

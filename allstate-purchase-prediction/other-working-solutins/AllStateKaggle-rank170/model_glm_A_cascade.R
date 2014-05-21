source("reboot_data.R")

# Error A :  0.07114792 
# Error B :  0.06585746 
# Error C :  0.0690338 
# Error D :  0.05045015 
# Error E :  0.06255736 
# Error F :  0.07268452 
# Error G :  0.1324677 

indices <- sample(1:nrow(data.train.normalized), 10000)
data.train.normalized.10000 <- data.train.normalized[indices,]

# cost
load(file.path("last_model", "model_glm_cost_restricted.RData"))
data.train.normalized$real_cost <- predict(model.cost.restricted, newdata=data.train.normalized)

# model.A.0 <- glm(I(real_A == "0") ~ . - group_size_factor, data=data.train.normalized.10000, family=binomial)
# anova.model.A.0 <- anova(model.A.0)
# df.anova.model.A.0 <- data.frame(anova.model.A.0)

model.A.0.restricted <- glm(
  I(real_A == "0") ~ 
    car_age + 
    prc_location_shopped_A_0 +
    last_A +
    real_cost,
  data=data.train.normalized,
  family=binomial
    )

# model.A.1 <- glm(I(real_A == "1") ~ ., data=data.train.normalized.10000, family=binomial)
# anova.model.A.1 <- anova(model.A.1)
# df.anova.model.A.1 <- data.frame(anova.model.A.1)

model.A.1.restricted <- glm(
  I(real_A == "1") ~ 
    car_age + 
    prc_location_shopped_A_1 +
    last_A +
    real_cost,
  data=data.train.normalized,
  family=binomial
)


# model.A.2 <- glm(I(real_A == "2") ~ ., data=data.train.normalized.10000, family=binomial)
# anova.model.A.2 <- anova(model.A.2)
# df.anova.model.A.2 <- data.frame(anova.model.A.2)

model.A.2.restricted <- glm(
  I(real_A == "2") ~ 
    car_age +
    I(1-prc_location_shopped_A_0-prc_location_shopped_A_1) +
    last_A +
    real_cost,
  data=data.train.normalized,
  family=binomial
)

save(
  model.A.0.restricted,
  model.A.1.restricted,
  model.A.2.restricted,
  file = file.path("last_model", "model_glm_A_restricted_cascade.RData")
  )


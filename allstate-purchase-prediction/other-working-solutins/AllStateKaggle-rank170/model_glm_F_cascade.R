source("reboot_data.R")

# Error A :  0.07114792 
# Error B :  0.06585746 
# Error C :  0.0690338 
# Error D :  0.05045015 
# Error E :  0.06255736 
# Error F :  0.07268452 
# Error G :  0.1324677 

# F super intéressant pour A (6056)
# A super intéressant pour A (7867)

# Calcul A puis F

indices <- sample(1:nrow(data.train.normalized), 10000)
data.train.normalized.10000 <- data.train.normalized[indices,]

# cost
load(file.path("last_model", "model_glm_cost_restricted.RData"))
data.train.normalized$real_cost <- predict(model.cost.restricted, newdata=data.train.normalized)

# model.F.0 <- glm(I(real_F == "0") ~ ., data=data.train.normalized.10000, family=binomial)
# anova.model.F.0 <- anova(model.F.0)
# df.anova.model.F.0 <- data.frame(anova.model.F.0)

model.F.0.restricted <- glm(
  I(real_F == "0") ~ 
    car_age +
    prc_location_shopped_F_0 +
    last_F +
    real_cost,
  data=data.train.normalized,
  family=binomial
)


# model.F.1 <- glm(I(real_F == "1") ~ ., data=data.train.normalized.10000, family=binomial)
# anova.model.F.1 <- anova(model.F.1)
# df.anova.model.F.1 <- data.frame(anova.model.F.1)

model.F.1.restricted <- glm(
  I(real_F == "1") ~ 
    car_age +
    prc_location_shopped_F_1 +
    last_F +
    real_cost,
  data=data.train.normalized,
  family=binomial
)


# model.F.2 <- glm(I(real_F == "2") ~ ., data=data.train.normalized.10000, family=binomial)
# anova.model.F.2 <- anova(model.F.2)
# df.anova.model.F.2 <- data.frame(anova.model.F.2)

model.F.2.restricted <- glm(
  I(real_F == "2") ~
    car_age + 
    prc_location_shopped_F_2 +
    last_F +
    real_cost,
  data=data.train.normalized,
  family=binomial
)


# model.F.3 <- glm(I(real_F == "3") ~ ., data=data.train.normalized.10000, family=binomial)
# anova.model.F.3 <- anova(model.F.3)
# df.anova.model.F.3 <- data.frame(anova.model.F.3)

model.F.3.restricted <- glm(
  I(real_F == "3") ~ 
    car_age +
    I(1-prc_location_shopped_F_0-prc_location_shopped_F_1-prc_location_shopped_F_2) +
    last_F +
    real_cost,
  data=data.train.normalized,
  family=binomial
)

save(
  model.F.0.restricted,
  model.F.1.restricted,
  model.F.2.restricted,
  model.F.3.restricted,
  file = file.path("last_model", "model_glm_F_restricted_cascade.RData")
)


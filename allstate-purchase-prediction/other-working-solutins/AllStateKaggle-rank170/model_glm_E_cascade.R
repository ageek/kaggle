source("reboot_data.R")

indices <- sample(1:nrow(data.train.normalized), 10000)
data.train.normalized.10000 <- data.train.normalized[indices,]

# cost
load(file.path("last_model", "model_glm_cost_restricted.RData"))
data.train.normalized$real_cost <- predict(model.cost.restricted, newdata=data.train.normalized)

# model.E.0 <- glm(I(real_E == "0") ~ ., data=data.train.normalized.10000, family=binomial)
# anova.model.E.0 <- anova(model.E.0)
# df.anova.model.E.0 <- data.frame(anova.model.E.0)

model.E.0.restricted <- glm(
  I(real_E == "0") ~ 
    car_age +
    prc_location_shopped_E_0 +
    last_A +
    last_E +
    real_cost,
  data=data.train.normalized,
  family=binomial
)

# model.E.1 <- glm(I(real_E == "1") ~ ., data=data.train.normalized.10000, family=binomial)
# anova.model.E.1 <- anova(model.E.1)
# df.anova.model.E.1 <- data.frame(anova.model.E.1)

model.E.1.restricted <- glm(
  I(real_E == "1") ~ 
    car_age +
    I(1 - prc_location_shopped_E_0) +
    last_A +
    last_E +
    real_cost,
  data=data.train.normalized,
  family=binomial
)

save(
  model.E.0.restricted,
  model.E.1.restricted,
  file = file.path("last_model", "model_glm_E_restricted_cascade.RData")
)


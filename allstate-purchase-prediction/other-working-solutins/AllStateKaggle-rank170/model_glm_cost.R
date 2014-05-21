source("reboot_data.R")

indices <- sample(1:nrow(data.train.normalized), 10000)
data.train.normalized.10000 <- data.train.normalized[indices,]

model.cost <- glm(real_cost ~ ., data=data.train.normalized.10000, family=gaussian)
anova.model.cost <- anova(model.cost)
df.anova.model.cost <- data.frame(anova.model.cost)

model.cost.restricted <- glm(
  real_cost ~ 
    last_A +
    last_cost +
    car_age +
    state +
    risk_factor +
    age_oldest +
    homeowner +
    car_value +
    age_youngest +
    prc_location_shopped_E_0 +
    prc_location_shopped_F_0,
  data=data.train.normalized,
  family=gaussian
    )

save(
  model.cost.restricted,
  file = file.path("last_model", "model_glm_cost_restricted.RData")
  )


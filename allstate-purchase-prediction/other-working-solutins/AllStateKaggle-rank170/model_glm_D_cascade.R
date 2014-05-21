source("reboot_data.R")

indices <- sample(1:nrow(data.train.normalized), 10000)
data.train.normalized.10000 <- data.train.normalized[indices,]

# cost
load(file.path("last_model", "model_glm_cost_restricted.RData"))
data.train.normalized$real_cost <- predict(model.cost.restricted, newdata=data.train.normalized)

# model.D.1 <- glm(I(real_D == "1") ~ ., data=data.train.normalized.10000, family=binomial)
# anova.model.D.1 <- anova(model.D.1)
# df.anova.model.D.1 <- data.frame(anova.model.D.1)

model.D.1.restricted <- glm(
  I(real_D == "1") ~ 
    C_previous +
    prc_location_shopped_D_1 +
    last_D +
    real_cost,
  data=data.train.normalized,
  family=binomial
)

# model.D.2 <- glm(I(real_D == "2") ~ ., data=data.train.normalized.10000, family=binomial)
# anova.model.D.2 <- anova(model.D.2)
# df.anova.model.D.2 <- data.frame(anova.model.D.2)

model.D.2.restricted <- glm(
  I(real_D == "2") ~ 
    C_previous +
    prc_location_shopped_D_2 +
    last_D +
    real_cost,
  data=data.train.normalized,
  family=binomial
)

# model.D.3 <- glm(I(real_D == "3") ~ ., data=data.train.normalized.10000, family=binomial)
# anova.model.D.3 <- anova(model.D.3)
# df.anova.model.D.3 <- data.frame(anova.model.D.3)

model.D.3.restricted <- glm(
  I(real_D == "3") ~ 
    C_previous +
    I(1-prc_location_shopped_D_1-prc_location_shopped_D_2) +
    last_D +
    real_cost,
  data=data.train.normalized,
  family=binomial
)

save(
  model.D.1.restricted,
  model.D.2.restricted,
  model.D.3.restricted,
  file = file.path("last_model", "model_glm_D_restricted_cascade.RData")
)


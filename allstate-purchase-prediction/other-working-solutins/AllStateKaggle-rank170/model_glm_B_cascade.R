source("reboot_data.R")

indices <- sample(1:nrow(data.train.normalized), 10000)
data.train.normalized.10000 <- data.train.normalized[indices,]

# cost
load(file.path("last_model", "model_glm_cost_restricted.RData"))
data.train.normalized$real_cost <- predict(model.cost.restricted, newdata=data.train.normalized)

# model.B.0 <- glm(I(real_B == "0") ~ ., data=data.train.normalized.10000, family=binomial)
# anova.model.B.0 <- anova(model.B.0)
# df.anova.model.B.0 <- data.frame(anova.model.B.0)

model.B.0.restricted <- glm(
  I(real_B == "0") ~ 
    prc_location_shopped_B_0 +
    last_B,
    data=data.train.normalized,
  family=binomial
)

# model.B.1 <- glm(I(real_B == "1") ~ ., data=data.train.normalized.10000, family=binomial)
# anova.model.B.1 <- anova(model.B.1)
# df.anova.model.B.1 <- data.frame(anova.model.B.1)

model.B.1.restricted <- glm(
  I(real_B == "1") ~ 
    I(1-prc_location_shopped_B_0) +
    last_B,
  data=data.train.normalized,
  family=binomial
)

save(
  model.B.0.restricted,
  model.B.1.restricted,
  file = file.path("last_model", "model_glm_B_restricted_cascade.RData")
  )


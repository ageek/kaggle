source("reboot_data.R")

indices <- sample(1:nrow(data.train.normalized), 10000)
data.train.normalized.10000 <- data.train.normalized[indices,]

model.A.0.F.0 <- glm(I(real_A == "0" & real_F == "0") ~ ., data=data.train.normalized.10000, family=binomial)
anova.model.A.0.F.0 <- anova(model.A.0.F.0)
df.anova.model.A.0.F.0 <- data.frame(anova.model.A.0.F.0)

model.A.0.F.0.restricted <- glm(
  I(real_A == "0" & real_F == "0") ~ 
    C_previous +
    car_age + 
    nb_shopped_A_0 +
    prc_location_shopped_A_0 + 
    prc_location_shopped_F_0 + 
    last_A +
    last_F,
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
    last_A,
  data=data.train.normalized,
  family=binomial
)


model.A.2 <- glm(I(real_A == "2") ~ ., data=data.train.normalized.10000, family=binomial)
anova.model.A.2 <- anova(model.A.2)
df.anova.model.A.2 <- data.frame(anova.model.A.2)

model.A.2.restricted <- glm(
  I(real_A == "2") ~ 
    car_age + 
    I(1-prc_location_shopped_A_1-prc_location_shopped_A_0) +
    last_A,
  data=data.train.normalized,
  family=binomial
)

save(
  model.A.0.restricted,
  model.A.1.restricted,
  model.A.2.restricted,
  file = file.path("last_model", "model_glm_A_restricted.RData")
  )


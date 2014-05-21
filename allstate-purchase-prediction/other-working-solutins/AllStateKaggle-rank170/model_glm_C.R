source("reboot_data.R")

indices <- sample(1:nrow(data.train.normalized), 10000)
data.train.normalized.10000 <- data.train.normalized[indices,]

model.C.1 <- glm(I(real_C == "1") ~ ., data=data.train.normalized.10000, family=binomial)
anova.model.C.1 <- anova(model.C.1)
df.anova.model.C.1 <- data.frame(anova.model.C.1)

model.C.1.restricted <- glm(
  I(real_C == "1") ~ 
    C_previous +
    prc_location_shopped_C_1 +
    last_C,
  data=data.train.normalized,
  family=binomial
)

model.C.2 <- glm(I(real_C == "2") ~ ., data=data.train.normalized.10000, family=binomial)
anova.model.C.2 <- anova(model.C.2)
df.anova.model.C.2 <- data.frame(anova.model.C.2)

model.C.2.restricted <- glm(
  I(real_C == "2") ~ 
    C_previous +
    prc_location_shopped_C_2 +
    last_C,
  data=data.train.normalized,
  family=binomial
)

model.C.3 <- glm(I(real_C == "3") ~ ., data=data.train.normalized.10000, family=binomial)
anova.model.C.3 <- anova(model.C.3)
df.anova.model.C.3 <- data.frame(anova.model.C.3)

model.C.3.restricted <- glm(
  I(real_C == "3") ~ 
    C_previous +
    prc_location_shopped_C_3 +
    last_C,
  data=data.train.normalized,
  family=binomial
)


model.C.4 <- glm(I(real_C == "4") ~ ., data=data.train.normalized.10000, family=binomial)
anova.model.C.4 <- anova(model.C.4)
df.anova.model.C.4 <- data.frame(anova.model.C.4)

model.C.4.restricted <- glm(
  I(real_C == "4") ~ 
    C_previous +
    I(1-prc_location_shopped_C_1-prc_location_shopped_C_2-prc_location_shopped_C_3) +
    last_C,
  data=data.train.normalized,
  family=binomial
)

save(
  model.C.1.restricted,
  model.C.2.restricted,
  model.C.3.restricted,
  model.C.4.restricted,
  file = file.path("last_model", "model_glm_C_restricted.RData")
  )


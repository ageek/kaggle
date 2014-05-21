source("reboot_data.R")

indices <- sample(1:nrow(data.train.normalized), 10000)
data.train.normalized.10000 <- data.train.normalized[indices,]

model.G.1 <- glm(I(real_G == "1") ~ ., data=data.train.normalized.10000, family=binomial)
anova.model.G.1 <- anova(model.G.1)
df.anova.model.G.1 <- data.frame(anova.model.G.1)

model.G.1.restricted <- glm(
  I(real_G == "1") ~ 
    prc_location_shopped_G_1 +
    last_G,
  data=data.train.normalized,
  family=binomial
)


model.G.2 <- glm(I(real_G == "2") ~ ., data=data.train.normalized.10000, family=binomial)
anova.model.G.2 <- anova(model.G.2)
df.anova.model.G.2 <- data.frame(anova.model.G.2)

model.G.2.restricted <- glm(
  I(real_G == "2") ~
    prc_location_shopped_G_2 +
    last_G,
  data=data.train.normalized,
  family=binomial
)


model.G.3 <- glm(I(real_G == "3") ~ ., data=data.train.normalized.10000, family=binomial)
anova.model.G.3 <- anova(model.G.3)
df.anova.model.G.3 <- data.frame(anova.model.G.3)

model.G.3.restricted <- glm(
  I(real_G == "3") ~ 
    prc_location_shopped_G_1 +
    prc_location_shopped_G_2 +
    prc_location_shopped_G_3 +
    last_G,
  data=data.train.normalized,
  family=binomial
)

model.G.4 <- glm(I(real_G == "4") ~ ., data=data.train.normalized.10000, family=binomial)
anova.model.G.4 <- anova(model.G.4)
df.anova.model.G.4 <- data.frame(anova.model.G.4)

model.G.4.restricted <- glm(
  I(real_G == "4") ~ 
    I(1 - prc_location_shopped_G_1 - prc_location_shopped_G_2 - prc_location_shopped_G_3) +    
    last_G,
  data=data.train.normalized,
  family=binomial
)



save(
  model.G.1.restricted,
  model.G.2.restricted,
  model.G.3.restricted,
  model.G.4.restricted,
  file = file.path("last_model", "model_glm_G_restricted.RData")
)


library(caret)
library(randomForest)

# fonctions
source("functions.R")

# Chargement des données d'entrainement
source("get_data.R")

# Check
load(file=file.path("DATA","OUTPUT","first_model_G.RData"))


data$predict_glm_1 <- predict(model_1_final_G, newdata=data)
data$predict_glm_2 <- predict(model_2_final_G, newdata=data)
data$predict_glm_3 <- predict(model_3_final_G, newdata=data)
data$predict_glm_4 <- predict(model_4_final_G, newdata=data)

data$predicted_glm_G <- factor(max.col(data[,c("predict_glm_1","predict_glm_2","predict_glm_3","predict_glm_4")]))

# Plot fest
library(ggplot2)
library(reshape2)

df <- data[, c("real_G","predict_glm_1","predict_glm_2","predict_glm_3","predict_glm_4")]
df$customer_ID <- rownames(df)

m <- melt(df, id.vars=c("customer_ID","real_G"))

ggplot(m) + geom_density(aes(x=value)) + facet_grid(variable ~ real_G)


wrong.2 <- data[data$predict_glm_2 < 0 & data$real_G == "2",]

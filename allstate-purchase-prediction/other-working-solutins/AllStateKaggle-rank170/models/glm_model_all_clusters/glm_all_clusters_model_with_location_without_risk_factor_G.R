
# Variables
y.letter <- "G"
y.variable <- "real_G"
percent.train <- .8
seed.value <- 42

start.check <- .9
end.check <- .9
step.check <- .2

type <- "with_location_without_risk_factor"

print(paste("Calcul model ", y.letter," ",type,"...", sep = ""))

csv.output.filename <- file.path("DATA","OUTPUT",paste("result_model_glm_all_clusters_", type,"_", y.letter, ".csv", sep = ""))
RData.output.filename <- file.path("DATA","OUTPUT",paste("first_model_glm_all_clusters_", type,"_", y.letter, ".RData", sep = ""))

# Formules
formula_1 <- formula(
  paste("I(",y.variable," == \"1\") ~ .", sep = "")
)

formula_2 <- formula(
  paste("I(",y.variable," == \"2\") ~ .", sep = "")
)

formula_3 <- formula(
  paste("I(",y.variable," == \"3\") ~ .", sep = "")
)

formula_4 <- formula(
  paste("I(",y.variable," == \"4\") ~ .", sep = "")
)

# fonctions
source(file.path("templates","functions.R"))
source(file.path("templates","get_data", paste("get_data_glm_model_", type, ".R", sep = "")))

# train.data <- subset(train.data, min_nb_erreur <= 2)
train.data <- train.data[, colnames(train.data) != "min_nb_erreur"]

source(file.path("templates","split_data", "test_train_skeleton_all_clusters.R"))
source(file.path("templates","glm_estimate", paste("glm_skeleton_error_estimate_",y.letter,".R", sep="")))

source(file.path("templates","split_data", "test_train_skeleton_all_clusters.R"))
source(file.path("templates","glm_train", paste("glm_skeleton_final_training_", y.letter, ".R", sep="")))


print("Calcul model B...")

# Variables
y.letter <- "B"
y.variable <- "real_B"
percent.train <- .8
seed.value <- 42

start.check <- .5
end.check <- .9
step.check <- .2

csv.output.filename <- file.path("DATA","OUTPUT","result_model_gbm_all_clusters_B.csv")
RData.output.filename <- file.path("DATA","OUTPUT","first_model_gbm_all_clusters_B.RData")

# Formules
formula_0 <- formula(
  paste("I(",y.variable," == \"0\") ~ .", sep = "")
)

formula_1 <- formula(
  paste("I(",y.variable," == \"1\") ~ .", sep = "")
)

# fonctions
source(file.path("templates","functions.R"))
source(file.path("templates","get_data_glm_model_with_error.R"))
source(file.path("templates","test_train_skeleton_all_clusters.R"))
source(file.path("templates","gbm_skeleton_error_estimate_B.R"))
source(file.path("templates","gbm_skeleton_final_training_B.R"))

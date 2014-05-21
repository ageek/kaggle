
# Variables
y.letter <- "F"
y.variable <- "real_F"
percent.train <- .8
seed.value <- 42

start.check <- .5
end.check <- .9
step.check <- .2

csv.output.filename <- file.path("DATA","OUTPUT","result_model_glm_all_clusters_F.csv")
RData.output.filename <- file.path("DATA","OUTPUT","first_model_glm_all_clusters_F.RData")

# Formules
formula_0 <- formula(
  paste("I(",y.variable," == \"0\") ~ .", sep = "")
)

formula_1 <- formula(
  paste("I(",y.variable," == \"1\") ~ .", sep = "")
)

formula_2 <- formula(
  paste("I(",y.variable," == \"2\") ~ .", sep = "")
)

formula_3 <- formula(
  paste("I(",y.variable," == \"3\") ~ .", sep = "")
)

# fonctions
source(file.path("templates","functions.R"))
source(file.path("templates","get_data.R"))
source(file.path("templates","test_train_skeleton_all_clusters.R"))
source(file.path("templates","glm_skeleton_error_estimate_F.R"))
source(file.path("templates","glm_skeleton_final_training_F.R"))

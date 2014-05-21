
# Variables
y.letter <- "G"
y.variable <- "real_G"
percent.train <- .8
seed.value <- 42

start.check <- .5
end.check <- .9
step.check <- .2

csv.output.filename <- file.path("DATA","OUTPUT","result_model_svm_all_clusters_G.csv")
RData.output.filename <- file.path("DATA","OUTPUT","first_model_svm_all_clusters_G.RData")

# Formules
formula_svm_linear <- formula(
  paste(y.variable," ~ .", sep = "")
)

formula_svm_radial <- formula(
  paste(y.variable," ~ .", sep = "")
)

formula_svm_polynomial <- formula(
  paste(y.variable," ~ .", sep = "")
)

# fonctions
source(file.path("templates","functions.R"))
source(file.path("templates","get_data.R"))
source(file.path("templates","test_train_skeleton_all_clusters.R"))
source(file.path("templates","svm_skeleton_error_estimate_G.R"))
source(file.path("templates","svm_skeleton_final_training_G.R"))

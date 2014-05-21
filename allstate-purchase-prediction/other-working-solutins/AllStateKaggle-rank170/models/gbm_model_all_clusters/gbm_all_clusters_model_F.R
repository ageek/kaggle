
print("Calcul model F...")

# Variables
y.letter <- "F"
y.variable <- "real_F"
percent.train <- .8
seed.value <- 42

start.check <- .5
end.check <- .9
step.check <- .2

csv.output.filename <- file.path("DATA","OUTPUT","result_model_gbm_all_clusters_F.csv")
RData.output.filename <- file.path("DATA","OUTPUT","first_model_gbm_all_clusters_F.RData")

# Formules
formula_0 <- formula(
  I(real_F == 0) ~ .
  )

formula_1 <- formula(
  I(real_F == 1) ~ .
)

formula_2 <- formula(
  I(real_F == 2) ~ .
)

formula_3 <- formula(
  I(real_F == 3) ~ .
)

# fonctions
source(file.path("templates","functions.R"))
source(file.path("templates","get_data_glm_model_with_error.R"))
source(file.path("templates","test_train_skeleton_all_clusters.R"))
source(file.path("templates","gbm_skeleton_error_estimate_F.R"))
source(file.path("templates","gbm_skeleton_final_training_F.R"))

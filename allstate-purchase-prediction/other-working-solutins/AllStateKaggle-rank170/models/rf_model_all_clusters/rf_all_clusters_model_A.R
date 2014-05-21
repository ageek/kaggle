
print("Calcul model A...")

# Variables
y.letter <- "A"
y.variable <- "real_A"
percent.train <- .8
seed.value <- 42

start.check <- .5
end.check <- .9
step.check <- .2

csv.output.filename <- file.path("DATA","OUTPUT","result_model_rf_all_clusters_A.csv")
RData.output.filename <- file.path("DATA","OUTPUT","first_model_rf_all_clusters_A.RData")

# Formules
formula_rf <- formula(
  real_A ~  
  A0_count +
  F0_count +
  shopping_pt_2_F +
  shopping_pt_2_cost +
  shopping_pt_min_cost_cost +
  shopping_pt_3_cost +
  last_cost +
  last_E +
  shopping_pt_3_F +
  car_age_cut +
  A1_count +
  shopping_pt_min_cost_F +
  A2_count +
  shopping_pt_2_A +
  car_age +
  last_F +
  shopping_pt_3_A +
  # shopping_pt_min_cost_A +
  last_A                                                                             
    )

# fonctions
source(file.path("templates","functions.R"))
source(file.path("templates","get_data_glm_model_with_error.R"))
source(file.path("templates","test_train_skeleton_all_clusters.R"))
source(file.path("templates","rf_skeleton_error_estimate_A.R"))
source(file.path("templates","rf_skeleton_final_training_A.R"))

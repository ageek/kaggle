source(file.path("templates", "functions.R"))

# Préparation des données
train.data <- read.csv(file=file.path("DATA","TMP", "glm_train_data.csv"))
train.data <- normalize.train.data(train.data, with.location=FALSE, with.risk.factor=TRUE)

#test.data <- get.data.glm.model.test()
#test.data <- normalize.test.data(test.data)

# functions
select.final.variable <- function(data, letter) {
  col <- ! (grepl("real",colnames(data)) & ! grepl(paste("real",letter, sep="_"), colnames(data)))
  return(data[,col])
}


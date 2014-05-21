library(RSQLite)
library(plyr)

csv.filename.train <- file.path("DATA", "TMP", "glm_train_data.csv")
csv.filename.test <- file.path("DATA", "TMP", "glm_test_data.csv")

# train
data.train <- read.csv(file=csv.filename.train)


# test get
sqlitedb.filename <- file.path("db", "allstate_data.sqlite3")

drv <- dbDriver("SQLite")
con <- dbConnect(drv, dbname=sqlitedb.filename)

data.test <- dbGetQuery(
  con,
  "
  select
  *
  from data_test_model_glm_first
  "
  )

dbDisconnect(con)

# agg location
columns.location <- colnames(data.train)[grepl("location", colnames(data.train))]
data.agg.location <- data.train[,columns.location]
data.agg.location <- unique(data.agg.location)

# comptage par location et risk factor
tmp <- merge(data.test, data.agg.location, by="location", all.x = TRUE)

cat("Ecriture de", csv.filename.test, "\n")
write.csv(x=tmp, file=csv.filename.test, row.names = FALSE)

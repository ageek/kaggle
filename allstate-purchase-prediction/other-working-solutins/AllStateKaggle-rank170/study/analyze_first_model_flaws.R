library(ggplot2)

# fonctions
source("functions.R")

# Chargement des données d'entrainement
source("get_data.R")

# Lecteur data
dataTrainBase <- read.csv(file=gzfile(file.path("DATA","train_first_model_prediction.csv.gz")))
dataTestBase <- read.csv(file=gzfile(file.path("DATA","test_first_model_prediction.csv.gz")))

# check
dataTrainBase <- compute.ABCDEF(dataTrainBase)
dataTestBase <- compute.ABCDEF(dataTestBase)

dataTrainBase <- compute.ABCDEFG(dataTrainBase)
dataTestBase <- compute.ABCDEFG(dataTestBase)

# List most common
library(RSQLite)

sqlitedb.filename <- "allstate_data.sqlite3"

drv <- dbDriver("SQLite")
con <- dbConnect(drv, dbname=sqlitedb.filename)

data <- dbGetQuery(con,
"
select
A || B || C || D || E || F as ABCDEF,
G,
count(*) as num_occurence
from
transactions
where
record_type = 1
group by 1,2
"
)

dbDisconnect(con)

data <- data[order(-data$num_occurence),]
data$percent <- data$num_occurence/sum(data$num_occurence)

# Wrong G
wrong_G <- dataTestBase[dataTestBase$predicted_ABCDEF == dataTestBase$real_ABCDEF & dataTestBase$predicted_G != dataTestBase$real_G,]

dataTestBase$OK_ABCDEF <- (dataTestBase$predicted_ABCDEF == dataTestBase$real_ABCDEF)
dataTestBase$OK_G <- (dataTestBase$predicted_G == dataTestBase$real_G)

dataTestBase$num_error_ABCDEFG <- num.errors(dataTestBase$predicted_ABCDEFG, dataTestBase$real_ABCDEFG)

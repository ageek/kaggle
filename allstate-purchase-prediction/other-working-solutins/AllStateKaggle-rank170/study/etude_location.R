library(RSQLite)

# Location communes test et train
sqlitedb.filename <- "allstate_data.sqlite3"

drv <- dbDriver("SQLite")
con <- dbConnect(drv, dbname=sqlitedb.filename)

data.location <- dbGetQuery(
  con,
  "
  select
  location,
  count(*) as nb_achat
  from transactions
  where record_type = 1
  group by 1
  "                
)

dbDisconnect(con)

data.location <- data.location[order(-data.location$nb_achat),]

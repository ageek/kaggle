library(RSQLite)
library(plyr)

csv.filename <- file.path("DATA", "TMP", "glm_train_data.csv")

sqlitedb.filename <- file.path("db", "allstate_data.sqlite3")

drv <- dbDriver("SQLite")
con <- dbConnect(drv, dbname=sqlitedb.filename)

data <- dbGetQuery(
  con,
  "
  select
  *
  from data_train_model_glm_first
  "
  )

dbDisconnect(con)

# comptage par location
print("Aggregation par location")
data <- ddply(
  data,
  .(location),
  transform,
  A0_location_pct=A0_count/(A0_count+A1_count+A2_count),
  A1_location_pct=A1_count/(A0_count+A1_count+A2_count),
  B0_location_pct=B0_count/(B0_count+B1_count),
  C1_location_pct=C1_count/(C1_count+C2_count+C3_count+C4_count),
  C2_location_pct=C2_count/(C1_count+C2_count+C3_count+C4_count),
  C3_location_pct=C3_count/(C1_count+C2_count+C3_count+C4_count),
  D1_location_pct=D1_count/(D1_count+D2_count+D3_count),
  D2_location_pct=D2_count/(D1_count+D2_count+D3_count),
  E0_location_pct=E0_count/(E0_count+E1_count),
  F0_location_pct=F0_count/(F0_count+F1_count+F2_count+F3_count),
  F1_location_pct=F1_count/(F0_count+F1_count+F2_count+F3_count),
  F2_location_pct=F2_count/(F0_count+F1_count+F2_count+F3_count),
  G1_location_pct=G1_count/(G1_count+G2_count+G3_count+G4_count),
  G2_location_pct=G2_count/(G1_count+G2_count+G3_count+G4_count),
  G3_location_pct=G3_count/(G1_count+G2_count+G3_count+G4_count)
)

cat("Ecriture de", csv.filename, "\n")
write.csv(x=data, file=csv.filename, row.names = FALSE)

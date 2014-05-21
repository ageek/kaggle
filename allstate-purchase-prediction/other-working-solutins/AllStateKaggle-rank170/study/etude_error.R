library(RSQLite)
library(plyr)
library(reshape2)

# Infos de bases
sqlitedb.filename <- "allstate_data.sqlite3"

drv <- dbDriver("SQLite")
con <- dbConnect(drv, dbname=sqlitedb.filename)

data <- dbGetQuery(
  con,
  "
  select
  customer_ID,
  error_A,
  error_B,
  error_C,
  error_D,
  error_E,
  error_F,
  error_G,
  error_A+error_B+error_C+error_D+error_E+error_F+error_G as total_error
  from
  (
  select
  T1.customer_ID,
  case when T1.A = T2.A then 0 else 1 end as error_A,
  case when T1.B = T2.B then 0 else 1 end as error_B,
  case when T1.C = T2.C then 0 else 1 end as error_C,
  case when T1.D = T2.D then 0 else 1 end as error_D,
  case when T1.E = T2.E then 0 else 1 end as error_E,
  case when T1.F = T2.F then 0 else 1 end as error_F,
  case when T1.G = T2.G then 0 else 1 end as error_G
  from
  transactions T1 inner join
  transactions T2 on (T1.customer_ID = T2.customer_ID and T1.record_type = 0 and T2.record_type=1)
  where
  T1.shopping_pt = (T2.shopping_pt - 1)
  ) A
  "
)

dbDisconnect(con)

# 

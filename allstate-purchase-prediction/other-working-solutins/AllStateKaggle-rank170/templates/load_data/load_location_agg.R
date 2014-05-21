library(RSQLite)
library(plyr)
library(reshape2)

# Infos de bases
sqlitedb.filename <- file.path("db", "allstate_data.sqlite3")

drv <- dbDriver("SQLite")
con <- dbConnect(drv, dbname=sqlitedb.filename)

data <- dbGetQuery(
con,
"
select
T1.location,
T1.A0_count_location/T2.A0_count_global as A0_percent_location,
T1.A1_count_location/T2.A1_count_global as A1_percent_location,
T1.A2_count_location/T2.A2_count_global as A2_percent_location,
T1.B0_count_location/T2.B0_count_global as B0_percent_location,
T1.B1_count_location/T2.B1_count_global as B1_percent_location,
T1.C1_count_location/T2.C1_count_global as C1_percent_location,
T1.C2_count_location/T2.C2_count_global as C2_percent_location,
T1.C3_count_location/T2.C3_count_global as C3_percent_location,
T1.C4_count_location/T2.C4_count_global as C4_percent_location,
T1.D1_count_location/T2.D1_count_global as D1_percent_location,
T1.D2_count_location/T2.D2_count_global as D2_percent_location,
T1.D3_count_location/T2.D3_count_global as D3_percent_location,
T1.E0_count_location/T2.E0_count_global as E0_percent_location,
T1.E1_count_location/T2.E1_count_global as E1_percent_location,
T1.F0_count_location/T2.F0_count_global as F0_percent_location,
T1.F1_count_location/T2.F1_count_global as F1_percent_location,
T1.F2_count_location/T2.F2_count_global as F2_percent_location,
T1.F3_count_location/T2.F3_count_global as F3_percent_location,
T1.G1_count_location/T2.G1_count_global as G1_percent_location,
T1.G2_count_location/T2.G2_count_global as G2_percent_location,
T1.G3_count_location/T2.G3_count_global as G3_percent_location,
T1.G4_count_location/T2.G4_count_global as G4_percent_location
from
(
  select
  coalesce(location, '') as location,
  1.0*sum(case when A = 0 then 1 else 0 end) as A0_count_location,
  1.0*sum(case when A = 1 then 1 else 0 end) as A1_count_location,
  1.0*sum(case when A = 2 then 1 else 0 end) as A2_count_location,
  1.0*sum(case when B = 0 then 1 else 0 end) as B0_count_location,
  1.0*sum(case when B = 1 then 1 else 0 end) as B1_count_location,
  1.0*sum(case when C = 1 then 1 else 0 end) as C1_count_location,
  1.0*sum(case when C = 2 then 1 else 0 end) as C2_count_location,
  1.0*sum(case when C = 3 then 1 else 0 end) as C3_count_location,
  1.0*sum(case when C = 4 then 1 else 0 end) as C4_count_location,
  1.0*sum(case when D = 1 then 1 else 0 end) as D1_count_location,
  1.0*sum(case when D = 2 then 1 else 0 end) as D2_count_location,
  1.0*sum(case when D = 3 then 1 else 0 end) as D3_count_location,
  1.0*sum(case when E = 0 then 1 else 0 end) as E0_count_location,
  1.0*sum(case when E = 1 then 1 else 0 end) as E1_count_location,
  1.0*sum(case when F = 0 then 1 else 0 end) as F0_count_location,
  1.0*sum(case when F = 1 then 1 else 0 end) as F1_count_location,
  1.0*sum(case when F = 2 then 1 else 0 end) as F2_count_location,
  1.0*sum(case when F = 3 then 1 else 0 end) as F3_count_location,
  1.0*sum(case when G = 1 then 1 else 0 end) as G1_count_location,
  1.0*sum(case when G = 2 then 1 else 0 end) as G2_count_location,
  1.0*sum(case when G = 3 then 1 else 0 end) as G3_count_location,
  1.0*sum(case when G = 4 then 1 else 0 end) as G4_count_location
  from transactions
  where
  record_type = 0
  group by 1
) T1,
(
  select
  1.0*sum(case when A = 0 then 1 else 0 end) as A0_count_global,
  1.0*sum(case when A = 1 then 1 else 0 end) as A1_count_global,
  1.0*sum(case when A = 2 then 1 else 0 end) as A2_count_global,
  1.0*sum(case when B = 0 then 1 else 0 end) as B0_count_global,
  1.0*sum(case when B = 1 then 1 else 0 end) as B1_count_global,
  1.0*sum(case when C = 1 then 1 else 0 end) as C1_count_global,
  1.0*sum(case when C = 2 then 1 else 0 end) as C2_count_global,
  1.0*sum(case when C = 3 then 1 else 0 end) as C3_count_global,
  1.0*sum(case when C = 4 then 1 else 0 end) as C4_count_global,
  1.0*sum(case when D = 1 then 1 else 0 end) as D1_count_global,
  1.0*sum(case when D = 2 then 1 else 0 end) as D2_count_global,
  1.0*sum(case when D = 3 then 1 else 0 end) as D3_count_global,
  1.0*sum(case when E = 0 then 1 else 0 end) as E0_count_global,
  1.0*sum(case when E = 1 then 1 else 0 end) as E1_count_global,
  1.0*sum(case when F = 0 then 1 else 0 end) as F0_count_global,
  1.0*sum(case when F = 1 then 1 else 0 end) as F1_count_global,
  1.0*sum(case when F = 2 then 1 else 0 end) as F2_count_global,
  1.0*sum(case when F = 3 then 1 else 0 end) as F3_count_global,
  1.0*sum(case when G = 1 then 1 else 0 end) as G1_count_global,
  1.0*sum(case when G = 2 then 1 else 0 end) as G2_count_global,
  1.0*sum(case when G = 3 then 1 else 0 end) as G3_count_global,
  1.0*sum(case when G = 4 then 1 else 0 end) as G4_count_global
  from transactions
  where
  record_type = 0
) T2
"
)

dbDisconnect(con)


# Ecriture
drv <- dbDriver("SQLite")
con <- dbConnect(drv, dbname=sqlitedb.filename)

print("Alimentation table location agg")
dbWriteTable(con, "location_agg_view", data)

dbDisconnect(con)

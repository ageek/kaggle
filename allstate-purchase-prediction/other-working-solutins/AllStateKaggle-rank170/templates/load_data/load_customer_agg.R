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
customer_ID,
sum(case when A = 0 then 1 else 0 end) as A0_count,
sum(case when A = 1 then 1 else 0 end) as A1_count,
sum(case when A = 2 then 1 else 0 end) as A2_count,
sum(case when B = 0 then 1 else 0 end) as B0_count,
sum(case when B = 1 then 1 else 0 end) as B1_count,
sum(case when C = 1 then 1 else 0 end) as C1_count,
sum(case when C = 2 then 1 else 0 end) as C2_count,
sum(case when C = 3 then 1 else 0 end) as C3_count,
sum(case when C = 4 then 1 else 0 end) as C4_count,
sum(case when D = 1 then 1 else 0 end) as D1_count,
sum(case when D = 2 then 1 else 0 end) as D2_count,
sum(case when D = 3 then 1 else 0 end) as D3_count,
sum(case when E = 0 then 1 else 0 end) as E0_count,
sum(case when E = 1 then 1 else 0 end) as E1_count,
sum(case when F = 0 then 1 else 0 end) as F0_count,
sum(case when F = 1 then 1 else 0 end) as F1_count,
sum(case when F = 2 then 1 else 0 end) as F2_count,
sum(case when F = 3 then 1 else 0 end) as F3_count,
sum(case when G = 1 then 1 else 0 end) as G1_count,
sum(case when G = 2 then 1 else 0 end) as G2_count,
sum(case when G = 3 then 1 else 0 end) as G3_count,
sum(case when G = 4 then 1 else 0 end) as G4_count,
count(*) as total_count
from transactions
where
record_type = 0
group by 1
"
)

dbDisconnect(con)

# evaluation 
# 
# df <- ddply(
#   data,
#   .(location),
#   function(x) {
#     tmp.A <- (0:2)[order(x[,c("A0","A1","A2")])]
#     tmp.B <- (0:1)[order(x[,c("B0","B1")])]
#     tmp.C <- (1:4)[order(x[,c("C1","C2","C3","C4")])]
#     tmp.D <- (1:3)[order(x[,c("D1","D2","D3")])]
#     tmp.E <- (0:1)[order(x[,c("E0","E1")])]
#     tmp.F <- (0:3)[order(x[,c("F0","F1","F2","F3")])]
#     tmp.G <- (1:4)[order(x[,c("G1","G2","G3","G4")])]
#     data.frame(
#       A_proba_1=tmp.A[3],
#       A_proba_2=tmp.A[2],
#       A_proba_3=tmp.A[1],
#       B_proba_1=tmp.B[2],
#       B_proba_2=tmp.B[1],
#       C_proba_1=tmp.C[4],
#       C_proba_2=tmp.C[3],
#       C_proba_3=tmp.C[2],
#       C_proba_4=tmp.C[1],
#       D_proba_1=tmp.D[3],
#       D_proba_2=tmp.D[2],
#       D_proba_3=tmp.D[1],
#       E_proba_1=tmp.E[2],
#       E_proba_2=tmp.E[1],
#       F_proba_1=tmp.F[4],
#       F_proba_2=tmp.F[3],
#       F_proba_3=tmp.F[2],
#       F_proba_4=tmp.F[1],
#       G_proba_1=tmp.G[4],
#       G_proba_2=tmp.G[3],
#       G_proba_3=tmp.G[2],
#       G_proba_4=tmp.G[1]      
#       )
#   }
#   )

# Ecriture
drv <- dbDriver("SQLite")
con <- dbConnect(drv, dbname=sqlitedb.filename)

print("Alimentation table customers agg")
dbWriteTable(con, "customer_agg", data)

dbDisconnect(con)

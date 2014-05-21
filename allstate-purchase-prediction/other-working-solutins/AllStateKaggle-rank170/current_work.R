library(RSQLite)

sqlitedb.filename <- file.path("db", "allstate_data.sqlite3")

drv <- dbDriver("SQLite")
con <- dbConnect(drv, dbname=sqlitedb.filename)

data.transaction <- dbGetQuery(con,
"
select
T1.customer_ID,
T1.shopping_pt,
T1.record_type,
T1.day,
T1.time,
T1.location,
T1.group_size,
T1.homeowner,
T1.car_age,
T1.car_value,
T1.risk_factor,
T1.age_youngest,
T1.age_oldest,
T1.married_couple,
T1.C_previous,
T1.duration_previous,
T1.A,
case when T2.A is not null then T2.A else -1 end as real_A,
T1.B,
case when T2.B is not null then T2.B else -1 end as real_B,
T1.C,
case when T2.C is not null then T2.C else -1 end as real_C,
T1.D,
case when T2.D is not null then T2.D else -1 end as real_D,
T1.E,
case when T2.E is not null then T2.E else -1 end as real_E,
T1.F,
case when T2.F is not null then T2.F else -1 end as real_F,
T1.G,
case when T2.G is not null then T2.G else -1 end as real_G,
T1.cost
from
transactions T1 left outer join transactions T2 on 
(T1.customer_ID = T2.customer_ID and T2.record_type = 1)
where
T1.record_type = 0 
--and T1.customer_ID = 10000001
"
)

data.customers <- dbGetQuery(con,
                               "
select
customer_ID,
state,
dataset,
random() as random_number
from
customers
"
)

dbDisconnect(con)

# reduction
indices <- which(data.customers$random_number > 1e+09)
data.customers <- data.customers[indices,]

# final dataset
data <- merge(data.transaction, data.customers, by=c("customer_ID"))

# ecriture data
write.csv(data, file="all_data.csv", row.names=FALSE, quote=FALSE)

library(RSQLite)

# Location communes test et train
sqlitedb.filename <- "allstate_data.sqlite3"

drv <- dbDriver("SQLite")
con <- dbConnect(drv, dbname=sqlitedb.filename)

data.location <- dbGetQuery(con,
"
select
location_train.location,
location_train.nb_distinct_customer_ID as nb_distinct_customer_ID_train,
location_test.nb_distinct_customer_ID as nb_distinct_customer_ID_test
from
(
select
T2.location,
count(distinct T1.state) as nb_distinct_state,
count(distinct T2.customer_ID) as nb_distinct_customer_ID
from
customers T1,
transactions T2
where
T1.customer_ID = T2.customer_ID
and
T1.dataset = 'train'
group by 1
) location_train inner join
(
select
T2.location,
count(distinct T1.state) as nb_distinct_state,
count(distinct T2.customer_ID) as nb_distinct_customer_ID
from
customers T1,
transactions T2
where
T1.customer_ID = T2.customer_ID
and
T1.dataset = 'test'
group by 1
) location_test on (location_train.location = location_test.location)

"
)

dbDisconnect(con)

data.location <- data.location[order(-data.location$nb_distinct_customer_ID_train),]


library(RSQLite)
library(plyr)

sqlitedb.filename <- file.path("db", "allstate_data.sqlite3")

drv <- dbDriver("SQLite")
con <- dbConnect(drv, dbname=sqlitedb.filename)

if(dbExistsTable(con, "transactions_with_result")){
  dbRemoveTable(con, "transactions_with_result")
}

data <- dbGetQuery(
  con,
  "
select
T1.customer_ID,
T1.location,
T3.state,
T3.dataset,
T1.shopping_pt,
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
case when T2.A is null then -1 else T2.A end as real_A,
T1.B,
case when T2.B is null then -1 else T2.B end as real_B,
T1.C,
case when T2.C is null then -1 else T2.C end as real_C,
T1.D,
case when T2.D is null then -1 else T2.D end as real_D,
T1.E,
case when T2.E is null then -1 else T2.E end as real_E,
T1.F,
case when T2.F is null then -1 else T2.F end as real_F,
T1.G,
case when T2.G is null then -1 else T2.G end as real_G,
T1.cost
from
transactions T1 left outer join transactions T2 on (T1.customer_ID = T2.customer_ID and T2.record_type = 1)
inner join customers T3 on (T1.customer_ID = T3.customer_ID)
where
T1.record_type = 0
  ")

data$erreur_A <- with(data, ifelse(A != real_A, 1, 0))
data$erreur_B <- with(data, ifelse(B != real_B, 1, 0))
data$erreur_C <- with(data, ifelse(C != real_C, 1, 0))
data$erreur_D <- with(data, ifelse(D != real_D, 1, 0))
data$erreur_E <- with(data, ifelse(E != real_E, 1, 0))
data$erreur_F <- with(data, ifelse(F != real_F, 1, 0))
data$erreur_G <- with(data, ifelse(G != real_G, 1, 0))

data$nb_erreur <- with(data, 
                         erreur_A +
                         erreur_B +
                         erreur_C +
                         erreur_D +
                         erreur_E +
                         erreur_F +
                         erreur_G                         
                       )

dbWriteTable(con, "transactions_with_result", data)
dbGetQuery(con, "create index ix_transactions_with_result_customer_id on transactions_with_result ( customer_ID)")

if(dbExistsTable(con, "customers_train_error")){
  dbRemoveTable(con, "customers_train_error")
}

data <- dbGetQuery(
  con,
  "
select
T1.customer_ID,
min(T1.nb_erreur) as min_nb_erreur,
avg(T1.nb_erreur) as avg_nb_erreur,
max(T1.nb_erreur) as max_nb_erreur
from
transactions_with_result T1 inner join customers T2 on (T1.customer_ID = T2.customer_ID)
where
T2.dataset = 'train'
group by 1
  "
)

dbWriteTable(con, "customers_train_error", data)
dbGetQuery(con, "create unique index ix_customers_train_error_customer_id on customers ( customer_ID)")

if(dbExistsTable(con, "shopping_point_list")){
  dbRemoveTable(con, "shopping_point_list")
}

data <- dbGetQuery(
  con,
  "
select
customer_ID,
dataset,
case when max(shopping_pt) < 2 then max(shopping_pt) else 2 end as shopping_pt_2,
case when max(shopping_pt) < 3 then max(shopping_pt) else 3 end as shopping_pt_3,
max(shopping_pt) as last_shopping_pt
from transactions_with_result
group by 1,2
  "
)

dbWriteTable(con, "shopping_point_list", data)

if(dbExistsTable(con, "shopping_point_min_cost")){
  dbRemoveTable(con, "shopping_point_min_cost")
}

data <- dbGetQuery(
  con,
  "
  select
  A.customer_ID,
  case
    when A.cost < B.cost then
      case 
        when A.cost < C.cost then A.shopping_pt
        else C.shopping_pt 
      end
    else 
      case
        when B.cost < C.cost then B.shopping_pt
        else C.shopping_pt
      end
    end
   as min_cost_shopping_pt
  from
  (
    select
    T1.customer_ID,
    T1.shopping_pt,
    T1.cost
    from transactions_with_result T1 inner join
    shopping_point_list T2 on (T1.customer_ID = T2.customer_ID and T1.shopping_pt = T2.last_shopping_pt)
    group by 1,2
  ) A inner join
  (
    select
    T1.customer_ID,
    T1.shopping_pt,
    T1.cost
    from transactions_with_result T1 inner join
    shopping_point_list T2 on (T1.customer_ID = T2.customer_ID and T1.shopping_pt = T2.shopping_pt_2)
    group by 1,2
  ) B on (A.customer_ID = B.customer_ID) inner join
  (
    select
    T1.customer_ID,
    T1.shopping_pt,
    T1.cost
    from transactions_with_result T1 inner join
    shopping_point_list T2 on (T1.customer_ID = T2.customer_ID and T1.shopping_pt = T2.shopping_pt_3)
    group by 1,2
  ) C on (B.customer_ID = C.customer_ID)
  "
)

dbWriteTable(con, "shopping_point_min_cost", data)


if(dbExistsTable(con, "data_train_model_glm_first")){
  dbRemoveTable(con, "data_train_model_glm_first")
}

data <- dbGetQuery(
  con,
  "
  select
  T1.customer_ID as customer_ID,
  T1.location as location,
  T1.state as state,
  T1.day as day,
  T1.group_size as group_size,
  T1.homeowner as homeowner,
  T1.car_age as car_age,
  T1.car_value as car_value,
  T1.risk_factor as risk_factor,
  T1.age_youngest as age_youngest,
  T1.age_oldest as age_oldest,
  T1.married_couple as married_couple,
  T1.C_previous as C_previous,
  T1.duration_previous as duration_previous,
  T1.cost as last_cost,
  T4.cost as shopping_pt_2_cost,
  T5.cost as shopping_pt_3_cost,
  T6.cost as shopping_pt_min_cost_cost,
  T1.A as last_A,
  T1.B as last_B,
  T1.C as last_C,
  T1.D as last_D,
  T1.E as last_E,
  T1.F as last_F,
  T1.G as last_G,
  T4.A as shopping_pt_2_A,
  T4.B as shopping_pt_2_B,
  T4.C as shopping_pt_2_C,
  T4.D as shopping_pt_2_D,
  T4.E as shopping_pt_2_E,
  T4.F as shopping_pt_2_F,
  T4.G as shopping_pt_2_G,
  T5.A as shopping_pt_3_A,
  T5.B as shopping_pt_3_B,
  T5.C as shopping_pt_3_C,
  T5.D as shopping_pt_3_D,
  T5.E as shopping_pt_3_E,
  T5.F as shopping_pt_3_F,
  T5.G as shopping_pt_3_G,
  T6.A as shopping_pt_min_cost_A,
  T6.B as shopping_pt_min_cost_B,
  T6.C as shopping_pt_min_cost_C,
  T6.D as shopping_pt_min_cost_D,
  T6.E as shopping_pt_min_cost_E,
  T6.F as shopping_pt_min_cost_F,
  T6.G as shopping_pt_min_cost_G,
  coalesce(T7.A0_count, 5) as A0_count,
  coalesce(T7.A1_count, 14) as A1_count,
  coalesce(T7.A2_count, 3) as A2_count,
  coalesce(T7.B0_count, 12) as B0_count,
  coalesce(T7.B1_count, 10) as B1_count,
  coalesce(T7.C1_count, 6) as C1_count,
  coalesce(T7.C2_count, 4) as C2_count,
  coalesce(T7.C3_count, 9) as C3_count,
  coalesce(T7.C4_count, 2) as C4_count,
  coalesce(T7.D1_count, 1) as D1_count,
  coalesce(T7.D2_count, 4) as D2_count,
  coalesce(T7.D3_count, 14) as D3_count,
  coalesce(T7.E0_count, 12) as E0_count,
  coalesce(T7.E1_count, 10) as E1_count,
  coalesce(T7.F0_count, 5) as F0_count,
  coalesce(T7.F1_count, 4) as F1_count,
  coalesce(T7.F2_count, 8) as F2_count,
  coalesce(T7.F3_count, 1) as F3_count,
  coalesce(T7.G1_count, 1) as G1_count,
  coalesce(T7.G2_count, 7) as G2_count,
  coalesce(T7.G3_count, 3) as G3_count,  
  coalesce(T7.G4_count, 1) as G4_count,
  T3.min_nb_erreur as min_nb_erreur,
  T8.nb_views as nb_views,
  T1.real_A as real_A,
  T1.real_B as real_B,
  T1.real_C as real_C,
  T1.real_D as real_D,
  T1.real_E as real_E,
  T1.real_F as real_F,
  T1.real_G as real_G
  from
  transactions_with_result T1 inner join 
  shopping_point_list T2 on (T1.customer_ID = T2.customer_ID) inner join
  customers_train_error T3 on (T2.customer_ID = T3.customer_ID) inner join
  (
  select
  A.*
  from
  transactions_with_result A inner join
  shopping_point_list B on (A.customer_ID = B.customer_ID)
  where
  A.shopping_pt = B.shopping_pt_2
  ) T4 on (T1.customer_ID = T4.customer_ID) inner join
  (
  select
  A.*
  from
  transactions_with_result A inner join
  shopping_point_list B on (A.customer_ID = B.customer_ID)
  where
  A.shopping_pt = B.shopping_pt_3
  ) T5 on (T1.customer_ID = T5.customer_ID) inner join
  (
  select
  A.*
  from
  transactions_with_result A inner join
  shopping_point_min_cost B on (A.customer_ID = B.customer_ID)
  where
  A.shopping_pt = min_cost_shopping_pt
  ) T6 on (T1.customer_ID = T6.customer_ID)
  left outer join
  location_agg T7 on (T1.location = T7.location)
  inner join
  (
    select
    customer_ID,
    count(*) as nb_views
    from
    transactions
    where
    record_type = 0
    group by 1
  ) T8 on (T1.customer_ID = T8.customer_ID)
  where
  T2.dataset = 'train'
  and
  T1.shopping_pt = T2.last_shopping_pt
  --and
  --T3.min_nb_erreur = 0
  "
)

dbWriteTable(con, "data_train_model_glm_first", data)

if(dbExistsTable(con, "data_test_model_glm_first")){
  dbRemoveTable(con, "data_test_model_glm_first")
}

data <- dbGetQuery(
  con,
  "
  select
  T1.customer_ID as customer_ID,
  T1.location as location,
  T1.state as state,
  T1.day as day,
  -- T1.location as location,
  T1.group_size as group_size,
  T1.homeowner as homeowner,
  T1.car_age as car_age,
  T1.car_value as car_value,
  T1.risk_factor as risk_factor,
  T1.age_youngest as age_youngest,
  T1.age_oldest as age_oldest,
  T1.married_couple as married_couple,
  T1.C_previous as C_previous,
  T1.duration_previous as duration_previous,
  T1.cost as last_cost,
  T4.cost as shopping_pt_2_cost,
  T5.cost as shopping_pt_3_cost,
  T6.cost as shopping_pt_min_cost_cost,
  T1.A as last_A,
  T1.B as last_B,
  T1.C as last_C,
  T1.D as last_D,
  T1.E as last_E,
  T1.F as last_F,
  T1.G as last_G,
  T4.A as shopping_pt_2_A,
  T4.B as shopping_pt_2_B,
  T4.C as shopping_pt_2_C,
  T4.D as shopping_pt_2_D,
  T4.E as shopping_pt_2_E,
  T4.F as shopping_pt_2_F,
  T4.G as shopping_pt_2_G,
  T5.A as shopping_pt_3_A,
  T5.B as shopping_pt_3_B,
  T5.C as shopping_pt_3_C,
  T5.D as shopping_pt_3_D,
  T5.E as shopping_pt_3_E,
  T5.F as shopping_pt_3_F,
  T5.G as shopping_pt_3_G,
  T6.A as shopping_pt_min_cost_A,
  T6.B as shopping_pt_min_cost_B,
  T6.C as shopping_pt_min_cost_C,
  T6.D as shopping_pt_min_cost_D,
  T6.E as shopping_pt_min_cost_E,
  T6.F as shopping_pt_min_cost_F,
  T6.G as shopping_pt_min_cost_G,
  coalesce(T7.A0_count, 5) as A0_count,
  coalesce(T7.A1_count, 14) as A1_count,
  coalesce(T7.A2_count, 3) as A2_count,
  coalesce(T7.B0_count, 12) as B0_count,
  coalesce(T7.B1_count, 10) as B1_count,
  coalesce(T7.C1_count, 6) as C1_count,
  coalesce(T7.C2_count, 4) as C2_count,
  coalesce(T7.C3_count, 9) as C3_count,
  coalesce(T7.C4_count, 2) as C4_count,
  coalesce(T7.D1_count, 1) as D1_count,
  coalesce(T7.D2_count, 4) as D2_count,
  coalesce(T7.D3_count, 14) as D3_count,
  coalesce(T7.E0_count, 12) as E0_count,
  coalesce(T7.E1_count, 10) as E1_count,
  coalesce(T7.F0_count, 5) as F0_count,
  coalesce(T7.F1_count, 4) as F1_count,
  coalesce(T7.F2_count, 8) as F2_count,
  coalesce(T7.F3_count, 1) as F3_count,
  coalesce(T7.G1_count, 1) as G1_count,
  coalesce(T7.G2_count, 7) as G2_count,
  coalesce(T7.G3_count, 3) as G3_count,  
  coalesce(T7.G4_count, 1) as G4_count,
  T8.nb_views as nb_views
  --T1.real_A as real_A,
  --T1.real_B as real_B,
  --T1.real_C as real_C,
  --T1.real_D as real_D,
  --T1.real_E as real_E,
  --T1.real_F as real_F,
  --T1.real_G as real_G
  from
  transactions_with_result T1 inner join 
  shopping_point_list T2 on (T1.customer_ID = T2.customer_ID) 
  --inner join
  --customers_train_error T3 on (T2.customer_ID = T3.customer_ID) 
  inner join
  (
  select
  A.*
  from
  transactions_with_result A inner join
  shopping_point_list B on (A.customer_ID = B.customer_ID)
  where
  A.shopping_pt = B.shopping_pt_2
  ) T4 on (T1.customer_ID = T4.customer_ID) inner join
  (
  select
  A.*
  from
  transactions_with_result A inner join
  shopping_point_list B on (A.customer_ID = B.customer_ID)
  where
  A.shopping_pt = B.shopping_pt_3
  ) T5 on (T1.customer_ID = T5.customer_ID) inner join
  (
  select
  A.*
  from
  transactions_with_result A inner join
  shopping_point_min_cost B on (A.customer_ID = B.customer_ID)
  where
  A.shopping_pt = min_cost_shopping_pt
  ) T6 on (T1.customer_ID = T6.customer_ID)
  left outer join
  location_agg T7 on (T1.location = T7.location)
  inner join
  (
    select
    customer_ID,
    count(*) as nb_views
    from
    transactions
    where
    record_type = 0
    group by 1
  ) T8 on (T1.customer_ID = T8.customer_ID)
  where
  T2.dataset = 'test'
  and
  T1.shopping_pt = T2.last_shopping_pt
  --and
  --T3.min_nb_erreur = 0
  "
)

dbWriteTable(con, "data_test_model_glm_first", data)


dbDisconnect(con)

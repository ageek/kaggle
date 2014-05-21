library(RSQLite)

# data shopping point 2 
sqlitedb.filename <- file.path("db", "allstate_data.sqlite3")

drv <- dbDriver("SQLite")
con <- dbConnect(drv, dbname=sqlitedb.filename)

data.2 <- dbGetQuery(
  con,
  "
select
T1.customer_ID as customer_ID,
cust.state as state,
T3.day as day,
T3.time as time,
T3.group_size as group_size,
T3.homeowner as homeowner,
T3.car_age as car_age,
T3.car_value as car_value,
T3.risk_factor as risk_factor,
T3.age_youngest as age_youngest,
T3.age_oldest as age_oldest,
T3.married_couple as married_couple,
T3.C_previous as C_previous,
T3.duration_previous as duration_previous,
T3.cost as value_cost_pt_2,
T4.avg_cost as avg_cost,
T4.min_cost as min_cost,
T4.max_cost as max_cost,
T3.A as value_A_pt_2,
T3.B as value_B_pt_2,
T3.C as value_C_pt_2,
T3.D as value_D_pt_2,
T3.E as value_E_pt_2,
T3.F as value_F_pt_2,
T3.G as value_G_pt_2,
T5.A as first_A,
T5.B as first_B,
T5.C as first_C,
T5.D as first_D,
T5.E as first_E,
T5.F as first_F,
T5.G as first_G,
T2.A as real_A,
T2.B as real_B,
T2.C as real_C,
T2.D as real_D,
T2.E as real_E,
T2.F as real_F,
T2.G as real_G
from
transactions T1
inner join
customers cust on (T1.customer_ID = cust.customer_ID and cust.dataset = 'train')
inner join
(
select
*
from
transactions
where
record_type = 1
) T2 on (T1.customer_ID = T2.customer_ID)
inner join
(
select
*
from
transactions
where
shopping_pt = 2
) T3 on (T1.customer_ID = T3.customer_ID and T1.shopping_pt = T3.shopping_pt)
inner join
(
select
customer_ID,
avg(cost) as avg_cost,
min(cost) as min_cost,
max(cost) as max_cost
from
transactions
where shopping_pt <= 2
group by 1
) T4 on (T1.customer_ID = T4.customer_ID)
inner join
(
select
*
from
transactions
where
shopping_pt = 1
) T5 on (T1.customer_ID = T5.customer_ID)
  "
  )

data.3 <- dbGetQuery(
  con,
  "
  select
  T1.customer_ID as customer_ID,
  cust.state as state,
  T3.day as day,
  T3.time as time,
  T3.group_size as group_size,
  T3.homeowner as homeowner,
  T3.car_age as car_age,
  T3.car_value as car_value,
  T3.risk_factor as risk_factor,
  T3.age_youngest as age_youngest,
  T3.age_oldest as age_oldest,
  T3.married_couple as married_couple,
  T3.C_previous as C_previous,
  T3.duration_previous as duration_previous,
  T3.cost as value_cost_pt_3,
  T4.avg_cost as avg_cost,
  T4.min_cost as min_cost,
  T4.max_cost as max_cost,
  T3.A as value_A_pt_3,
  T3.B as value_B_pt_3,
  T3.C as value_C_pt_3,
  T3.D as value_D_pt_3,
  T3.E as value_E_pt_3,
  T3.F as value_F_pt_3,
  T3.G as value_G_pt_3,
  T5.A as first_A,
  T5.B as first_B,
  T5.C as first_C,
  T5.D as first_D,
  T5.E as first_E,
  T5.F as first_F,
  T5.G as first_G,
  T2.A as real_A,
  T2.B as real_B,
  T2.C as real_C,
  T2.D as real_D,
  T2.E as real_E,
  T2.F as real_F,
  T2.G as real_G
  from
  transactions T1
  inner join
  customers cust on (T1.customer_ID = cust.customer_ID and cust.dataset = 'train')
  inner join
  (
  select
  *
  from
  transactions
  where
  record_type = 1
  ) T2 on (T1.customer_ID = T2.customer_ID)
  inner join
  (
  select
  *
  from
  transactions
  where
  shopping_pt = 3
  ) T3 on (T1.customer_ID = T3.customer_ID and T1.shopping_pt = T3.shopping_pt)
  inner join
  (
  select
  customer_ID,
  avg(cost) as avg_cost,
  min(cost) as min_cost,
  max(cost) as max_cost
  from
  transactions
  where shopping_pt <= 3
  group by 1
  ) T4 on (T1.customer_ID = T4.customer_ID)
  inner join
  (
  select
  *
  from
  transactions
  where
  shopping_pt = 1
  ) T5 on (T1.customer_ID = T5.customer_ID)
  "
  )

data.all <- dbGetQuery(
  con,
  "
  select
  T1.customer_ID as customer_ID,
  cust.state as state,
  T3.day as day,
  T3.time as time,
  T3.group_size as group_size,
  T3.homeowner as homeowner,
  T3.car_age as car_age,
  T3.car_value as car_value,
  T3.risk_factor as risk_factor,
  T3.age_youngest as age_youngest,
  T3.age_oldest as age_oldest,
  T3.married_couple as married_couple,
  T3.C_previous as C_previous,
  T3.duration_previous as duration_previous,
  T3.cost as value_cost_last,
  T4.avg_cost as avg_cost,
  T4.min_cost as min_cost,
  T4.max_cost as max_cost,
  T3.A as value_A_last,
  T3.B as value_B_last,
  T3.C as value_C_last,
  T3.D as value_D_last,
  T3.E as value_E_last,
  T3.F as value_F_last,
  T3.G as value_G_last,
  T5.A as first_A,
  T5.B as first_B,
  T5.C as first_C,
  T5.D as first_D,
  T5.E as first_E,
  T5.F as first_F,
  T5.G as first_G,
  T2.A as real_A,
  T2.B as real_B,
  T2.C as real_C,
  T2.D as real_D,
  T2.E as real_E,
  T2.F as real_F,
  T2.G as real_G
  from
  transactions T1
  inner join
  customers cust on (T1.customer_ID = cust.customer_ID and cust.dataset = 'train')
  inner join
  (
  select
  *
  from
  transactions
  where
  record_type = 1
  ) T2 on (T1.customer_ID = T2.customer_ID)
  inner join
  (
    select
    A.*
    from
    transactions A inner join (
      select
      customer_ID,
      max(shopping_pt) as max_shopping_pt
      from transactions
      where
      record_type = 0
      group by 1
    ) B on (A.customer_ID = B.customer_ID and A.shopping_pt = B.max_shopping_pt)
  ) T3 on (T1.customer_ID = T3.customer_ID and T1.shopping_pt = T3.shopping_pt)
  inner join
  (
  select
  customer_ID,
  avg(cost) as avg_cost,
  min(cost) as min_cost,
  max(cost) as max_cost
  from
  transactions
  where record_type = 0
  group by 1
  ) T4 on (T1.customer_ID = T4.customer_ID)
  inner join
  (
  select
  *
  from
  transactions
  where
  shopping_pt = 1
  ) T5 on (T1.customer_ID = T5.customer_ID)
  "
  )


dbDisconnect(con)


normalize.2 <- function(data) {
  
  rownames(data) <- data$customer_ID
  data <- data[, colnames(data) != "customer_ID"]
  
  data$state <- factor(data$state)
  
  data <- data[, colnames(data) != "day"]
  data <- data[, colnames(data) != "time"]
  
  data$homeowner <- factor(ifelse(data$homeowner == 1, "Yes", "No"))
  
  data$car_value <- factor(data$car_value)
  
  data$risk_factor <- factor(ifelse(is.na(data$risk_factor), "NotAvailable", data$risk_factor))
  
  data$married_couple <- factor(ifelse(data$married_couple == 1, "Yes", "No"))
  
  data$C_previous <- factor(ifelse(is.na(data$C_previous), "NotAvailable", data$C_previous))

  data$duration_previous <- ifelse(is.na(data$duration_previous), 5, data$duration_previous)  
  
  for(letter in c("A","B","C","D","E","F","G")) {
    data[, paste("value", letter, "pt_2", sep="_")] <- factor(data[, paste("value", letter, "pt_2", sep="_")])
    data[, paste("first", letter, sep="_")] <- factor(data[, paste("first", letter, sep="_")])
    data[, paste("real", letter, sep="_")] <- factor(data[, paste("real", letter, sep="_")])
  }
  
  return(data)
  
}

normalize.3 <- function(data) {
  
  rownames(data) <- data$customer_ID
  data <- data[, colnames(data) != "customer_ID"]
  
  data$state <- factor(data$state)
  
  data <- data[, colnames(data) != "day"]
  data <- data[, colnames(data) != "time"]
  
  data$homeowner <- factor(ifelse(data$homeowner == 1, "Yes", "No"))
  
  data$car_value <- factor(data$car_value)
  
  data$risk_factor <- factor(ifelse(is.na(data$risk_factor), "NotAvailable", data$risk_factor))
  
  data$married_couple <- factor(ifelse(data$married_couple == 1, "Yes", "No"))
  
  data$C_previous <- factor(ifelse(is.na(data$C_previous), "NotAvailable", data$C_previous))
  
  data$duration_previous <- ifelse(is.na(data$duration_previous), 5, data$duration_previous)  
  
  for(letter in c("A","B","C","D","E","F","G")) {
    data[, paste("value", letter, "pt_3", sep="_")] <- factor(data[, paste("value", letter, "pt_3", sep="_")])
    data[, paste("first", letter, sep="_")] <- factor(data[, paste("first", letter, sep="_")])
    data[, paste("real", letter, sep="_")] <- factor(data[, paste("real", letter, sep="_")])
  }
  
  return(data)
  
}


normalize.all <- function(data) {
  
  rownames(data) <- data$customer_ID
  data <- data[, colnames(data) != "customer_ID"]
  
  data$state <- factor(data$state)
  
  data <- data[, colnames(data) != "day"]
  data <- data[, colnames(data) != "time"]
  
  data$homeowner <- factor(ifelse(data$homeowner == 1, "Yes", "No"))
  
  data$car_value <- factor(data$car_value)
  
  data$risk_factor <- factor(ifelse(is.na(data$risk_factor), "NotAvailable", data$risk_factor))
  
  data$married_couple <- factor(ifelse(data$married_couple == 1, "Yes", "No"))
  
  data$C_previous <- factor(ifelse(is.na(data$C_previous), "NotAvailable", data$C_previous))
  
  data$duration_previous <- ifelse(is.na(data$duration_previous), 5, data$duration_previous)  
  
  for(letter in c("A","B","C","D","E","F","G")) {
    data[, paste("value", letter, "last", sep="_")] <- factor(data[, paste("value", letter, "last", sep="_")])
    data[, paste("first", letter, sep="_")] <- factor(data[, paste("first", letter, sep="_")])
    data[, paste("real", letter, sep="_")] <- factor(data[, paste("real", letter, sep="_")])
  }
  
  return(data)
  
}

data.2 <- normalize.2(data.2)
data.3 <- normalize.3(data.3)
data.all <- normalize.all(data.all)

# Test glmnet

##### FUNCTIONS ###############

get.result.glmnet <- function(data.train, data.test, letter, alphas, nlambda=50) {
  result <- data.frame()
  
  formula.letter <- formula(paste("real_", letter, " ~ .", sep = ""))
  
  data.train <- data.train[, ! (grepl("real_", colnames(data.train)) & colnames(data.train) != paste("real_", letter, sep=""))]
  data.test <- data.test[, ! (grepl("real_", colnames(data.test)) & colnames(data.test) != paste("real_", letter, sep=""))]
  
  x <- model.matrix(formula.letter, data=data.train)
  y <- data.train[, paste("real_", letter, sep="")]
  
  for(alpha in alphas) {
    cat("alpha = ", alpha, "\n")
    model <- glmnet(x,y,
                    family="multinomial", alpha=alpha, nlambda=nlambda)
    
    x.test <- model.matrix(formula.letter, data=data.test)
    for(lambda in model$lambda) {
      y.test <- as.character(predict(model, newx=x.test, s=lambda, type="class"))
      
      nb.ok <- sum(y.test == as.character(data.test[, paste("real_", letter, sep="")]))
      nb.ko <- sum(y.test != as.character(data.test[, paste("real_", letter, sep="")]))
      result <- rbind(result,
                      data.frame(
                        letter=letter,
                        alpha=alpha,
                        lambda=lambda,
                        prc.ok=(nb.ok*100)/(nb.ok+nb.ko),
                        prc.ko=(nb.ko*100)/(nb.ok+nb.ko)
                      ))
    }
    
  }
  
  return(result)
}


###############################

library(glmnet)

alphas <- seq(from=0, to=1, length.out=5)

indices <- sample(1:nrow(data.2), nrow(data.2)*0.7)
data.train.2 <- data.2[indices,]
data.test.2 <- data.2[-indices,]

indices <- sample(1:nrow(data.3), nrow(data.3)*0.7)
data.train.3 <- data.3[indices,]
data.test.3 <- data.3[-indices,]

indices <- sample(1:nrow(data.all), nrow(data.all)*0.7)
data.train.all <- data.all[indices,]
data.test.all <- data.all[-indices,]

# lettre
result.2 <- data.frame()
result.3 <- data.frame()
result.all <- data.frame()

for(letter in c("A","B","C","D","E","F","G")) {
  tmp <- get.result.glmnet(data.train.2, data.test.2, letter, alphas, nlambda=50)
  result.2 <- rbind(result.2, tmp)
}

for(letter in c("A","B","C","D","E","F","G")) {
  tmp <- get.result.glmnet(data.train.3, data.test.3, letter, alphas, nlambda=50)
  result.3 <- rbind(result.3, tmp)
}

for(letter in c("A","B","C","D","E","F","G")) {
  tmp <- get.result.glmnet(data.train.all, data.test.all, letter, alphas, nlambda=50)
  result.all <- rbind(result.all, tmp)
}

write.csv(x=result.2, file="result_2.csv")
write.csv(x=result.3, file="result_3.csv")
write.csv(x=result.all, file="result_all.csv")

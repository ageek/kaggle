
##
# 
# sqlite> select T1.location, T1.G, T2.G, count(*) from transactions T1, transacti
# ons T2 where T1.customer_ID = T2.customer_ID and T1.record_type = 0 and T2.recor
# d_type = 1 and T1.location = 12382 and T1.location = T2.location group by 1,2,3;
# 
# 12382|1|1|98
# 12382|2|1|13
# 12382|4|1|20
# sqlite>
# 
# But:
# transition_1_vers_1 : 99
# transition_1_vers_2 : 1
# transition_1_vers_3 : 1
# transition_1_vers_4 : 1
# total_1             : 102
# transition_2_vers_1 : 14
# transition_2_vers_2 : 1
# transition_2_vers_3 : 1
# transition_2_vers_4 : 1
# total_2             : 17
# transition_3_vers_1 : 1
# transition_3_vers_2 : 1
# transition_3_vers_3 : 1
# transition_3_vers_4 : 1
# total_3             : 4
# transition_4_vers_1 : 20
# transition_4_vers_2 : 1
# transition_4_vers_3 : 1
# transition_4_vers_4 : 1
# total_4             : 24


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
  T1.G as debut_G,
  T2.G as fin_G,
  count(*) as total_transition
  from
  transactions T1, transactions T2
  where 
  T1.customer_ID = T2.customer_ID and
  T1.record_type = 0 and
  T2.record_type = 1 and
  T1.location = T2.location
  group by 1,2,3
  "
)

dbDisconnect(con)


# Test
tmp <- ddply(
  data,
  .(location),
  function(df) {
    result <- data.frame(location=df$location[1])
    
    for(i in c(1,2,3,4)) {
      n <- 0
      for(j in c(1,2,3,4)) {
        var.name <- paste("transition_G", i, "vers", j, sep = "_")
        total <- df$total_transition[df$debut_G == i & df$fin_G == j]
        if(length(total) == 0) {
          total <- 1 
        } else {
          total <- total + 1
        }
        
        n <- n + total
        
        result[,var.name] <- total
      }
      var.total.name <- paste("total_G", i, sep = "_")
      result[,var.total.name] <- n
    }
    
    for(i in c(1,2,3,4)) {
      var.total.name <- paste("total_G", i, sep = "_")
      
      for(j in c(1,2,3,4)) {
        var.name <- paste("transition_G", i, "vers", j, sep = "_")
        var.name.prc <- paste("percent_transition_G", i, "vers", j, sep = "_")
        result[,var.name.prc] <- (result[,var.name]*100)/result[,var.total.name]
      }
    }
    
    return(result)
  }
  )

# Ecriture
drv <- dbDriver("SQLite")
con <- dbConnect(drv, dbname=sqlitedb.filename)

print("Alimentation table transitions_G")
dbWriteTable(con, "transitions_G", tmp)

dbDisconnect(con)

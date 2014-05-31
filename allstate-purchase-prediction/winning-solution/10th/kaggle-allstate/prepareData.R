source('changedPlansMatrix.R')

currentTrainPath = 'data/train_2014.04.05.RData'
currentTestPath = 'data/test_2014.04.05.RData'

training = T
if (training)
{
  data = read.csv('data/raw/train.csv',header=T)
} else {
  load(currentTrainPath)
  rm(data)
  data = read.csv('data/raw/test_v2.csv',header=T)
}

############################### base variables ####################################
data$customer_ID = as.factor(data$customer_ID)
data$record_type = as.factor(data$record_type)

# day conversion
day = data$day
data$day = factor(NA,levels=c('workweek','weekend'))
data$day[day >= 0 & day < 5] <- 'workweek'
data$day[day >= 5] <- 'weekend'
rm(day)

# time conversion
time = unlist(lapply(strsplit(as.character(data$time),":"),function(x){ return(round(as.numeric(x[1])+as.numeric(x[2])/60)) }))
data$time = factor(NA,levels=c('midnight','morning','noon','afternoon','evening'))
data$time[time>22 | time<=6] <- 'midnight'
data$time[time>6 & time<=10] <- 'morning'
data$time[time>10 & time <= 13] <- 'noon'
data$time[time>13 & time <= 18] <- 'afternoon'
data$time[time>18 & time <= 22] <- 'evening'
rm(time)

data$location = as.factor(data$location)
data$homeowner = as.factor(data$homeowner)

data$car_value = as.ordered(data$car_value)
data$car_value[data$car_value == ""] <- NA
data$car_value = droplevels(data$car_value)

data$risk_factor = as.ordered(data$risk_factor)
data$married_couple = as.factor(data$married_couple)
data$C_previous = as.ordered(data$C_previous)
data$A = as.ordered(data$A)
data$B = as.ordered(data$B)
data$C = as.ordered(data$C)
data$D = as.ordered(data$D)
data$E = as.ordered(data$E)
data$F = as.ordered(data$F)
data$G = as.ordered(data$G)

# group_size correction
data$group_size[which(data$group_size == 1 & data$married_couple == 1)] = 2
# sum(data$age_oldest != data$age_youngest & data$group_size==1) ?????? 

# for convenient exploration
if (training)
  data$customer_ID = as.numeric(data$customer_ID)

################################# new variables ###################################
data$age_diff = data$age_oldest - data$age_youngest
data$age_mean = rowMeans(cbind(data$age_youngest,data$age_oldest))
data$senior = as.factor((data$age_oldest >= 55 & data$age_youngest >= 55)*1)
data$teenWithParents = as.factor((data$age_youngest <= 18 & data$age_diff >= 18)*1)
data$teenAlone = as.factor((data$age_youngest <= 18 & data$group_size == 1)*1)
data$studentAlone = as.factor((data$group_size == 1 & data$age_youngest > 18 & data$age_youngest <= 25)*1)
data$youngMarriage = as.factor((data$group_size == 2 & data$married_couple == 1 & data$age_oldest <= 25)*1)

data$newCar = as.factor((data$car_age <= 1)*1)
data$oldCar = as.factor((data$car_age > 40)*1)

data$sameC = as.factor((data$C == data$C_previous)*1)

data$unknownRisk <- as.factor((is.na(data$risk_factor))*1)
data$newCustomer <- as.factor((is.na(data$duration_previous) | is.na(data$C_previous))*1)

data$hasA = as.factor((data$A != "0")*1)
data$hasB = as.factor((data$B != "0")*1)
data$hasE = as.factor((data$E != "0")*1)
data$hasF = as.factor((data$F != "0")*1)

##### defining the time-varying variables
data$cost_mean = NA
data$cost_grad = NA
data$cost_cumgrad = 0
data$cost_absgrad = 0
data$numChanges = 0

data$hadA = factor(0,levels=c(0,1))
data$hadB = factor(0,levels=c(0,1))
data$hadE = factor(0,levels=c(0,1))
data$hadF = factor(0,levels=c(0,1))

data$prevA = factor(NA,levels=levels(data$A))
data$prevB = factor(NA,levels=levels(data$B))
data$prevC = factor(NA,levels=levels(data$C))
data$prevD = factor(NA,levels=levels(data$D))
data$prevE = factor(NA,levels=levels(data$E))
data$prevF = factor(NA,levels=levels(data$F))
data$prevG = factor(NA,levels=levels(data$G))


data$last <- factor(0,levels=c(0,1))
if (training)
{
  data$willChange <- factor(NA,levels=c(0,1))
  data$targetA = factor(NA,levels=levels(data$A))
  data$targetB = factor(NA,levels=levels(data$B))
  data$targetC = factor(NA,levels=levels(data$C))
  data$targetD = factor(NA,levels=levels(data$D))
  data$targetE = factor(NA,levels=levels(data$E))
  data$targetF = factor(NA,levels=levels(data$F))
  data$targetG = factor(NA,levels=levels(data$G))
}


if (training)
{
  target = data[which(data$record_type==1),]
  data = data[-which(data$record_type==1),]
  target$record_type <- NULL
}
data$record_type <- NULL

###################### filling in time-varying variables ##########################
mat = data.matrix(data)
targetMat = data.matrix(target)
isNullFactor = rep(F,ncol(data))
for(col in 1:ncol(data)) { if('factor' %in% class(data[,col]) & "0" %in% levels(data[,col])) isNullFactor[col] = T }
mat[,isNullFactor] = mat[,isNullFactor]-1
targetMat[,isNullFactor] = targetMat[,isNullFactor]-1

allCustomers = unique(mat[,"customer_ID"])
for(cust in seq.int(1,length(allCustomers)))
{
  customer = which(mat[,"customer_ID"] == allCustomers[cust])
  mat[customer,"last"][length(customer)] = T # the last quote of each transaction
  
  if (training)
  {
    mat[customer,"willChange"] = changedPlansMatrix(mat[customer,],targetMat[cust,])
    mat[customer,"targetA"] = targetMat[cust,"A"]
    mat[customer,"targetB"] = targetMat[cust,"B"]
    mat[customer,"targetC"] = targetMat[cust,"C"]
    mat[customer,"targetD"] = targetMat[cust,"D"]
    mat[customer,"targetE"] = targetMat[cust,"E"]
    mat[customer,"targetF"] = targetMat[cust,"F"]
    mat[customer,"targetG"] = targetMat[cust,"G"]
  }
  
  for (obs in seq.int(2,length(customer)))
  {
    mat[customer,"cost_mean"][obs] = mean(mat[customer,"cost"][1:obs])
    mat[customer,"cost_grad"][obs] = mat[customer,"cost"][obs]-mat[customer,"cost"][obs-1]
    mat[customer,"cost_cumgrad"][obs] = mat[customer,"cost_cumgrad"][obs-1] + mat[customer,"cost_grad"][obs]
    mat[customer,"cost_absgrad"][obs] = mat[customer,"cost_absgrad"][obs-1] + abs(mat[customer,"cost_grad"][obs])
    mat[customer,"numChanges"][obs] = mat[customer,"numChanges"][obs-1] + as.numeric(changedPlansMatrix(mat[customer,][obs,],mat[customer,][obs-1,]))
    mat[customer,"hadA"][obs] = mat[customer,"hadA"][obs-1] | mat[customer,"hasA"][obs]
    mat[customer,"hadB"][obs] = mat[customer,"hadB"][obs-1] | mat[customer,"hasB"][obs]
    mat[customer,"hadE"][obs] = mat[customer,"hadE"][obs-1] | mat[customer,"hasE"][obs]
    mat[customer,"hadF"][obs] = mat[customer,"hadF"][obs-1] | mat[customer,"hasF"][obs]
    mat[customer,"prevA"][obs] = mat[customer,"A"][obs-1]
    mat[customer,"prevB"][obs] = mat[customer,"B"][obs-1]
    mat[customer,"prevC"][obs] = mat[customer,"C"][obs-1]
    mat[customer,"prevD"][obs] = mat[customer,"D"][obs-1]
    mat[customer,"prevE"][obs] = mat[customer,"E"][obs-1]
    mat[customer,"prevF"][obs] = mat[customer,"F"][obs-1]
    mat[customer,"prevG"][obs] = mat[customer,"G"][obs-1]
  }
  if (cust %% 10 == 0)
    cat('Customers processed: ',cust/length(allCustomers)*100,'\n')
}
data$cost_mean = mat[,"cost_mean"]
data$cost_grad = mat[,"cost_grad"]
data$cost_cumgrad = mat[,"cost_cumgrad"]
data$cost_absgrad = mat[,"cost_absgrad"]
data$numChanges = mat[,"numChanges"]
data$hadA = as.factor(mat[,"hadA"])
data$hadB = as.factor(mat[,"hadB"])
data$hadE = as.factor(mat[,"hadE"])
data$hadF = as.factor(mat[,"hadF"])
data$prevA = as.ordered(mat[,"prevA"])
data$prevB = as.ordered(mat[,"prevB"])
data$prevC = as.ordered(mat[,"prevC"])
data$prevD = as.ordered(mat[,"prevD"])
data$prevE = as.ordered(mat[,"prevE"])
data$prevF = as.ordered(mat[,"prevF"])
data$prevG = as.ordered(mat[,"prevG"])
data$last = as.factor(mat[,"last"])
if (training)
{
  data$willChange = as.factor(mat[,"willChange"])
  data$targetA = as.ordered(mat[,"targetA"])
  data$targetB = as.ordered(mat[,"targetB"])
  data$targetC = as.ordered(mat[,"targetC"])
  data$targetD = as.ordered(mat[,"targetD"])
  data$targetE = as.ordered(mat[,"targetE"])
  data$targetF = as.ordered(mat[,"targetF"])
  data$targetG = as.ordered(mat[,"targetG"])
}

# deleting the first quote of each customer
data = data[-which(data$shopping_pt==1),]


########################### popularities ##############################

##### options
dataOption = factor((as.numeric(data$A)-1)*1 + 
                      ((as.numeric(data$B)-1))*10 + 
                      ((as.numeric(data$C)))*100 + 
                      ((as.numeric(data$D)))*1000 +
                      ((as.numeric(data$E)-1))*10000 + 
                      ((as.numeric(data$F)-1))*100000 +
                      ((as.numeric(data$G))*1000000 ) )

targetOption = factor((as.numeric(target$A)-1)*1 + 
                        ((as.numeric(target$B)-1))*10 + 
                        ((as.numeric(target$C)))*100 + 
                        ((as.numeric(target$D)))*1000 +
                        ((as.numeric(target$E)-1))*10000 + 
                        ((as.numeric(target$F)-1))*100000 +
                        ((as.numeric(target$G))*1000000 ) )

a = table(targetOption)
data$popularity = ordered(ifelse( a[dataOption] <= mean(a) ,'rare',
                                  ifelse(a[dataOption] <= mean(a)+sd(a),'popular','very popular'))
                          ,levels=c('rare','popular','very popular'))
data$popularity[is.na(data$popularity)] = 'rare'

#####  locations
loc = table(target$location)

data$loc_visited = ordered(ifelse( loc[data$location] <= mean(loc) ,'rarely',
                                   ifelse(loc[data$location] <= mean(loc)+sd(loc),'medium','often'))
                           ,levels=c('rarely','medium','often'))
data$loc_visited[is.na(data$loc_visited)] = 'rarely'

################################### SAVE ##########################################
if (training) {
  save(data,target,file='data/train_2014.04.05.RData')
} else {
  test = data
  save(test,file='data/test_2014.04.05.RData')
}


############### auxiliary variables ##################
# both preprocessed train and test sets are required to add these
car_age = (data$car_age-mean(c(target$car_age,test$car_age[test$last==1])))/sd(c(target$car_age,test$car_age[test$last==1]))
car_value = as.numeric(data$car_value)
car_value = (car_value-mean(as.numeric(c(target$car_value,test$car_value[test$last==1])),na.rm=T))/sd(as.numeric(c(target$car_value,test$car_value[test$last==1])),na.rm=T)
age_mean = (data$age_mean-mean(c(target$age_mean,test$age_mean[test$last==1])))/sd(c(target$age_mean,test$age_mean[test$last==1]))

data$aux1 = car_value*car_age
data$aux2 = car_age - age_mean
data$aux3 = car_value - car_age
data$aux4 = car_age + age_mean
data$aux5 = car_value + car_age
data$aux6 = car_value + age_mean

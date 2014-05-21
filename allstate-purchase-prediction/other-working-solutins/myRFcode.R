#####import
require(randomForest)

#####read file
sampleSubmission <- read.csv("~/R/allstate/sampleSubmission.csv")
sub.persistent <- read.csv("~/R/allstate/sub.persistent.csv",colClass="character")
test_v2 <- read.csv("~/R/allstate/test_v2.csv")
train <- read.csv("~/R/allstate/train.csv")

tune<-T

#####data Setting
idx<-train$record_type==1 #no truncation
dsub<-train[c(idx[2:length(idx)],FALSE),]
dsub$weekday<-ifelse(dsub$day<=4,1,0) #date
dsub$time<-as.character(dsub$time) #time
dsub$time<-as.integer(substr(dsub$time,1,2))*60+as.integer(substr(dsub$time,4,5))
dsub$child<-ifelse(dsub$group_size>=3 & dsub$age_youngest<=18, 1, 0) #have child
dsub$couple<-ifelse(dsub$group_size==2 & dsub$married_couple==1, 1, 0) #couple
dsub$single<-ifelse(dsub$group_size==1 & dsub$married_couple==0, 1, 0) #single
idx<-c(idx[3:length(idx)],FALSE,FALSE) #2ndlast
dsub2<-train[idx,]
dsub$SA<-dsub2[,18]
dsub$SB<-dsub2[,19]
dsub$SC<-dsub2[,20]
dsub$SD<-dsub2[,21]
dsub$SE<-dsub2[,22]
dsub$SF<-dsub2[,23]
dsub$SG<-dsub2[,24]
dsub$SA<-paste0(dsub[,18],dsub[,30]) #last+2nd last
dsub$SB<-paste0(dsub[,19],dsub[,31])
dsub$SC<-paste0(dsub[,20],dsub[,32])
dsub$SD<-paste0(dsub[,21],dsub[,33])
dsub$SE<-paste0(dsub[,22],dsub[,34])
dsub$SF<-paste0(dsub[,23],dsub[,35])
dsub$SG<-paste0(dsub[,24],dsub[,36])
dsub2<-train[train$record_type==1,] #answer
dsub$PA<-dsub2[,18]
dsub$PB<-dsub2[,19]
dsub$PC<-dsub2[,20]
dsub$PD<-dsub2[,21]
dsub$PE<-dsub2[,22]
dsub$PF<-dsub2[,23]
dsub$PG<-dsub2[,24]
dsub$risk_factor[is.na(dsub$risk_factor)]<-3 #NA
dsub$C_previous[is.na(dsub$C_previous)]<-3
dsub$duration_previous[is.na(dsub$duration_previous)]<-6
c1<-c(7,9,15,16,18:24,26:43)
for(i in c1)
{
  dsub[,i]<-as.factor(dsub[,i])
}
ranking<-order(table(dsub$state),decreasing=T) #select top30 state
levels(dsub$state)<-c(levels(dsub$state),"XX")
for(i in levels(dsub$state)[ranking][32:36])
{
  dsub$state[dsub$state==i]<-"XX"
}
dsub$state<-factor(dsub$state)
dtrain<-dsub

###make test data
dsub <- test_v2[ !duplicated( test_v2$customer_ID, fromLast=TRUE ) , ]
dsub$weekday<-ifelse(dsub$day<=4,1,0) #date
dsub$time<-as.character(dsub$time) #time
dsub$time<-as.integer(substr(dsub$time,1,2))*60+as.integer(substr(dsub$time,4,5))
dsub$child<-ifelse(dsub$group_size>=3 & dsub$age_youngest<=18, 1, 0)
dsub$couple<-ifelse(dsub$group_size==2 & dsub$married_couple==1, 1, 0)
dsub$single<-ifelse(dsub$group_size==1 & dsub$married_couple==0, 1, 0)
idx<-which(!duplicated( test_v2$customer_ID, fromLast=TRUE ))-1 #2nd last
dsub2<-test_v2[idx,]
dsub$SA<-dsub2[,18]
dsub$SB<-dsub2[,19]
dsub$SC<-dsub2[,20]
dsub$SD<-dsub2[,21]
dsub$SE<-dsub2[,22]
dsub$SF<-dsub2[,23]
dsub$SG<-dsub2[,24]
dsub$SA<-paste0(dsub[,18],dsub[,30]) #last+2nd last
dsub$SB<-paste0(dsub[,19],dsub[,31])
dsub$SC<-paste0(dsub[,20],dsub[,32])
dsub$SD<-paste0(dsub[,21],dsub[,33])
dsub$SE<-paste0(dsub[,22],dsub[,34])
dsub$SF<-paste0(dsub[,23],dsub[,35])
dsub$SG<-paste0(dsub[,24],dsub[,36])
dsub$risk_factor[is.na(dsub$risk_factor)]<-3 #NA
dsub$C_previous[is.na(dsub$C_previous)]<-3
dsub$duration_previous[is.na(dsub$duration_previous)]<-6
c1<-c(7,9,15,16,18:24,26:36)
for(i in c1)
{
  dsub[,i]<-as.factor(dsub[,i])
}
levels(dsub$state)<-c(levels(dsub$state),"XX")
for(i in levels(dsub$state)[ranking][32:36])
{
  dsub$state[dsub$state==i]<-"XX"
}
dsub$state<-factor(dsub$state)
dtest<-dsub

#####model
mlist<-list()
dresult<-data.frame(customer_ID=dtest$customer_ID)
cy<-c("PA","PB","PC","PD","PE","PF","PG")
cx<-c(2,4,5,6,8:17,18:29,30:36)
if(tune) #tune
{
  cmtry<-rep(0,length(cy))
  for(i in 1:length(cy))
  {
    print(cy[i])
    model.tune<-tuneRF(dtrain[,cx],dtrain[,cy[i]])
    cmtry[i]<-model.tune[order(model.tune[,2])[1],1]
  }
  print(cmtry)
}
for(i in 1:length(cy)) #predict A-G
{
  print(cy[i])
  if(tune) {
    model<-randomForest(dtrain[,cx],dtrain[,cy[i]],mtry=cmtry[i])
  } 
  else {
    model<-randomForest(dtrain[,cx],dtrain[,cy[i]])
  }
  mlist<-c(mlist,list(model))
  print(model$importance[order(-model$importance)[1:10],])
}

#####prediction
for(i in 1:length(cy))
{
  model<-mlist[[i]]
  pred<-predict(model,dtest[,cx])
  dresult[,cy[i]]<-pred
}

#####write submit data
dresult$plan<-paste0(dresult[,"PA"],dresult[,"PB"],dresult[,"PC"],dresult[,"PD"],dresult[,"PE"],dresult[,"PF"],dresult[,"PG"])
write.csv(dresult[,c("customer_ID","plan")],paste0('result.csv'),quote=FALSE,row.names = FALSE )
sum(sub.persistent$plan==dresult$plan)/55716

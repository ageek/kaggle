#Update base .96817 model

# HQC kaggle challenge
# /home/topo/ghub/kaggle/kaggle-2016/homesite-quote-conversion
# ref : https://www.kaggle.com/sushize/homesite-quote-conversion/xgb-stop/run/104408/code
# LB score: .96817 AUC

setwd("/home/topo/ghub/kaggle/kaggle-2016/homesite-quote-conversion")
getwd()
library(readr)
library(xgboost)

#my favorite seed^^
set.seed(1718)

cat("reading the train and test data\n")
train <- read_csv("./train.csv")
test  <- read_csv("./test.csv")

# There are some NAs in the integer columns so conversion to zero
#treat missing as -1, as done in other columns
train$missCount <- rowSums(is.na(train))
test$missCount <- rowSums(is.na(test))

train[is.na(train)]   <- -1
test[is.na(test)]   <- -1


## Add new column counting zeros in each row
train$zeros <- rowSums(train==0)
test$zeros <- rowSums(test==0)

cat("train data column names and details\n")
names(train)
str(train)
#summary(train)
cat("test data column names and details\n")
names(test)
str(test)
#summary(test)


# seperating out the elements of the date column for the train set
train$month <- as.integer(format(train$Original_Quote_Date, "%m"))
train$year <- as.integer(format(train$Original_Quote_Date, "%y"))
train$day <- weekdays(as.Date(train$Original_Quote_Date))

# removing the date column
train <- train[,-c(2)]

# seperating out the elements of the date column for the train set
test$month <- as.integer(format(test$Original_Quote_Date, "%m"))
test$year <- as.integer(format(test$Original_Quote_Date, "%y"))
test$day <- weekdays(as.Date(test$Original_Quote_Date))

# removing the date column
test <- test[,-c(2)]

#add 2 for two new columns, zeros, & misscount
feature.names <- names(train)[c(3:303)]
cat("Feature Names\n")
feature.names

cat("assuming text variables are categorical & replacing them with numeric ids\n")
for (f in feature.names) {
  if (class(train[[f]])=="character") {
    levels <- unique(c(train[[f]], test[[f]]))
    train[[f]] <- as.integer(factor(train[[f]], levels=levels))
    test[[f]]  <- as.integer(factor(test[[f]],  levels=levels))
  }
}

cat("train data column names after slight feature engineering\n")
names(train)
cat("test data column names after slight feature engineering\n")
names(test)
tra<-train[,feature.names]

nrow(train)
#validation lengh changed from 20k to 80k, but from train data only
#set.seed(1718)
h<-sample(nrow(train),50000)

#check target data spread across sample
#in original data
prop.table(table(train$QuoteConversion_Flag))
#in sampled data
prop.table(table(train$QuoteConversion_Flag[h]))

dval<-xgb.DMatrix(data=data.matrix(tra[h,]),
                  label=train$QuoteConversion_Flag[h])
dtrain<-xgb.DMatrix(data=data.matrix(tra[-h,]),
                  label=train$QuoteConversion_Flag[-h])
#dtrain<-xgb.DMatrix(data=data.matrix(tra),
#                    label=train$QuoteConversion_Flag)

watchlist<-list(val=dval,train=dtrain)
param <- list(  objective           = "binary:logistic", 
                booster = "gbtree",
                eval_metric = "auc",
                eta                 = 0.023, # 0.06, #0.01,
                max_depth           = 6, #changed from default of 8
                subsample           = 0.83, # 0.7
                colsample_bytree    = 0.77 # 0.7
                #num_parallel_tree   = 2
                # alpha = 0.0001, 
                # lambda = 1
)

system.time(clf <- xgb.train(   params              = param, 
                                data                = dtrain, 
                                nrounds             = 1000, 
                                verbose             = 1,  #1
                                print.every.n       =10,
                                #early.stop.round    = 150,
                                watchlist           = watchlist,
                                maximize            = FALSE
)
)

#save the base model
save(clf, file="xgb_base_for_96817_AUC_update-val-auc_987801.rda")

pred1 <- predict(clf, data.matrix(test[,feature.names]))
submission <- data.frame(QuoteNumber=test$QuoteNumber, 
                         QuoteConversion_Flag=pred1)
cat("saving the submission file\n")
write_csv(submission, "xgb_base_for_96817_AUC_update-val-auc_987801.csv")

# LB score: .96802
# for 50k validation, max local val-AUC=
#    [1760]	val-auc:0.967516	train-auc:0.987398
# 
# [1700]	val-auc:0.967488	train-auc:0.986846
# [1710]	val-auc:0.967488	train-auc:0.986945
# [1720]	val-auc:0.967498	train-auc:0.987022
# [1730]	val-auc:0.967496	train-auc:0.987119
# [1740]	val-auc:0.967491	train-auc:0.987199
# [1750]	val-auc:0.967500	train-auc:0.987306
# [1760]	val-auc:0.967516	train-auc:0.987398
# [1770]	val-auc:0.967509	train-auc:0.987487
# [1780]	val-auc:0.967510	train-auc:0.987599
# [1790]	val-auc:0.967504	train-auc:0.987691

# 2nd run with same params same seed still diff result(both seeds 1718)
# [1700]	val-auc:0.967319	train-auc:0.986914
# [1710]	val-auc:0.967327	train-auc:0.986985
# [1720]	val-auc:0.967329	train-auc:0.987060
# [1730]	val-auc:0.967328	train-auc:0.987164
# [1740]	val-auc:0.967330	train-auc:0.987249
# [1750]	val-auc:0.967330	train-auc:0.987341
# [1760]	val-auc:0.967327	train-auc:0.987421
# [1770]	val-auc:0.967343	train-auc:0.987510
# [1780]	val-auc:0.967330	train-auc:0.987595
# [1790]	val-auc:0.967334	train-auc:0.987673
# user   system  elapsed 
# 3644.952    0.592  947.918 

## with seed=1729 for both the seeds, gets val-auc=..968894

# > set.seed(1729)
# > h<-sample(nrow(train),50000)
# > dval<-xgb.DMatrix(data=data.matrix(tra[h,]),
#                     + label=train$QuoteConversion_Flag[h])
# > dtrain<-xgb.DMatrix(data=data.matrix(tra[-h,]),
#                       + label=train$QuoteConversion_Flag[-h])
# > watchlist<-list(val=dval,train=dtrain)
# > param <- list(  objective           = "binary:logistic", 
#                   +                 booster = "gbtree",
#                   +                 eval_metric = "auc",
#                   +                 eta                 = 0.023, # 0.06, #0.01,
#                   +                 max_depth           = 6, #changed from default of 8
#                   +                 subsample           = 0.83, # 0.7
#                   +                 colsample_bytree    = 0.77 # 0.7
#                   +                 #num_parallel_tree   = 2
#                     +                 # alpha = 0.0001, 
#                     +                 # lambda = 1
#                     + )
# > system.time(clf <- xgb.train(   params              = param, 
#                                   +                                 data                = dtrain, 
#                                   +                                 nrounds             = 1800, 
#                                   +                                 verbose             = 1,  #1
#                                   +                                 print.every.n       =10,
#                                   +                                 #early.stop.round    = 150,
#                                     +                                 watchlist           = watchlist,
#                                   +                                 maximize            = FALSE
#                                   + )
#               + )
# [0]	val-auc:0.926885	train-auc:0.924769
# [10]	val-auc:0.945216	train-auc:0.942602
# [20]	val-auc:0.947277	train-auc:0.944698
# [30]	val-auc:0.947605	train-auc:0.944930
# [40]	val-auc:0.949143	train-auc:0.946611
# [50]	val-auc:0.950229	train-auc:0.947733
# [60]	val-auc:0.951396	train-auc:0.949065
# [70]	val-auc:0.951858	train-auc:0.949713
# [80]	val-auc:0.952696	train-auc:0.950625
# [90]	val-auc:0.953875	train-auc:0.951932
# [100]	val-auc:0.954433	train-auc:0.952578
# [110]	val-auc:0.955305	train-auc:0.953604
# [120]	val-auc:0.955913	train-auc:0.954329
# [130]	val-auc:0.956783	train-auc:0.955334
# [140]	val-auc:0.957280	train-auc:0.955899
# [150]	val-auc:0.957973	train-auc:0.956678
# [160]	val-auc:0.958662	train-auc:0.957446
# [170]	val-auc:0.959184	train-auc:0.958067
# [180]	val-auc:0.959543	train-auc:0.958513
# [190]	val-auc:0.959920	train-auc:0.958985
# [200]	val-auc:0.960286	train-auc:0.959422
# [210]	val-auc:0.960605	train-auc:0.959831
# [220]	val-auc:0.961102	train-auc:0.960433
# [230]	val-auc:0.961426	train-auc:0.960844
# [240]	val-auc:0.961786	train-auc:0.961351
# [250]	val-auc:0.962237	train-auc:0.961936
# [260]	val-auc:0.962444	train-auc:0.962304
# [270]	val-auc:0.962728	train-auc:0.962714
# [280]	val-auc:0.962978	train-auc:0.963131
# [290]	val-auc:0.963330	train-auc:0.963624
# [300]	val-auc:0.963628	train-auc:0.964022
# [310]	val-auc:0.963866	train-auc:0.964410
# [320]	val-auc:0.964096	train-auc:0.964751
# [330]	val-auc:0.964330	train-auc:0.965128
# [340]	val-auc:0.964545	train-auc:0.965502
# [350]	val-auc:0.964750	train-auc:0.965867
# [360]	val-auc:0.964932	train-auc:0.966228
# [370]	val-auc:0.965118	train-auc:0.966566
# [380]	val-auc:0.965251	train-auc:0.966826
# [390]	val-auc:0.965402	train-auc:0.967157
# [400]	val-auc:0.965498	train-auc:0.967378
# [410]	val-auc:0.965622	train-auc:0.967690
# [420]	val-auc:0.965762	train-auc:0.967981
# [430]	val-auc:0.965923	train-auc:0.968270
# [440]	val-auc:0.966064	train-auc:0.968591
# [450]	val-auc:0.966156	train-auc:0.968874
# [460]	val-auc:0.966249	train-auc:0.969116
# [470]	val-auc:0.966342	train-auc:0.969363
# [480]	val-auc:0.966404	train-auc:0.969595
# [490]	val-auc:0.966498	train-auc:0.969878
# [500]	val-auc:0.966578	train-auc:0.970098
# [510]	val-auc:0.966648	train-auc:0.970321
# [520]	val-auc:0.966721	train-auc:0.970527
# [530]	val-auc:0.966772	train-auc:0.970727
# [540]	val-auc:0.966821	train-auc:0.970929
# [550]	val-auc:0.966896	train-auc:0.971138
# [560]	val-auc:0.966956	train-auc:0.971348
# [570]	val-auc:0.967036	train-auc:0.971578
# [580]	val-auc:0.967104	train-auc:0.971796
# [590]	val-auc:0.967156	train-auc:0.971955
# [600]	val-auc:0.967228	train-auc:0.972172
# [610]	val-auc:0.967264	train-auc:0.972381
# [620]	val-auc:0.967329	train-auc:0.972579
# [630]	val-auc:0.967387	train-auc:0.972818
# [640]	val-auc:0.967437	train-auc:0.973029
# [650]	val-auc:0.967458	train-auc:0.973219
# [660]	val-auc:0.967501	train-auc:0.973389
# [670]	val-auc:0.967561	train-auc:0.973590
# [680]	val-auc:0.967619	train-auc:0.973820
# [690]	val-auc:0.967664	train-auc:0.974032
# [700]	val-auc:0.967699	train-auc:0.974199
# [710]	val-auc:0.967726	train-auc:0.974376
# [720]	val-auc:0.967764	train-auc:0.974583
# [730]	val-auc:0.967791	train-auc:0.974748
# [740]	val-auc:0.967810	train-auc:0.974906
# [750]	val-auc:0.967825	train-auc:0.975094
# [760]	val-auc:0.967867	train-auc:0.975270
# [770]	val-auc:0.967893	train-auc:0.975467
# [780]	val-auc:0.967932	train-auc:0.975634
# [790]	val-auc:0.967951	train-auc:0.975772
# [800]	val-auc:0.967980	train-auc:0.975937
# [810]	val-auc:0.967998	train-auc:0.976090
# [820]	val-auc:0.968008	train-auc:0.976259
# [830]	val-auc:0.968022	train-auc:0.976414
# [840]	val-auc:0.968041	train-auc:0.976555
# [850]	val-auc:0.968051	train-auc:0.976705
# [860]	val-auc:0.968068	train-auc:0.976872
# [870]	val-auc:0.968106	train-auc:0.977017
# [880]	val-auc:0.968132	train-auc:0.977164
# [890]	val-auc:0.968144	train-auc:0.977308
# [900]	val-auc:0.968152	train-auc:0.977476
# [910]	val-auc:0.968159	train-auc:0.977620
# [920]	val-auc:0.968160	train-auc:0.977757
# [930]	val-auc:0.968175	train-auc:0.977908
# [940]	val-auc:0.968195	train-auc:0.978018
# [950]	val-auc:0.968210	train-auc:0.978174
# [960]	val-auc:0.968245	train-auc:0.978312
# [970]	val-auc:0.968258	train-auc:0.978451
# [980]	val-auc:0.968278	train-auc:0.978593
# [990]	val-auc:0.968308	train-auc:0.978742
# [1000]	val-auc:0.968324	train-auc:0.978871
# [1010]	val-auc:0.968343	train-auc:0.979017
# [1020]	val-auc:0.968349	train-auc:0.979137
# [1030]	val-auc:0.968367	train-auc:0.979269
# [1040]	val-auc:0.968436	train-auc:0.979437
# [1050]	val-auc:0.968443	train-auc:0.979558
# [1060]	val-auc:0.968441	train-auc:0.979688
# [1070]	val-auc:0.968443	train-auc:0.979807
# [1080]	val-auc:0.968448	train-auc:0.979918
# [1090]	val-auc:0.968461	train-auc:0.980058
# [1100]	val-auc:0.968473	train-auc:0.980205
# [1110]	val-auc:0.968487	train-auc:0.980331
# [1120]	val-auc:0.968494	train-auc:0.980463
# [1130]	val-auc:0.968502	train-auc:0.980601
# [1140]	val-auc:0.968514	train-auc:0.980752
# [1150]	val-auc:0.968530	train-auc:0.980888
# [1160]	val-auc:0.968553	train-auc:0.981016
# [1170]	val-auc:0.968552	train-auc:0.981147
# [1180]	val-auc:0.968561	train-auc:0.981291
# [1190]	val-auc:0.968574	train-auc:0.981413
# [1200]	val-auc:0.968590	train-auc:0.981540
# [1210]	val-auc:0.968597	train-auc:0.981665
# [1220]	val-auc:0.968609	train-auc:0.981796
# [1230]	val-auc:0.968619	train-auc:0.981925
# [1240]	val-auc:0.968624	train-auc:0.982059
# [1250]	val-auc:0.968638	train-auc:0.982183
# [1260]	val-auc:0.968644	train-auc:0.982299
# [1270]	val-auc:0.968661	train-auc:0.982430
# [1280]	val-auc:0.968657	train-auc:0.982517
# [1290]	val-auc:0.968669	train-auc:0.982660
# [1300]	val-auc:0.968676	train-auc:0.982750
# [1310]	val-auc:0.968687	train-auc:0.982857
# [1320]	val-auc:0.968696	train-auc:0.982958
# [1330]	val-auc:0.968691	train-auc:0.983074
# [1340]	val-auc:0.968703	train-auc:0.983198
# [1350]	val-auc:0.968718	train-auc:0.983325
# [1360]	val-auc:0.968726	train-auc:0.983448
# [1370]	val-auc:0.968738	train-auc:0.983546
# [1380]	val-auc:0.968733	train-auc:0.983654
# [1390]	val-auc:0.968758	train-auc:0.983778
# [1400]	val-auc:0.968769	train-auc:0.983893
# [1410]	val-auc:0.968773	train-auc:0.983990
# [1420]	val-auc:0.968771	train-auc:0.984083
# [1430]	val-auc:0.968764	train-auc:0.984192
# [1440]	val-auc:0.968778	train-auc:0.984292
# [1450]	val-auc:0.968788	train-auc:0.984420
# [1460]	val-auc:0.968784	train-auc:0.984547
# [1470]	val-auc:0.968801	train-auc:0.984665
# [1480]	val-auc:0.968811	train-auc:0.984785
# [1490]	val-auc:0.968832	train-auc:0.984893
# [1500]	val-auc:0.968826	train-auc:0.985007
# [1510]	val-auc:0.968824	train-auc:0.985111
# [1520]	val-auc:0.968834	train-auc:0.985214
# [1530]	val-auc:0.968831	train-auc:0.985311
# [1540]	val-auc:0.968827	train-auc:0.985394
# [1550]	val-auc:0.968833	train-auc:0.985511
# [1560]	val-auc:0.968828	train-auc:0.985602
# [1570]	val-auc:0.968827	train-auc:0.985706
# [1580]	val-auc:0.968821	train-auc:0.985810
# [1590]	val-auc:0.968824	train-auc:0.985891
# [1600]	val-auc:0.968826	train-auc:0.985993
# [1610]	val-auc:0.968826	train-auc:0.986088
# [1620]	val-auc:0.968834	train-auc:0.986190
# [1630]	val-auc:0.968830	train-auc:0.986283
# [1640]	val-auc:0.968839	train-auc:0.986385
# [1650]	val-auc:0.968845	train-auc:0.986461
# [1660]	val-auc:0.968837	train-auc:0.986561
# [1670]	val-auc:0.968848	train-auc:0.986637
# [1680]	val-auc:0.968847	train-auc:0.986729
# [1690]	val-auc:0.968849	train-auc:0.986837
# [1700]	val-auc:0.968837	train-auc:0.986925
# [1710]	val-auc:0.968835	train-auc:0.987021
# [1720]	val-auc:0.968846	train-auc:0.987122
# [1730]	val-auc:0.968847	train-auc:0.987205
# [1740]	val-auc:0.968848	train-auc:0.987294
# [1750]	val-auc:0.968872	train-auc:0.987382
# [1760]	val-auc:0.968864	train-auc:0.987491
# [1770]	val-auc:0.968859	train-auc:0.987568
# [1780]	val-auc:0.968887	train-auc:0.987669
# [1790]	val-auc:0.968894	train-auc:0.987768
# user   system  elapsed 
# 3639.704    0.588  946.509 
# 
# > this gives LB score: .96752

#wtih seed 1718, val-score =.96734
# 
# [1700]	val-auc:0.967319	train-auc:0.986914
# [1710]	val-auc:0.967327	train-auc:0.986985
# [1720]	val-auc:0.967329	train-auc:0.987060
# [1730]	val-auc:0.967328	train-auc:0.987164
# [1740]	val-auc:0.967330	train-auc:0.987249
# [1750]	val-auc:0.967330	train-auc:0.987341
# [1760]	val-auc:0.967327	train-auc:0.987421
# [1770]	val-auc:0.967343	train-auc:0.987510
# [1780]	val-auc:0.967330	train-auc:0.987595
# [1790]	val-auc:0.967334	train-auc:0.987673
# user   system  elapsed 
# 3647.144    0.552  948.252 
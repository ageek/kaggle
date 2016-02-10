# Homesite quote conversion get started script
# https://www.kaggle.com/sushize/homesite-quote-conversion/xgb-stop/run/104408/code

library(readr)
library(xgboost)
require(ggplot2)

#my favorite seed^^
set.seed(1718)

cat("reading the train and test data\n")
train <- read_csv("C:/Ahmed/ML/Kag2016/Homesite Quote Conversion/train.csv")
test  <- read_csv("C:/Ahmed/ML/Kag2016/Homesite Quote Conversion/test.csv")

### basic feature engg
# seperating out the elements of the date column for the train set
train$month <- as.integer(format(train$Original_Quote_Date, "%m"))
train$year <- as.integer(format(train$Original_Quote_Date, "%y"))
train$day <- weekdays(as.Date(train$Original_Quote_Date))
train$Q <- quarters(as.Date(train$Original_Quote_Date))

# removing the date column
train <- train[,-c(2)]

# seperating out the elements of the date column for the train set
test$month <- as.integer(format(test$Original_Quote_Date, "%m"))
test$year <- as.integer(format(test$Original_Quote_Date, "%y"))
test$day <- weekdays(as.Date(test$Original_Quote_Date))
test$Q <- quarters(as.Date(test$Original_Quote_Date))

# removing the date column
test <- test[,-c(2)]


feature.names <- names(train)[c(3:302)]
cat("Feature Names\n")
feature.names

cat("assuming text variables are categorical & replacing them with numeric ids\n")
# lets check how many fields have missing "" value in their columns
# we need to check the impact on Conversion ratio from missing data

for (f in feature.names) {
  if (class(tn[[f]])=="character") {
    levels <- unique(c(tn[[f]], tt[[f]]))
    if (any(levels=="")) {
      print(f)
      #append(missingFields, f)
      print(levels)
    }
    #train[[f]] <- as.integer(factor(train[[f]], levels=levels))
    #test[[f]]  <- as.integer(factor(test[[f]],  levels=levels))
  }
}
missingFields <- c("PersonalField7"
                   ,"PropertyField3"
                   ,"PropertyField4"
                   , "PropertyField5"
                   , "PropertyField30"
                   , "PropertyField32"
                   , "PropertyField34"
                   , "PropertyField36"
                   , "PropertyField37"
                   , "PropertyField38"
                   , "GeographicField63")
print(missingFields)
#[1] "PersonalField7"    "PropertyField3"    "PropertyField4"    "PropertyField5"   
#[5] "PropertyField30"   "PropertyField32"   "PropertyField34"   "PropertyField36"  
#[9] "PropertyField37"   "PropertyField38"   "GeographicField63"

#Note:
# from PropertyField5 misisng, 3 converted
table(tn$PropertyField34)

# PropertyField29 and PersonalField84 
tn %>%
  group_by(PropertyField29,QuoteConversion_Flag) %>%
  summarise(n())

tn[,c("PropertyField34","QuoteConversion_Flag")]

# there are many "" in various columns lets check and remove them
table(tn[,c("PersonalField7")])
table(train[,c("PersonalField7")])
#from missing "PersonalField7" how many converted???
# none/ 0 from missing actually converted
train %>%
  group_by(PersonalField7,QuoteConversion_Flag ) %>%
  summarize(N=n())

#lets check for: GeographicField63
# none/0 from missing converted
table(tn[,c("GeographicField63")])
table(train[,c("GeographicField63")])

train %>%
  group_by(GeographicField10A ,QuoteConversion_Flag ) %>%
  summarize(N=n())

head(train)
table(train$QuoteConversion_Flag)

# class is imbalanced with around 18% yes to 82% no
# Global conversion rate = 18%
prop.table(table(train$QuoteConversion_Flag))

columns <- names(train)
# we have a total of 299 fiels including target in train data

#lets count NA/missing etc in each columns and see the percentage
#require(Amelia)
#missmap(train)

# PersonalField84  has missing values
table(is.na(train$PersonalField84))
# around 48 % missing / NA values
prop.table(table(is.na(train$PersonalField84)))

# For this missing data, how many Converted???
require(dplyr)

train %>%
  filter(is.na(PersonalField84)) %>%
  summarise(N=n())

train %>%
  filter(is.na(PersonalField84)) %>%
  group_by(QuoteConversion_Flag) %>%
  summarise(Count=n())
  
train %>%
  filter(is.na(PersonalField84)) %>%
  group_by(QuoteConversion_Flag) %>%
  #summarise(Count=n()) %>%
  ggplot() +
    geom_bar(aes(QuoteConversion_Flag))
  
# PropertyField29 has missing values
table(is.na(train$PropertyField29))
# around 77% are missing data
prop.table(table(is.na(train$PropertyField29)))

# from missing how many actually Converted
train %>%
  filter(is.na(PropertyField29)) %>%
  group_by(QuoteConversion_Flag) %>%
  summarise(Count=n())


dim(train)


# do RF on small set and get var importance
train <- read_csv("C:/Ahmed/ML/Kag2016/Homesite Quote Conversion/train.csv") 
                  
require(caret)

# small dataset 5k
set.seed(1239)
in_train <- sample(dim(train)[1], 5000)


train_5k <- train[in_train,]

#do we have any column with single category
str(lapply(train_5k, unique))

dim(train_5k)
str(train_5k)
# ratio is similar to global average
prop.table(table(train_5k$QuoteConversion_Flag))


#2 of the fields are constant and need to be removed
prop.table(table(train_5k$PropertyField6))
prop.table(table(train_5k$GeographicField10A))

train_5k[,c("PropertyField6")] <- NULL
train_5k[,c("GeographicField10A")] <- NULL

train_5k[is.na(train_5k)] <- -1

dt_5k <- data.table(train_5k)


clf <- train(as.factor(QuoteConversion_Flag)~., data=train_5k, 
             method="glm")



#use data table and count -1s and 0s in each row
require(data.table)

dt <- fread("C:/Ahmed/ML/Kag2016/Homesite Quote Conversion/train.csv")
dtt <- fread("C:/Ahmed/ML/Kag2016/Homesite Quote Conversion/test.csv")

dim(dt)
names(dt)

dt[, .N, by=QuoteConversion_Flag]

# count zeros across each row ignoring NAs
zeros <- rowSums(dt==0, na.rm=T)
head(zeros)

ones <- rowSums(dt==-1, na.rm=T)
head(ones)

#check
table(dt[1,]==0)
table(dt[2,]==0)
table(dt[3,]==0)

table(dt[1,]==-1)
table(dt[2,]==-1)
table(dt[3,]==-1)

dt[,c("PropertyField29"), with=F ]

# count NAs as well
table(dt$PropertyField29, exclude=NULL)
# ~77% is missing
prop.table(table(dt$PropertyField29, exclude=NULL))

# ~48% data is missing
table(dt$PersonalField84 , exclude=NULL)
prop.table(table(dt$PersonalField84 , exclude=NULL))


#check in test data
table(dtt$PersonalField84, exclude = NULL)
table(dtt$PropertyField29, exclude = NULL)

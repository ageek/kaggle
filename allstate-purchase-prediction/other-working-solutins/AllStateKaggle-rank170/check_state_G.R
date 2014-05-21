
# fonctions
source(file.path("templates","functions.R"))
source(file.path("templates","get_data.R"))


# Models
load(file=file.path("DATA", "OUTPUT", "first_model_glm_all_clusters_G.RData"))
                    
# Selection variable à estimer
liste.prop <- seq(.5,.9,.1)
state.list <- sort(unique(as.character(data$state)))

result <- data.frame()

for(prop in liste.prop) {
  
  set.seed(42)
  tmp <- get.base.train.test(data, "real_G", prop)
  
  dataTrainBase <- tmp$train
  dataTest <- tmp$test
  
  
  dataTrainBase$predict_glm_1 <- predict(model_1_final_G, newdata=dataTrainBase)
  dataTrainBase$predict_glm_2 <- predict(model_2_final_G, newdata=dataTrainBase)
  dataTrainBase$predict_glm_3 <- predict(model_3_final_G, newdata=dataTrainBase)
  dataTrainBase$predict_glm_4 <- predict(model_4_final_G, newdata=dataTrainBase)
  dataTrainBase$predict_glm_G <- factor(max.col(dataTrainBase[,c("predict_glm_1","predict_glm_2","predict_glm_3","predict_glm_4")]))  
  dataTrainBase$customer_ID <- rownames(dataTrainBase)
  
  
  dataTest$predict_glm_1 <- predict(model_1_final_G, newdata=dataTest)
  dataTest$predict_glm_2 <- predict(model_2_final_G, newdata=dataTest)
  dataTest$predict_glm_3 <- predict(model_3_final_G, newdata=dataTest)
  dataTest$predict_glm_4 <- predict(model_4_final_G, newdata=dataTest)
  dataTest$predict_glm_G <- factor(max.col(dataTest[,c("predict_glm_1","predict_glm_2","predict_glm_3","predict_glm_4")]))  
  dataTest$customer_ID <- rownames(dataTest)
  
  for(state.chosen in state.list) {
    cat("Traitement", prop, state.chosen, "\n")
    
    train.subset <- subset(dataTrainBase, state == state.chosen)
    test.subset <- subset(dataTest, state == state.chosen)
    
    nb.state.train <- nrow(train.subset)
    ok.state.train <- sum(train.subset$predict_glm_G == train.subset$real_G)
    ko.state.train <- nb.state.train - ok.state.train

    nb.state.test <- nrow(test.subset)
    ok.state.test <- sum(test.subset$predict_glm_G == test.subset$real_G)
    ko.state.test <- nb.state.test - ok.state.test
    
    result <- rbind(result,
                    data.frame(
                      state=state.chosen,
                      prop.train=prop,
                      prop.test=1-prop,
                      nb.sample.train=nb.state.train,
                      nb.ok.state.train=ok.state.train,
                      nb.ko.state.train=ko.state.train,
                      prc.ok.state.train=(ok.state.train/nb.state.train)*100,
                      prc.ko.state.train=(ko.state.train/nb.state.train)*100,
                      prop.ko.state.train=((ko.state.train/nb.state.train))*nb.state.train,
                      nb.sample.test=nb.state.test,
                      nb.ok.state.test=ok.state.test,
                      nb.ko.state.test=ko.state.test,
                      prc.ok.state.test=(ok.state.test/nb.state.test)*100,
                      prc.ko.state.test=(ko.state.test/nb.state.test)*100,
                      prop.ko.state.test=((ko.state.test/nb.state.test))*nb.state.test
                    )
    )
    
  }
  
}

# Result
library(ggplot2)
library(plyr)
library(reshape2)

selected.states <- c("WA","AL","IN","MD","OH","PA","NY","FL")

ggplot(subset(result, state %in% selected.states & prop.train == .9)) + 
  # geom_line(aes(x=prop.train, y=prop.ko.state.train, color="train")) + 
  geom_bar(aes(x=state, y=prop.ko.state.test, stat="bin"))

ggplot(subset(result, state %in% selected.states & prop.train == .9)) + 
  # geom_line(aes(x=prop.train, y=prop.ko.state.train, color="train")) + 
  geom_bar(aes(x=state, y=prc.ko.state.test, stat="bin"))


# ko.NY
test.NY <- subset(dataTest, state == "NY")

ok.NY.test <- test.NY[test.NY$predict_glm_G == test.NY$real_G,]
ko.NY.test <- test.NY[test.NY$predict_glm_G != test.NY$real_G,]


# Check
m <- melt(dataTrainBase, id.vars=c("customer_ID","state","real_G"), measure.vars=c("predicted_G_1","predicted_G_2","predicted_G_3","predicted_G_4"))

ggplot(subset(m, real_G == "1")) + geom_histogram(aes(x=value)) + facet_grid(state + real_G  ~ variable )

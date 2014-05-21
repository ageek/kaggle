library(ggplot2)

result <- data.frame()

for(i in c("cluster_1", "cluster_2", "cluster_3")) {
  for(j in toupper(letters)[1:7]) {
    filename <- file.path("DATA", "OUTPUT", paste(paste("result_model_glm", i, j, sep="_"), "csv", sep=".")) 
    tmp <- read.csv(filename)
    
    result <- rbind(result,
                    data.frame(
                      size.train = tmp$size.train,
                      error.glm.test = tmp$error.glm.test,
                      error.glm.train = tmp$error.glm.train,
                      cluster=i,
                      letter=j
                      )
                    )
    
  }
}

result$cluster <- factor(result$cluster)
result$letter <- factor(result$letter)

ggplot(result) + geom_line(aes(x=size.train, y=error.glm.test, color="test")) + 
  geom_line(aes(x=size.train, y=error.glm.train, color="train")) + 
  facet_grid(letter ~ cluster)

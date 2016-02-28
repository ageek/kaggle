#https://www.kaggle.com/wacaxx/march-machine-learning-mania-2016/elo-benchmark-playerratings-in-r/code

#Elo Benchmark
#Ver 0.2
require("data.table")
require("PlayerRatings")
require("ggplot2")

#Read Files----------
seasonCompact <- fread("./RegularSeasonCompactResults.csv")
teams <- fread(file.path("./Teams.csv"))
sampleSubmission <- fread("./SampleSubmission.csv")

#Elo rating for regular seasons----------
#teams in seasons since 2012 'till 2015
allSeasons <- seq(2012, 2015)

eloEndOfSeasonList <- lapply(allSeasons, function(season2extractInfo){
  #season2extractInfo <- 2015 #here for debbugging only
  seasonDataDt <- seasonCompact[Season == season2extractInfo, .(Daynum, Wteam, Lteam, Wloc)]
  resultVector <- rep(1, nrow(seasonDataDt))
  advantageVector <- as.numeric(seasonDataDt$Wloc == "H")
  seasonDataDf <- data.frame(yearDay = seasonDataDt$Daynum,
                             tid1 = seasonDataDt$Wteam, 
                             tid2 = seasonDataDt$Lteam, 
                             result = resultVector)
  EloRatings <- elo(x = seasonDataDf, gamma = advantageVector)
  EloRatingsDt <- as.data.table(EloRatings$ratings)

  return(EloRatingsDt)
})

names(eloEndOfSeasonList) <- allSeasons
print("Elo ratings extracted")

#Matches Information Extraction---------
matches2Predict <- lapply(sampleSubmission$Id, function(submissionIds){
  #submissionIds <- sampleSubmission$Id[1]
  matchesInfo <- strsplit(submissionIds, "_")[[1]]
  return(as.numeric(matchesInfo))
})
matches2PredictDt <- as.data.table(do.call(rbind, matches2Predict))
setnames(matches2PredictDt, names(matches2PredictDt), c("Season", "Team1", "Team2"))

eloMatrix <- apply(matches2PredictDt, 1, function(matchInformation){
  #matchInformation <- matches2PredictDt[2] #here for debugging
  season <- matchInformation[["Season"]]
  team1 <- matchInformation[["Team1"]]
  team2 <- matchInformation[["Team2"]]
  
  #Seeds table search 
  seasonMatrix <- eloEndOfSeasonList[[as.character(season)]]
  eloTeam1 <- as.numeric(seasonMatrix[Player == team1, Rating])
  eloTeam2 <- as.numeric(seasonMatrix[Player == team2, Rating])
  
  return(eloTeam1 - eloTeam2)
})

#Rating difference to probability
elo2Prob <- function(elo, CValue){
  #elo to probability transformation
  probabilityOfVictory <- 1 / (1 + 10 ^ (-(elo)/CValue))
  return(probabilityOfVictory)
}

eloProbabilites <- elo2Prob(eloMatrix, CValue = 200)    #C value and formula based on https://fivethirtyeight.com/datalab/introducing-nfl-elo-ratings/
print("Elo ratings difference transformed to probability")

#Plot the top 10 teams according to Elo's system
top10Elo2012 <- head(as.data.frame(eloEndOfSeasonList[["2012"]][, .(Player, Rating)]), 10)
top10Elo2012 <- merge(top10Elo2012, teams, by.x = "Player", by.y = "Team_Id")

top10Elo2013 <- head(as.data.frame(eloEndOfSeasonList[["2013"]][, .(Player, Rating)]), 10)
top10Elo2013 <- merge(top10Elo2013, teams, by.x = "Player", by.y = "Team_Id")

top10Elo2014 <- head(as.data.frame(eloEndOfSeasonList[["2014"]][, .(Player, Rating)]), 10)
top10Elo2014 <- merge(top10Elo2014, teams, by.x = "Player", by.y = "Team_Id")

top10Elo2015 <- head(as.data.frame(eloEndOfSeasonList[["2015"]][, .(Player, Rating)]), 10)
top10Elo2015 <- merge(top10Elo2015, teams, by.x = "Player", by.y = "Team_Id")

#Plot top 10 in 2012
ggplot(top10Elo2012, aes(x = Team_Name, y = Rating)) +
  geom_bar(stat = "identity", width = 0.5, fill="#6699FF") + coord_cartesian(ylim = c(2300, 2525)) +
  ggtitle("Top 10 Elo ratings before tourney in NCAA basketball \n 2012")

#Plot top 10 in 2013
ggplot(top10Elo2013, aes(x = Team_Name, y = Rating)) +
  geom_bar(stat = "identity", width = 0.5, fill="#6699FF") + coord_cartesian(ylim = c(2300, 2525)) +
  ggtitle("Top 10 Elo ratings before tourney in NCAA basketball \n 2013")

#Plot top 10 in 2014
ggplot(top10Elo2014, aes(x = Team_Name, y = Rating)) +
  geom_bar(stat = "identity", width = 0.5, fill="#6699FF") + coord_cartesian(ylim = c(2300, 2525)) +
  ggtitle("Top 10 Elo ratings before tourney in NCAA basketball \n 2014")

#Plot top 10 in 2015
ggplot(top10Elo2015, aes(x = Team_Name, y = Rating)) +
  geom_bar(stat = "identity", width = 0.5, fill="#6699FF") + coord_cartesian(ylim = c(2300, 2525)) +
  ggtitle("Top 10 Elo ratings before tourney in NCAA basketball \n 2015")
  
#Plot distributions of elo differences and elo differences transformed to probabilities
hist(eloMatrix)
hist(eloProbabilites)

#Write a .csv file with results
sampleSubmission$Pred <- eloProbabilites
write.csv(sampleSubmission, "EloBenchmark.csv", row.names = FALSE)

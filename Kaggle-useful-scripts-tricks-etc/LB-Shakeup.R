require(RCurl)
require(XML)
require(plyr)

shakeup <- function(url.root){
  # url.root is the bare LB url ending in /leaderboard
  # usage: shakeup('http://www.kaggle.com/c/mlsp-2014-mri/leaderboard')
  
  pub.url <- paste(url.root,'/public',sep='')
  pvt.url <- paste(url.root,'/private',sep='')
  
  pub.raw <- getURL(pub.url)
  pvt.raw <- getURL(pvt.url)
  
  pub.doc <- htmlTreeParse(pub.raw, useInternalNodes=TRUE)
  pvt.doc <- htmlTreeParse(pvt.raw, useInternalNodes=TRUE)
  
  pub.ids <- xpathSApply(pub.doc, '//tr[@id]/@id')
  pvt.ids <- xpathSApply(pvt.doc, '//tr[@id]/@id')
  
  n <- length(pub.ids)
  pub.df <- data.frame('id'=pub.ids, 'pub.idx'=1:n)
  pvt.df <- data.frame('id'=pvt.ids, 'pvt.idx'=1:n)
  all.df <- join(pub.df, pvt.df)
  
  cut <- floor(0.1 * n)
  shakeup.top <- mean(abs(all.df$pub.idx[1:cut] - all.df$pvt.idx[1:cut]))/n
  shakeup.all <- mean(abs(all.df$pub.idx - all.df$pvt.idx))/n
  list('shakeup.top'=shakeup.top, 'shakeup.all'=shakeup.all)
}



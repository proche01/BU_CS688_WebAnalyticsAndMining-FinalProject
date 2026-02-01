# Paul Roche
# CS 688
# Final Poject

# Part 1 - Stock Sentiment Analysis

#Install new packages
install.packages("quantmod")
# Import libraries
library("twitteR")
library("ROAuth")
library("RCurl")
library("bitops")
library("rjson")
library("quantmod")
library(tm)
library(SnowballC)
library(wordcloud)
library(googleVis)

# Set directory
dir <- "C:/Users/pocke/OneDrive/Boston University/CS 688/Paul_Roche_Final_Project/"
setwd(dir)
 
# Import twitter API and access keys
source("twitter_keys.r")
#Setup authorization for API
setup_twitter_oauth(t.api.key,t.api.secret,t.access.key,t.access.secret)

# Compile tweets from top gainers and losers
#Top Losers
gwwTweets<-searchTwitter('$GWW ',n=100,lang = 'en')
acbffTweets<-searchTwitter('$ACBFF ',n=100,lang = 'en')
cgcTweets<-searchTwitter('$CGC ',n=100,lang = 'en')
#Combined Losers
loserTweets<-c(gwwTweets,acbffTweets,cgcTweets)
#Top Gainers
iTweets<-searchTwitter('$I ',n=100,lang = 'en')
arryTweets<-searchTwitter('$ARRY ',n=100,lang = 'en')
crspTweets<-searchTwitter('$CRSP ',n=100,lang = 'en')
#Combined Gainers
gainerTweets<-c(iTweets,arryTweets,crspTweets)

# Check first tweets
#Gainers
gwwTweets[[1]]
loserTweets[[1]]
acbffTweets[[1]]
loserTweets[[101]]
cgcTweets[[1]]
loserTweets[[201]]
#Losers
iTweets[[1]]
gainerTweets[[1]]
arryTweets[[1]]
gainerTweets[[101]]
crspTweets[[1]]
gainerTweets[[201]]

#Simple function that removes usernames and creates corpus for tweets
createCorpus <- function (x) {Corpus(VectorSource(lapply(x, function(t) {t$getText()})))}

# Eliminate usernames and text mine for each stock by using the createCorpus function
data.corpus1<-createCorpus(loserTweets)
data.corpus2<-createCorpus(gainerTweets)

# Inspect each corpus
inspect(data.corpus1[1])
inspect(data.corpus2[101])
data.corpus1 #Losers
data.corpus2 #Gainers

#Save corpus objects
save(data.corpus1, file = "losersCorpuses.RData")
save(data.corpus2, file = "gainersCorpuses.RData")

# Function that takes corpus and returns preprocessed corpus
preprocessCorpus <- function (corpus) {
  # Remove url from tweets
  removeURL <- function (x) { gsub(" ?(f|ht)tp(s?)://(.*)", "", gsub(" ?(f|ht)tp(s?)://\\S+ ", "", x)) }
  # Preprocessing
  corpus <- tm_map(corpus,content_transformer(removeURL)) # Remove URLs
  corpus <- tm_map(corpus,removePunctuation) # Remove Punctuation
  corpus <- tm_map(corpus, content_transformer(tolower)) # Lowercase
  corpus <- tm_map(corpus, removeWords, stopwords("english")) # Remove stopwords
  corpus <- tm_map(corpus, function(x) iconv(enc2utf8(x), sub = "byte")) # Remove emojis
}

# Perform preprocessing
data.corpus1<-preprocessCorpus(data.corpus1)
data.corpus2<-preprocessCorpus(data.corpus2)

# Create term document matrix for two sets of data: top gainers and top losers
# Create Document Term Matrix with word length >= 3 and >= 2 reps
# Document term matrix
dtm1 <- DocumentTermMatrix(data.corpus1, control=list(wordLengths=c(3,Inf), bounds=list(global=c(2,Inf)) ) )
dtm2 <- DocumentTermMatrix(data.corpus2, control=list(wordLengths=c(3,Inf), bounds=list(global=c(2,Inf)) ) )

# Find frequent terms
# losers:
losersTopWords<-findFreqTerms(dtm1,50)
losers.m<-as.matrix(dtm1)
losers.v<-sort(colSums(losers.m),decreasing = TRUE)
losers.top<-head(losers.v,50)
head(losers.top,10)
# gainers:
gainersTopWords<-findFreqTerms(dtm2,50)
gainers.m<-as.matrix(dtm2)
gainers.v<-sort(colSums(gainers.m),decreasing = TRUE)
gainers.top<-head(gainers.v,50)
head(gainers.top,10)

# Word Cloud
wordcloud(names(losers.top), freq = unname(losers.top),colors=brewer.pal(8, "Dark2"),
          random.order = FALSE)
wordcloud(names(gainers.top), freq = unname(gainers.top),colors=brewer.pal(8, "Dark2"),
          random.order = FALSE)

# Calculate Sentiment Score:
# Lexicons
pos.words = scan('positive-words.txt',what='character',comment.char=';')
neg.words = scan('negative-words.txt', what='character', comment.char=';')
#### Sentiment Analysis
#### Sentiment Analysis
sentiment <- function(text, pos.words, neg.words) {
  text <- gsub('[[:punct:]]', '', text)
  text <- gsub('[[:cntrl:]]', '', text)
  text <- gsub('\\d+', '', text)
  text <- tolower(text)
  # split the text into a vector of words
  words <- strsplit(text, '\\s+')
  words <- unlist(words)
  # find which words are positive
  pos.matches <- match(words, pos.words)
  pos.matches <- !is.na(pos.matches)
  # find which words are negative
  neg.matches <- match(words, neg.words)
  neg.matches <- !is.na(neg.matches)
  # calculate the sentiment score
  score <- sum(pos.matches) - sum(neg.matches)
  # cat (" Positive: ", words[pos.matches], "\n")
  # cat (" Negative: ", words[neg.matches], "\n")
  return (score)
}

losers.sent<-sentiment(lapply(loserTweets, function(t) {t$getText()}),pos.words,neg.words)
gainers.sent<-sentiment(lapply(gainerTweets, function(t) {t$getText()}),pos.words,neg.words)


barplot(c(losers.sent,gainers.sent), names.arg = c("Losers","Gainers"), xlab="Stock Type", 
        ylab="Sentiment Score",col="cyan",main="Stock Sentiment of Losers & Gainers",cex.names = 0.9)

#Get stock data and plot it
allStocks<-c("CGC","GWW","ACBFF","CRSP","I","AU","ARRY")
getSymbols(allStocks,src = "yahoo")
chartSeries(CGC,type = "candlesticks",subset = '2018-10-03::2018-10-17',
            up.col = "green",dn.col = "red",TA=NULL)
chartSeries(GWW,type = "candlesticks",subset = '2018-10-03::2018-10-17',
            up.col = "green",dn.col = "red",TA=NULL)
chartSeries(ACBFF,type = "candlesticks",subset = '2018-10-03::2018-10-17',
            up.col = "green",dn.col = "red",TA=NULL)
chartSeries(CRSP,type = "candlesticks",subset = '2018-10-03::2018-10-17',
            up.col = "green",dn.col = "red",TA=NULL)
chartSeries(I,type = "candlesticks",subset = '2018-10-03::2018-10-17',
            up.col = "green",dn.col = "red",TA=NULL)
chartSeries(ARRY,type = "candlesticks",subset = '2018-10-03::2018-10-17',
            up.col = "green",dn.col = "red",TA=NULL)

#Extra Credit: googleVis
#Line Chart Visualization
makeStockChart <- function (x) {
  lineChart<-gvisLineChart(subset((data.frame(as.Date(row.names(as.data.frame(x))),
                                              as.data.frame(x)[4])),
                                  as.Date(row.names(as.data.frame(x)))>"2018-10-03"),
                           options=list(width=700, height=250))
}
#Merge visualizations for all in one display
mergeChart1<-gvisMerge(makeStockChart(CGC),makeStockChart(GWW))
losersMerged<-gvisMerge(mergeChart1,makeStockChart(ACBFF))
mergeChart2<-gvisMerge(makeStockChart(CRSP),(makeStockChart(I)))
gainersMerged<-gvisMerge(mergeChart2, makeStockChart(ARRY))
finalMerged<-gvisMerge(losersMerged,gainersMerged,horizontal=TRUE)
plot(finalMerged)


#Save objects
save(dtm1,dtm2,file = "gainersLosersDTMs.RData")


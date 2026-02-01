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

# Set directory
dir <- "C:/Users/pocke/OneDrive/Boston University/CS 688/Paul_Roche_Final_Project/"
setwd(dir)
 
# Import twitter API and access keys
source("twitter_keys.r")
#Setup authorization for API
setup_twitter_oauth(t.api.key,t.api.secret,t.access.key,t.access.secret)

#Set start and end dates
start <- as.Date("2018-10-08")
end <- as.Date("2018-10-12")

# Compile tweets from hand selected stocks
aaplTweets<-c(searchTwitter('#AAPL ',n=250,lang = 'en',since = as.character(start),
                            until = as.character(end)),
                searchTwitter('$AAPL ',n=250,lang = 'en',since = as.character(start),
                              until = as.character(end)))
gmTweets<-c(searchTwitter('#GM ',n=250,lang = 'en',since = as.character(start),
                            until = as.character(end)),
              searchTwitter('$GM ',n=250,lang = 'en',since = as.character(start),
                            until = as.character(end)))
googlTweets<-c(searchTwitter('$GOOGL ',n=250,lang = 'en',since = as.character(start),
                            until = as.character(end)),
              searchTwitter('$GOOG ',n=250,lang = 'en',since = as.character(start),
                            until = as.character(end)))
jnjTweets<-c(searchTwitter('#JNJ ',n=250,lang = 'en',since = as.character(start),
                            until = as.character(end)),
              searchTwitter('$JNJ ',n=250,lang = 'en',since = as.character(start),
                            until = as.character(end)))
cviaTweets<-c(searchTwitter('#CVIA ',n=250,lang = 'en',since = as.character(start),
                            until = as.character(end)),
              searchTwitter('$CVIA ',n=250,lang = 'en',since = as.character(start),
                            until = as.character(end)))
auTweets<-c(searchTwitter('#AU ',n=250,lang = 'en',since = as.character(start),
                            until = as.character(end)),
              searchTwitter('$AU ',n=250,lang = 'en',since = as.character(start),
                            until = as.character(end)))
#For fun, I'll also track the largest market cap S&P500 ETF (only $spy to minimize false data)
spyTweets<-c(searchTwitter('$spy ',n=250,lang = 'en',since = as.character(start),
                          until = as.character(end)))

# Check first tweets
aaplTweets[[1]]
gmTweets[[1]]
googlTweets[[1]]
jnjTweets[[1]]
cviaTweets[[1]]
auTweets[[1]]
spyTweets[[1]]

# Eliminate usernames in order to get only text from tweets
aaplTweets.text <- lapply(aaplTweets, function(t) {t$getText()})
gmTweets.text <- lapply(gmTweets, function(t) {t$getText()})
googlTweets.text <- lapply(googlTweets, function(t) {t$getText()})
jnjTweets.text <- lapply(jnjTweets, function(t) {t$getText()})
cviaTweets.text <- lapply(cviaTweets, function(t) {t$getText()})
auTweets.text <- lapply(auTweets, function(t) {t$getText()})
spyTweets.text <- lapply(spyTweets, function(t) {t$getText()})

# Text mine for each stock
aaplTweets.source <- VectorSource(aaplTweets.text)
aaplTweets.corpus <- Corpus(aaplTweets.source)
gmTweets.source <- VectorSource(gmTweets.text)
gmTweets.corpus <- Corpus(gmTweets.source)
googlTweets.source <- VectorSource(googlTweets.text)
googlTweets.corpus <- Corpus(googlTweets.source)
jnjTweets.source <- VectorSource(jnjTweets.text)
jnjTweets.corpus <- Corpus(jnjTweets.source)
cviaTweets.source <- VectorSource(cviaTweets.text)
cviaTweets.corpus <- Corpus(cviaTweets.source)
auTweets.source <- VectorSource(auTweets.text)
auTweets.corpus <- Corpus(auTweets.source)
spyTweets.source <- VectorSource(spyTweets.text)
spyTweets.corpus <- Corpus(spyTweets.source)

# Inspect each corpus
inspect(aaplTweets.corpus[1])
inspect(gmTweets.corpus[1])
inspect(googlTweets.corpus[1])
inspect(jnjTweets.corpus[1])
inspect(cviaTweets.corpus[1])
inspect(auTweets.corpus[1])
inspect(spyTweets.corpus[1])

# Pre-processing: AAPL
# Before
aaplTweets.corpus[[1]]$content
# Remove url from tweets
removeURL <- function (x) { gsub(" ?(f|ht)tp(s?)://(.*)", "", gsub(" ?(f|ht)tp(s?)://\\S+ ", "", x)) }
aaplTweets.corpus <- tm_map(aaplTweets.corpus,content_transformer(removeURL))
# A look into one of the corpuses
aaplTweets.corpus.temp1[[1]]$content
aaplTweets.corpus.temp1<- tm_map(aaplTweets.corpus,removePunctuation) # Remove Punctuation
#Peek into file to see punctuation removed
aaplTweets.corpus.temp1[[1]]$content
aaplTweets.corpus.temp2<- tm_map(aaplTweets.corpus.temp1, content_transformer(tolower)) # Lowercase
#Another quick look with all lowercase letters
aaplTweets.corpus.temp2[[1]]$content
aaplTweets.corpus.temp3 <- tm_map(aaplTweets.corpus.temp2, removeWords, stopwords("english")) # Remove stopwords
#Another quick look with no stop words
aaplTweets.corpus.temp3[[1]]$content
aaplTweets.corpus.temp4 <- tm_map(aaplTweets.corpus.temp3, function(x) iconv(enc2utf8(x), sub = "byte")) # Remove emojis
#Another quick look with no emojis
aaplTweets.corpus.temp4[[1]]$content
#Final version
aaplTweets.corpus<-aaplTweets.corpus.temp4

# Pre-processing: GM
# A quick look before preprocessing
gmTweets.corpus[[1]]$content
# Preprocessing
gmTweets.corpus <- tm_map(gmTweets.corpus,content_transformer(removeURL)) # Remove URLs
gmTweets.corpus<- tm_map(gmTweets.corpus,removePunctuation) # Remove Punctuation
gmTweets.corpus<- tm_map(gmTweets.corpus, content_transformer(tolower)) # Lowercase
gmTweets.corpus <- tm_map(gmTweets.corpus, removeWords, stopwords("english")) # Remove stopwords
gmTweets.corpus <- tm_map(gmTweets.corpus, function(x) iconv(enc2utf8(x), sub = "byte")) # Remove emojis
# A quick look after preprocessing
gmTweets.corpus[[1]]$content

# Pre-processing: GOOGL
# A quick look before preprocessing
googlTweets.corpus[[1]]$content
# Preprocessing
googlTweets.corpus <- tm_map(googlTweets.corpus,content_transformer(removeURL)) # Remove URLs
googlTweets.corpus<- tm_map(googlTweets.corpus,removePunctuation) # Remove Punctuation
googlTweets.corpus<- tm_map(googlTweets.corpus, content_transformer(tolower)) # Lowercase
googlTweets.corpus <- tm_map(googlTweets.corpus, removeWords, stopwords("english")) # Remove stopwords
googlTweets.corpus <- tm_map(googlTweets.corpus, function(x) iconv(enc2utf8(x), sub = "byte")) # Remove emojis
# A quick look after preprocessing
googlTweets.corpus[[1]]$content

# Pre-processing: JNJ
# A quick look before preprocessing
jnjTweets.corpus[[1]]$content
# Preprocessing
jnjTweets.corpus <- tm_map(jnjTweets.corpus,content_transformer(removeURL)) # Remove URLs
jnjTweets.corpus<- tm_map(jnjTweets.corpus,removePunctuation) # Remove Punctuation
jnjTweets.corpus<- tm_map(jnjTweets.corpus, content_transformer(tolower)) # Lowercase
jnjTweets.corpus <- tm_map(jnjTweets.corpus, removeWords, stopwords("english")) # Remove stopwords
jnjTweets.corpus <- tm_map(jnjTweets.corpus, function(x) iconv(enc2utf8(x), sub = "byte")) # Remove emojis
# A quick look after preprocessing
jnjTweets.corpus[[1]]$content

# Pre-processing: CVIA
# A quick look before preprocessing
cviaTweets.corpus[[1]]$content
# Preprocessing
cviaTweets.corpus <- tm_map(cviaTweets.corpus,content_transformer(removeURL)) # Remove URLs
cviaTweets.corpus<- tm_map(cviaTweets.corpus,removePunctuation) # Remove Punctuation
cviaTweets.corpus<- tm_map(cviaTweets.corpus, content_transformer(tolower)) # Lowercase
cviaTweets.corpus<- tm_map(cviaTweets.corpus, content_transformer(stripWhitespace)) # strip Whitespace
cviaTweets.corpus <- tm_map(cviaTweets.corpus, removeWords, stopwords("english")) # Remove stopwords
cviaTweets.corpus <- tm_map(cviaTweets.corpus, function(x) iconv(enc2utf8(x), sub = "byte")) # Remove emojis
# A quick look after preprocessing
cviaTweets.corpus[[1]]$content

# Pre-processing: AU
# A quick look before preprocessing
auTweets.corpus[[1]]$content
# Preprocessing
auTweets.corpus <- tm_map(auTweets.corpus,content_transformer(removeURL)) # Remove URLs
auTweets.corpus<- tm_map(auTweets.corpus,removePunctuation) # Remove Punctuation
auTweets.corpus<- tm_map(auTweets.corpus, content_transformer(tolower)) # Lowercase
auTweets.corpus <- tm_map(auTweets.corpus, removeWords, stopwords("english")) # Remove stopwords
auTweets.corpus <- tm_map(auTweets.corpus, function(x) iconv(enc2utf8(x), sub = "byte")) # Remove emojis
# A quick look after preprocessing
auTweets.corpus[[1]]$content

# Pre-processing: SPY
# A quick look before preprocessing
spyTweets.corpus[[1]]$content
# Preprocessing
spyTweets.corpus <- tm_map(spyTweets.corpus,content_transformer(removeURL)) # Remove URLs
spyTweets.corpus<- tm_map(spyTweets.corpus,removePunctuation) # Remove Punctuation
spyTweets.corpus<- tm_map(spyTweets.corpus, content_transformer(tolower)) # Lowercase
spyTweets.corpus <- tm_map(spyTweets.corpus, removeWords, stopwords("english")) # Remove stopwords
spyTweets.corpus <- tm_map(spyTweets.corpus, function(x) iconv(enc2utf8(x), sub = "byte")) # Remove emojis
# A quick look after preprocessing
spyTweets.corpus[[1]]$content

# Create term document matrix for all hand selected stocks
# Create Document Term Matrix with word length >= 3 and >= 4 reps
# Document term matrix
aapldtm <- DocumentTermMatrix(aaplTweets.corpus, control=list(wordLengths=c(3,Inf), bounds=list(global=c(4,Inf)) ) )
gmdtm <- DocumentTermMatrix(gmTweets.corpus, control=list(wordLengths=c(3,Inf), bounds=list(global=c(4,Inf)) ) )
googldtm <- DocumentTermMatrix(googlTweets.corpus, control=list(wordLengths=c(3,Inf), bounds=list(global=c(4,Inf)) ) )
jnjdtm <- DocumentTermMatrix(jnjTweets.corpus, control=list(wordLengths=c(3,Inf), bounds=list(global=c(4,Inf)) ) )
cviadtm <- DocumentTermMatrix(cviaTweets.corpus, control=list(wordLengths=c(3,Inf), bounds=list(global=c(4,Inf)) ) )
audtm <- DocumentTermMatrix(auTweets.corpus, control=list(wordLengths=c(3,Inf), bounds=list(global=c(4,Inf)) ) )
spydtm <- DocumentTermMatrix(spyTweets.corpus, control=list(wordLengths=c(3,Inf), bounds=list(global=c(4,Inf)) ) )


# Find frequent terms
# AAPL:
aaplTopWords<-findFreqTerms(aapldtm,50)
aapl.m<-as.matrix(aapldtm)
aapl.v<-sort(colSums(aapl.m),decreasing = TRUE)
aapl.top<-head(aapl.v,50)
head(aapl.top,10)
# gm:
gmTopWords<-findFreqTerms(gmdtm,50)
gm.m<-as.matrix(gmdtm)
gm.v<-sort(colSums(gm.m),decreasing = TRUE)
gm.top<-head(gm.v,50)
head(gm.top,10)
# googl:
googlTopWords<-findFreqTerms(googldtm,50)
googl.m<-as.matrix(googldtm)
googl.v<-sort(colSums(googl.m),decreasing = TRUE)
googl.top<-head(googl.v,50)
head(googl.top,10)
# jnj:
jnjTopWords<-findFreqTerms(jnjdtm,50)
jnj.m<-as.matrix(jnjdtm)
jnj.v<-sort(colSums(jnj.m),decreasing = TRUE)
jnj.top<-head(jnj.v,50)
head(jnj.top,10)
# cvia:
cviaTopWords<-findFreqTerms(cviadtm,50)
cvia.m<-as.matrix(cviadtm)
cvia.v<-sort(colSums(cvia.m),decreasing = TRUE)
cvia.top<-head(cvia.v,50)
head(cvia.top,10)
# au:
auTopWords<-findFreqTerms(audtm,50)
au.m<-as.matrix(audtm)
au.v<-sort(colSums(au.m),decreasing = TRUE)
au.top<-head(au.v,50)
head(au.top,10)
# spy:
spyTopWords<-findFreqTerms(spydtm,50)
spy.m<-as.matrix(spydtm)
spy.v<-sort(colSums(spy.m),decreasing = TRUE)
spy.top<-head(spy.v,50)
head(spy.top,10)

# Word Cloud
wordcloud(names(aapl.top), freq = unname(aapl.top),colors=brewer.pal(8, "Dark2"),
          random.order = FALSE)
wordcloud(names(gm.top), freq = unname(gm.top),scale=c(3,.2), 
          random.order = FALSE,rot.per=.5,colors=brewer.pal(8, "Dark2"))
wordcloud(names(googl.top), freq = unname(googl.top),scale=c(3,.2), 
          random.order = FALSE,rot.per=.5,colors=brewer.pal(8, "Dark2"))
wordcloud(names(jnj.top), freq = unname(jnj.top),colors=brewer.pal(8, "Dark2"),
          random.order = FALSE)
wordcloud(names(cvia.top), freq = unname(cvia.top),colors=brewer.pal(8, "Dark2"),
          random.order = FALSE)
wordcloud(names(au.top), freq = unname(au.top),scale=c(3,.2), 
          random.order = FALSE,rot.per=.5,colors=brewer.pal(8, "Dark2"))
wordcloud(names(spy.top), freq = unname(spy.top),colors=brewer.pal(8, "Dark2"),
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

aapl.sent<-sentiment(aaplTweets.text,pos.words,neg.words)
gm.sent<-sentiment(gmTweets.text,pos.words,neg.words)
googl.sent<-sentiment(googlTweets.text,pos.words,neg.words)
jnj.sent<-sentiment(jnjTweets.text,pos.words,neg.words)
cvia.sent<-sentiment(cviaTweets.text,pos.words,neg.words)
au.sent<-sentiment(auTweets.text,pos.words,neg.words)
spy.sent<-sentiment(spyTweets.text,pos.words,neg.words)


barplot(c(aapl.sent,gm.sent,googl.sent,jnj.sent,cvia.sent,au.sent,spy.sent), names.arg = c("AAPL","GM","GOOG","JNJ","CVIA","AU","SPY"),
        xlab="Stock Symbol", ylab="Sentiment",col="cyan",main="Stock Sentiment",cex.names = 0.9)

#Get stock data and plot it
allStocks<-c("AAPL","GM","GOOG","JNJ","CVIA","AU","SPY")
getSymbols(allStocks,src = "yahoo")
chartSeries(AAPL,type = "candlesticks",subset = '2018-10-08::2018-10-12',
            up.col = "green",dn.col = "red",TA=NULL)
chartSeries(GM,type = "candlesticks",subset = '2018-10-08::2018-10-12',
            up.col = "green",dn.col = "red",TA=NULL)
chartSeries(GOOG,type = "candlesticks",subset = '2018-10-08::2018-10-12',
            up.col = "green",dn.col = "red",TA=NULL)
chartSeries(JNJ,type = "candlesticks",subset = '2018-10-08::2018-10-12',
            up.col = "green",dn.col = "red",TA=NULL)
chartSeries(CVIA,type = "candlesticks",subset = '2018-10-08::2018-10-12',
            up.col = "green",dn.col = "red",TA=NULL)
chartSeries(AU,type = "candlesticks",subset = '2018-10-08::2018-10-12',
            up.col = "green",dn.col = "red",TA=NULL)
chartSeries(SPY,type = "candlesticks",subset = '2018-10-08::2018-10-12',
            up.col = "green",dn.col = "red",TA=NULL)

#Save objects
save(aapldtm, gmdtm, googldtm, jnjdtm, cviadtm, audtm, spydtm,file = "handselectedDTMs.RData")
save(aaplTweets.corpus, gmTweets.corpus, googlTweets.corpus, jnjTweets.corpus, 
     cviaTweets.corpus, auTweets.corpus, spyTweets.corpus,file = "handselectedCorpuses.RData")

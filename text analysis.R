#Text Mining Assignment

library(tm)
install.packages('readr')
library(readr)#package for reading files
library(wordcloud)
library(cluster)

#set the working directory
setwd("C:/Users/pradn/Documents/text analysis")
getwd()

#Reading the text file
pride <- read_file("C:/Users/pradn/Documents/text analysis/pride.txt")
#complete text file read into one char cell
str(pride)
#counting the number of characters
nchar(pride)


#split each paragraph into a new row
pride <- strsplit(pride, "\\r\\n\\r") 

pride <- unlist(pride) #str returns list lets convert to character vector
str(pride)

#remove line break \n and carriage return codes \r and \" marks replacing with a space
pride <-  gsub('\\n|\\r|\\"', " ", pride)

#Regular Expressions

#Letters, digits and punctuation characters starting with @ are removed and replaced with USER.
pride<- gsub("@\\w*"," USER",   pride)
head(pride)

##Website links are removed and replaced with "URL"
pride  <- gsub("http[[:alnum:][:punct:]]*"," WEBADDRESS",   tolower(pride ))
pride  <- gsub("www[[:alnum:][:punct:]]*"," WEBADDRESS",   tolower(pride ))
head(pride, 20)

#html entities like &quot are removed
pride <-gsub("\\&\\w*;","", pride)

#Any letters repeated more than twice are removed (eg. ughhhh -> ughh)
pride  <- gsub('([[:alpha:]])\\1+', '\\1\\1', pride)

#additional cleaning removing leaving only letters numbers or spaces
pride <- gsub("[^a-zA-Z0-9 ]","",pride)

#review text now
head(pride,20)

#list of stopwords
stopwords("english")


#create Corpus
Pride_Corpus <-  Corpus(VectorSource(pride))

Pride_Corpus <- tm_map(Pride_Corpus, removePunctuation)
Pride_Corpus <- tm_map(Pride_Corpus, removeNumbers)
Pride_Corpus <- tm_map(Pride_Corpus, removeWords, stopwords("english"))
Pride_Corpus <- tm_map(Pride_Corpus, stripWhitespace)  

#create term document matrix (terms as rows, documents as columns)
tdm <- TermDocumentMatrix(Pride_Corpus)

#count row (i.e, terms)
tdm$nrow 

#inspect the term document matrix
inspect(tdm[1:29, 1:2])

#remove words that are over 98% sparse (i.e., do not appear in 98% of documents)
tdm <- removeSparseTerms(tdm, 0.98)
tdm$nrow 
tdm$ncol 
inspect(tdm[1:29, 1:3])

inspect(tdm)

head(pride)


# define tdm as matrix
k = as.matrix(tdm)
p <- sort(rowSums(k),decreasing=TRUE)
d <- data.frame(word = names(p),freq=p)
d #lets see frequency of words

# plot wordcloud
set.seed(1)
wordcloud(words = d$word, freq = d$freq, min.freq = 1,
          max.words=200, random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Dark2"))

#find association between said and will
findAssocs(tdm, terms = c("said", "will"), corlimit = .0) 

#make a bar chart of frequent words
barplot(d[1:10,]$freq, las = 2, names.arg = d[1:10,]$word,
        col ="lightblue", main ="Most frequent words",
        ylab = "Word frequencies")

#lets cluster the documents. find optimal k
wss <- numeric(15) 
for (k in 1:10) wss[k] <- sum(kmeans(tdm, centers=k)$withinss)
plot(wss, type="b") #type b stand for plotting line and point both

pride.kmeans <- kmeans(tdm,2)#2 clusters are formed.
pride.kmeans$cluster
head(pride,50)

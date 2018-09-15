#Big Data Project Fall 2017
#Data set : 370k used cars data base from ebay with 19 variables.
#Agenda:
# Price prediction depending upon model input specifications using regression analysis.
# Find most used car brand using text analysis
# Find if the car will be sold or not given its specifications using classification analysis

#install and load the necessary packages

install.packages(c("tm", "SnowballC", "rpart", "data.table", "caret" , 
                   "cluster", "wordcloud", "mice", "VIM", "tidyverse", "forcats","neuralnet"))
library(tidyverse)# used for taking the function of filtering the columns
library(forcats) #used for dealing with categorical variables
library(tm) #for corpus and term document matrix creation/processing
library(SnowballC) #for stemming of words in corpus 
library(wordcloud) # for creating wordcloud
library(cluster) #for kmeans cluster creation
library(caret) #used for preprocessing and training models
library(data.table) #used for data manipulation of large datasets
library(rpart) # for decision tree
library(rpart.plot)# for plotting DT
library(e1071) 
library(neuralnet)#for Neural Network
library(dplyr)#used for data partitioning

#------------------------ Objective 1: Find most used car brand using text analysis------------------------

system.time(car.data <- fread("car_DB.csv"))
#data cleaning with regular expressions
#Make all the texts to lowercase e.g. this shall make only one term for Hello or hello and not two
car.data$brand <-  tolower(car.data$brand)

#removing punctuations and unnecessary dots for eg. ok... -> ok 
car.data$brand <- gsub("_","",car.data$brand)

#removing letters repeated more than twice in a word e.g. helloooo -> helloo 
car.data$brand  <- gsub('([[:alpha:]])\\1+', '\\1\\1', car.data$brand)

#to show spreadsheet output in R itself.
View(car.data)
#create the corpus on text messages and cleaning the text before creating a term document matrix
car.corpus <- Corpus(VectorSource(car.data$brand))
#create a term document matrix from the cleaned corpus
tdm <- TermDocumentMatrix(car.corpus)
tdm$nrow #40 rows/terms that shall represent 40 unique car brands


#convert the tdm to matrix to work on it
car.mat <- as.matrix(tdm)
v <- sort(rowSums(car.mat),decreasing=TRUE) #store the row sum count in decresing order
d <- data.frame(word = names(v),freq=v) #store the row name and their count in a data frame
View(d)

set.seed(2)
wordcloud(words = d$word, freq = d$freq, min.freq = 20,
          max.words=50, random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Dark2"))

barplot(d[1:10,]$freq, las = 3, names.arg = d[1:10,]$word,
        col ="lightblue", main ="Most frequent words",
        ylab = "Word frequencies")

#---------------------end of Objective1: most used cars using text analysis------------------------

#---------------------Objective 2: car price predictor using Regression analysis---------------
#---------------------steps to prepare the data-----------------------

car.db.original <- read.csv("car_DB.csv") # to be done only once to save read times
saveRDS(car.db.original,"car.db.RDS")
car.db.original <- readRDS("car.db.RDS") # for every consecutive read after reading csv once

drops<-c("price", "yearOfRegistration","seller" ,"offerType", "gearbox","powerPS", "kilometer", "fuelType", "brand","Label")
car.db <- car.db.original [,(names(car.db.original) %in% drops)] #select only columns from drops

cleaned.car.db[cleaned.car.db$fuelType=="",]$fuelType <- as.factor("others")
cleaned.car.db <- filter(car.db, price< 150000, price>100,
                         yearOfRegistration>1975, yearOfRegistration<2017, 
                         powerPS<750) 
cleaned.car.db$gearbox <- factor(cleaned.car.db$gearbox)
cleaned.car.db$brand <- factor(cleaned.car.db$brand)
cleaned.car.db$fuelType <- factor(cleaned.car.db$fuelType)
cleaned.car.db$seller <- factor(cleaned.car.db$seller)
cleaned.car.db$offerType <- factor(cleaned.car.db$offerType)

set.seed(100)
train<-sample_frac(cleaned.car.db, 0.90)
sid<-as.numeric(rownames(train)) # because rownames() returns character
test<-cleaned.car.db[-sid,]
#--------------------end of data preparation steps----------------------------

#-------------------model1: Decision Tree------------------------
system.time(model.DT <- rpart(price ~ seller + offerType +  yearOfRegistration + gearbox + powerPS + kilometer + fuelType + brand + Label, 
                              method="anova", 
                              data=train))

rpart.plot(model.DT, digits=2, fallen.leaves=TRUE, type=3, extra=101)

p.rpart <- predict(model.DT, test)#performance testing

#comparing test set to predictions
summary(p.rpart)
summary(test)

dt.r2 <- cor(as.numeric(test$price), p.rpart) #gives out correlation of 0.7974
MAE(as.numeric(test$price),p.rpart) # gives out 2690

opt.cp <- model.DT$cptable[which.min(model.DT$cptable[,"xerror"]),"CP"] #tuning the tree by grabbing the CP with lowest error 

model.DT.pruned <- prune(model.DT, cp=opt.cp) #prune the tree

rpart.plot(model.DT.pruned)#lets review the final tree

p.rpart.pruned <- predict(model.DT.pruned, test) 
dt.r2.pruned <- cor(as.numeric(test$price), p.rpart.pruned) #gives out correlation of 0.7974

par(mfrow=c(1,3)) 
rsq.rpart(model.DT.pruned)

tmp <- printcp(model.DT)
rsq.val <- 1-tmp[,c(3,4)] #plotting the CP table

#-------------------end of model1: Decision Tree------------------------

#--------------Model 2: multiple regression--------------------------
system.time(model.MR <- lm(price ~ seller + offerType +  yearOfRegistration + gearbox + powerPS + kilometer + fuelType + brand + Label,
                           data = train))
reg.check <- predict(model.MR,test)
mr.r2 <- cor(as.numeric(test$price), reg.check) #gives out correlation of 0.7757

#--------------end of Model 2: multiple regression--------------------------
#--------------Model 3: Random FOrest ----------------------------

train.rf <- train[1:100000,]
system.time(model.DT.rf <- randomForest(price ~ seller + offerType +  yearOfRegistration + gearbox + powerPS + kilometer + fuelType + brand + Label, 
                                        data=train.rf))
test.rf <- test[1:10000,]
rf.check <- predict(model.DT, test.rf)
rf.r2 <- cor(as.numeric(test[1:10000,]$price), rf.check) 
#-------------------end of model3: Random FOrest------------------------
#-------------------------Model 4,5: SVM------------------------------------------
train.svm <- train[1:100000,]
install.packages("kernlab")
library(kernlab)
system.time(model.svm <- ksvm(price ~ ., data = train.svm ,
                              kernel = "vanilladot", scaled=TRUE))

test.svm <- test[1:10000,]
svm.check <- predict(model.svm, test.svm)
svm.r1 <- cor(as.numeric(test[1:10000,]$price), svm.check)

system.time(model.svm.rbf <- ksvm(price ~ ., data = train.svm ,
                                  kernel = "rbfdot", scaled=TRUE))
svm.check.rbf <- predict(model.svm.rbf, test.svm)
svm.r2.rbf <- cor(as.numeric(test[1:10000,]$price), svm.check.rbf)

#-------------------------end of Model 4,5: SVM------------------------------------------

#----------------------------Model 6: Neural NEtwork--------------------------------

set.seed(12345) 
x.dummy.model.train <- dummyVars("~ .", data=train, fullRank=TRUE)
nn.train <- data.frame(predict(x.dummy.model.train, train))
x.dummy.model.test <- dummyVars("~ .", data=test, fullRank=TRUE)
nn.test<- data.frame(predict(x.dummy.model.test, test))

normalize <- function(x) { 
  return((x - min(x)) / (max(x) - min(x)))
}

a.nn.train <-  as.data.frame(lapply(nn.train, normalize))
a.nn.test <- as.data.frame(lapply(nn.test, normalize))

ctrl.nn <- trainControl(method="cv",number=10,
                        summaryFunction = defaultSummary, #regression performance measures
                        allowParallel = FALSE) 
library("doParallel")
cl <- makeForkCluster(4)
registerDoParallel(cl)

a.nn.train1<-sample_frac(a.nn.train, 0.30) #roughly 100k records
a.nn.test1 <- sample_frac(a.nn.test,0.30) #roughly 10k records

system.time(m.nn <- train(price ~ .,
                          data = a.nn.train1, trControl = ctrl.nn,
                          method = "nnet"))
getTrainPerf(m.nn)

nn.predict <- predict(m.nn, newdata = a.nn.test1)
nn.rmse <- sqrt(mean((nn.predict - a.nn.test1$price)^2)) 


nn.grid <- expand.grid(size=c(4,5,6,7,8,9,10), decay=c(.0001, .001, .01))


system.time(m.nn.customgrid <- train(price ~ .,
                                     data = a.nn.train1, trControl = ctrl.nn,
                                     tune.grid=nn.grid,
                                     method = "nnet"))

plot(m.nn.customgrid)
getTrainPerf(m.nn.customgrid)

rValues <- resamples(list(nn.grid=m.nn, nn=m.nn.customgrid))

summary(rValues)

nn.grid.update <- expand.grid(size=c(5,6,7), decay=c(0.5,0.1))


system.time(m.nn.customgrid <- train(price ~ .,
                                     data = a.nn.train1, trControl = ctrl.nn,
                                     tune.grid=nn.grid.update,
                                     method = "nnet", linout=1 , trace=F , maxit=500))

#create plot comparing them
bwplot(rValues, metric="MAE")
bwplot(rValues, metric="RMSE") #Sensitvity
bwplot(rValues, metric="Rsquared")
#----------------------------end of Model 6: Neural NEtwork--------------------------------

#-----------------------BACKUP for regression--------------------------------------------
a <- c(dt.r2,mr.r2,rf,svm.r1,svm.r2.rbf)
b <- c("Decision Tree", "Mult Reg","Random Forest","SVM.V","SVM.R")
c <- data.frame(model=b,cor_measure=a)
c
model <- c$model
accuracy <- c$cor_measure

ggplot(c, aes(model,accuracy, fill="")) + geom_bar(stat = "identity" , col="blue")
qplot(model,accuracy,c, method=lm, color="blue")
ggplot(c,aes(c$model,c$cor_measure))+geom_line(aes(color = "red")) 
#-----------------------end of BACKUP for regression--------------------------------------------

#-------------------- end of Objective 2: price prediction with regression-----------------------

#---------------------Objective 3: Classification with Class Label, sold or not sold--------------
y <- cleaned.car.db$Label 
x <- cleaned.car.db[,1:9]

set.seed(192)
inTrain<-createDataPartition(y=y, p=.90, list=FALSE)#lets split out using index of training and test sets created above, uses row index
y.train <- y[inTrain]
x.train <- x[inTrain,]
y.test<- y[-inTrain]
x.test <- x[-inTrain,]
#check composition
table(y.train)
table(y.test)

#----------------Model1: Decision Tree-------------------
ctrl.cv <- trainControl(method="cv", number=10,
                        classProbs=TRUE,
                        #function used to measure performance
                        summaryFunction = twoClassSummary, #multiClassSummary for non binary
                        allowParallel =  FALSE) #am disabling allowParallel because of bug in caret 6.0-77
#example models are small enough that parallel not important but set to TRUE! when working with large datasets  

ctrl.boost <- trainControl(method="boot", number=20)
#levels(y.train) <- make.names(levels(factor(y.train)))
#--------------DT---------------------------
system.time(m.rpart <- train(y=y.train, x=x.train,
                             trControl = ctrl.cv,
                             metric = "ROC", #using AUC to find best performing parameters
                             method = "rpart"))
getTrainPerf(m.rpart)
p.rpart <- predict(m.rpart,x.test)
#levels(y.test) <- make.names(levels(factor(y.test)))
confusionMatrix(p.rpart,y.test)
# install.packages("lattice")
# library(lattice)
# bwplot(p.rpart,metric="ROC")
# install.packages("thePackage")
system.time(m.rpart.boost <- train(y=y.train, x=x.train,
                                   trControl = ctrl.boost,
                                   metric = "ROC", #using AUC to find best performing parameters
                                   method = "rpart" , classProbs= TRUE))
library(ROCR)
#-----------------------------------
#---------------------DT15----------------------
set.seed(192)
system.time(m.rpart.15 <- train(y=y.train, x=x.train,
                                trControl = ctrl.cv,
                                metric = "ROC", #using AUC to find best performing parameters
                                tuneLength=15, #search through 15 different complexity parameters for pruning (150 models, 10 CV x 15 parameters)
                                method = "rpart"))
#m.rpart.15
getTrainPerf(m.rpart.15)
p.rpart.15 <- predict(m.rpart.15,x.test)
#levels(y.test) <- make.names(levels(factor(y.test)))
confusionMatrix(p.rpart.15,y.test)
#------------------------------------------------
#----------------Model 2 : Naive Bayes-------------------------------
set.seed(192)
system.time(m.nb <- train(y=y.train, x=x.train,
                          trControl = ctrl.cv,
                          metric = "ROC", #using AUC to find best performing parameters
                          method = "nb"))
m.nb
getTrainPerf(m.nb)

varImp(m.nb)
plot(m.nb)
p.nb<- predict(m.nb,x.test)
confusionMatrix(p.nb,y.test) #calc accuracies with confusion matrix on test set
getTrainPerf(m.nb)
#----------------end of Model 2 : Naive Bayes------------------------
#-------------- Model 3 : treebag--------------------------------------

library(ipred)
set.seed(192)
modelLookup("")
system.time(  m.bag <- train(y=y.train, x=x.train,
                             trControl = ctrl.cv,
                             metric = "ROC", #using AUC to find best performing parameters
                             method = "treebag"))
m.bag
p.bag<- predict(m.bag,x.test)
confusionMatrix(p.bag,y.test)

#--------------end of Model 3 : treebag--------------------------------
#-------------------Model 4: RF--------------------------------
set.seed(192)
system.time(m.rf <- train(y=y.train, x=x.train,
                          trControl = ctrl.cv,
                          metric = "ROC", #using AUC to find best performing parameters
                          method = c("rf") ))

m.rf
p.rf<- predict(m.rf,x.test)
confusionMatrix(p.rf,y.test)
#-----------------end of Model 4 : RF----------------------------
#------------------MOdel 5: ADA -------------------------------
install.packages("ada")
library(ada)
set.seed(192)
m.ada <- train(y=y.train, x=x.train,
               trControl = ctrl.cv,
               metric = "ROC", #using AUC to find best performing parameters
               method = "ada")

p.ada<- predict(m.ada,x.test)
confusionMatrix(p.ada,y.test)
stopCluster(cl)

#------------------ end of MOdel 5: ADA -------------------------------
#--------------consolidating results-------------------------------------
rValues1 <- resamples(list(DT=m.rpart,DTtuned=m.rpart.15,NB=m.nb, Bag=m.bag, Boost=m.ada, RF=m.rf))

bwplot(rValues1, metric="ROC")
bwplot(rValues1, metric="Sens") #Sensitvity
bwplot(rValues1, metric="Spec")
#-------------------end of consolidation ----------------------------------
#---------------------end of Objective 3: Classification with Class Label, sold or not sold--------------
#--------------------Visualizations------------------------------
install.packages("earth")
library(earth)
m.earth <- earth(price ~ ., data=train)
ev <- evimp(m.earth)
ev

outlier_values <- boxplot.stats(cleaned.car.db$kilometer)$out  # outlier values.
boxplot(cleaned.car.db$kilometer, main="Kilometer", boxwex=0.1)
mtext(paste("Outliers: ", paste(outlier_values, collapse=", ")), cex=0.6)

system.time(pair <- pairs(cleaned.car.db))
system.time(cor1 <- cor(cleaned.car.db))
#--------------------end of Visualizations-----------------------

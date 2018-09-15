#Part A-Poverty Prediction library(ggplot2) # Data visualization
library(readr) # CSV file I/O, e.g. the read_csv function
library(reshape2)
library(dplyr)
# system("ls ../input")
# Read input file
data <- as.data.frame(read.csv("acs2015_census_tract_data_new.csv"))
str(data)
# Find total population, poverty population, and poverty rate by state
statepop<-aggregate(data$TotalPop,by=list(data$State),FUN=sum)
colnames(statepop)<-c('State','Population')
data$povertyPop<-data$TotalPop*data$Poverty/100
statepoverty<-aggregate(data$povertyPop,by=list(data$State),FUN=sum, na.rm=TRUE)
colnames(statepoverty)<-c('State','povertyPop')
bystate<-merge(statepop,statepoverty,by='State')
bystate$povertyRate<-bystate[,3]/bystate[,2]*100
bystate$nonpoverty<-bystate$Population-bystate$povertyPop
# reshape the dataframe and prepare for plotting
bystate.melt<-melt(bystate[,c('State','nonpoverty','povertyPop')],id='State')
# visualization
ggplot(data=bystate.melt,aes(x=reorder(State,value,sum),y=value,fill=factor(variable))) + geom_bar(stat='identity')+coord_flip()
povertypop.plot<-povertypop.plot+labs(x='State',y='Population')+scale_fill_discrete(name="",
                                                                                    breaks=c('povertyPop','nonpoverty'),
                                                                                    labels=c("Poverty", "Non-poverty")) +ggtitle('Poverty Population by State')
png('poverty_pop_by_state.png')
povertypop.plot
dev.off()
povertypop.plot
# -------------poverty rate by state-------------------
povertyrate.plot<-ggplot(data=bystate,aes(x=reorder(State,povertyRate),y=povertyRate)) + geom_bar(stat='identity',colour='white',fill='blue')+coord_flip()
povertyrate.plot<-povertyrate.plot+labs(x='State',y='Poverty Rate')+scale_y_continuous(limits = c(0, 55))+ guides(fill=FALSE)
povertyrate.plot<-povertyrate.plot+ggtitle('Poverty Rate by State')+geom_text(aes(label=paste(round(povertyRate,digits=2),'%')), hjust=-0.1,size=3.5)
png('poverty_rate_by_state.png')
povertyrate.plot
dev.off()
povertyrate.plot
# exclude Puerto Rico data
data.nopr<-data[data$State!='Puerto Rico',]
bystate<-bystate[bystate$State!='Puerto Rico',]
# aggregate other variables by state
women<-aggregate(data.nopr$Women,by=list(data.nopr$State),FUN=sum, na.rm=TRUE)
colnames(women)<-c('State','Women')
bystate$female<-women[,2]/bystate$Population
#Puerto Rico has exceptionally high poverty rate.
#Since politically it is not a state, the economic model
#might be different there. I will discard 
#the data from Puerto Rico in the following analysis,
#unless stated otherwise.
# exclude Puerto Rico data
data.nopr<-data[data$State!='Puerto Rico',]
bystate<-bystate[bystate$State!='Puerto Rico',]
# aggregate other variables by state
women<-aggregate(data.nopr$Women,by=list(data.nopr$State),FUN=sum, na.rm=TRUE)
colnames(women)<-c('State','Women')
bystate$female<-women[,2]/bystate$Population
bystate$female
# discard rows with NA values
data.nopr.c<-data.nopr[complete.cases(data.nopr),]
# percentage of complete cases
nrow(data.nopr.c)/nrow(data.nopr)
#------There are less than 2% of the rows with missing values.
#Since the proportion is small, we simply discard them,
#without looking for ways to fill them.
#Next, we prepare the data frame for regression.
# Convert populations into percentages
data.p<-data.nopr.c
data.p$Men<-data.p$Men/data.p$TotalPop
data.p$Women<-data.p$Women/data.p$TotalPop
data.p$Citizen<-data.p$Citizen/data.p$TotalPop
data.p$Employed<-data.p$Employed/data.p$TotalPop
# perform simple linear regression
lr<-lm(Poverty ~.-CensusTract-State-County-Men-povertyPop,data.p)
#summary(lr)
# find the least significant predictor
cc<-coef(summary(lr))
which.max(cc[,'Pr(>|t|)'])
lr<-lm(Poverty ~.-CensusTract-State-County-Men-povertyPop-Office,data.p)
# summary(lr)
cc<-coef(summary(lr))
which.max(cc[,'Pr(>|t|)'])
lr<-lm(Poverty ~.-CensusTract-State-County-Men-povertyPop-Office-Walk,data.p)
# summary(lr)
cc<-coef(summary(lr))
which.max(cc[,'Pr(>|t|)'])
# FamilyWork
lr<-lm(Poverty ~.-CensusTract-State-County-Men-povertyPop-Office-Walk-FamilyWork,data.p)
# summary(lr)
cc<-coef(summary(lr))
which.max(cc[,'Pr(>|t|)'])
# Pacific
lr<-lm(Poverty ~.-CensusTract-State-County-Men-povertyPop-Office-Walk-FamilyWork-Pacific,data.p)
# summary(lr)
cc<-coef(summary(lr))
which.max(cc[,'Pr(>|t|)'])
# Pacific
lr<-lm(Poverty ~.-CensusTract-State-County-Men-povertyPop-Office-Walk-FamilyWork-Pacific
       -SelfEmployed,data.p)
# summary(lr)
cc<-coef(summary(lr))
which.max(cc[,'Pr(>|t|)'])
# TotalPop
lm(Poverty ~.-CensusTract-State-County-Men-povertyPop-Office-Walk-FamilyWork-Pacific
   -SelfEmployed-TotalPop,data.p)
# summary(lr)
cc<-coef(summary(lr))
which.max(cc[,'Pr(>|t|)'])
# White
lr<-lm(Poverty ~.-CensusTract-State-County-Men-povertyPop-Office-Walk-FamilyWork-Pacific
       -SelfEmployed-TotalPop-White,data.p)
# summary(lr)
cc<-coef(summary(lr))
which.max(cc[,'Pr(>|t|)'])
# Production
lr<-lm(Poverty ~.-CensusTract-State-County-Men-povertyPop-Office-Walk-FamilyWork-Pacific
       -SelfEmployed-TotalPop-White-Production,data.p)
# summary(lr)
cc<-coef(summary(lr))
which.max(cc[,'Pr(>|t|)'])
# Women
lr<-lm(Poverty ~.-CensusTract-State-County-Men-povertyPop-Office-Walk-FamilyWork-Pacific
       -SelfEmployed-TotalPop-White-Production-Women,data.p)
# summary(lr)
cc<-coef(summary(lr))
which.max(cc[,'Pr(>|t|)'])
# PublicWork
lr<-lm(Poverty ~.-CensusTract-State-County-Men-povertyPop-Office-Walk-FamilyWork-Pacific
       -SelfEmployed-TotalPop-White-Production-Women-PublicWork,data.p)
summary(lr)
data.pn<-scale(select_if(data.p,is.numeric))
data.pn<-data.frame(data.pn[,-1])
#---Now we fit the selected model to the normalized data.
lr.n<-lm(Poverty ~.-Men-povertyPop-Office-Walk-FamilyWork-Pacific
         -SelfEmployed-TotalPop-White-Production-Women-PublicWork,data.pn)
summary(lr.n)
cc<-data.frame(coef(summary(lr.n)))
cc<-cbind(cc,rownames(cc))
coln<-colnames(cc)
coln[5]<-'Predictor'
colnames(cc)<-coln
cc<-cc[-1,]
coef.plot<-ggplot(data=cc,aes(x=reorder(Predictor,Estimate),y=Estimate)) + geom_bar(stat='identity',colour='white',fill='red')+coord_flip()
coef.plot<-coef.plot+labs(x='Predictor',y='Coefficient')
png('linear_model.png')
coef.plot
dev.off()
coef.plot
#-------------------------------------------
nh<-data[data$State=='New Hampshire',]
pr<-data[data$State=='Puerto Rico',]
nh<-nh[complete.cases(nh),]
pr<-pr[complete.cases(pr),]
#--Summaries of poverty rate by tract in New Hampshire and Puerto Rico.
print('New Hampshire Poverty Rate')
summary(nh$Poverty)
#Now we normalize both data frames.
nh.n<-scale(select_if(nh,is.numeric))
nh.n<-data.frame(nh.n[,-1])
pr.n<-scale(select_if(pr,is.numeric))
pr.n<-data.frame(pr.n[,-1])
#Select best models for New Hampshire and Puerto Rico by eliminating
#the most insignificant predictor (as before)
#until obtaining a model with every predictor having t-score smaller than 0.05.
lrnh<-lm(Poverty ~.-Men-povertyPop-ChildPoverty-Drive-Black-Pacific-Native-WorkAtHome-MeanCommute-Professional-Production
         -Service-Construction-FamilyWork-Employed-TotalPop-Office-Carpool-IncomeErr-SelfEmployed-PublicWork-PrivateWork,nh.n)
# cc<-coef(summary(lrnh))
# x<-which.max(cc[-1,'Pr(>|t|)'])
# x
# cc[names(x),]
summary(lrnh)
lrpr<-lm(Poverty ~.-Men-povertyPop-ChildPoverty-White-Construction-Women-Asian-IncomeErr-FamilyWork-PublicWork-Native
         -Carpool-OtherTransp-Pacific-Transit-Black-IncomePerCapErr-MeanCommute-Service-Hispanic-PrivateWork,pr.n)
# cc<-coef(summary(lrpr))
# x<-which.max(cc[-1,'Pr(>|t|)'])
# x
# cc[names(x),]
summary(lrpr)
ccnh<-data.frame(coef(summary(lrnh)))
ccnh<-cbind(ccnh,rownames(ccnh))
cnh<-colnames(ccnh)
cnh[5]<-'Predictor'
colnames(ccnh)<-cnh
ccpr<-data.frame(coef(summary(lrpr)))
ccpr<-cbind(ccpr,rownames(ccpr))
cpr<-colnames(ccpr)
cpr[5]<-'Predictor'
colnames(ccpr)<-cpr
ccnh$State=rep('NH',nrow(ccnh))
ccpr$State=rep('PR',nrow(ccpr))
# Predictors in ccpr but not in ccnh
addtonh<-ccpr$Predictor[!(ccpr$Predictor %in% ccnh$Predictor)]
ccnh<-rbind(ccnh,data.frame('Estimate'=rep(0,length(addtonh)),'Std..Error'=rep(0,length(addtonh)),
                            't.value'=rep(0,length(addtonh)),'Pr...t..'=rep(0,length(addtonh)),
                            'Predictor'=addtonh,'State'=rep('NH',length(addtonh))))
# Predictors in ccnh but not in ccpr
addtopr<-ccnh$Predictor[!(ccnh$Predictor %in% ccpr$Predictor)]
ccpr<-rbind(ccpr,data.frame('Estimate'=rep(0,length(addtopr)),'Std..Error'=rep(0,length(addtopr)),
                            't.value'=rep(0,length(addtopr)),'Pr...t..'=rep(0,length(addtopr)),
                            'Predictor'=addtopr,'State'=rep('PR',length(addtopr))))
nhpr<-rbind(ccnh[-1,],ccpr[-1,])
colnames(nhpr)<-c('Estimate','std','tvalue','tscore','Predictor','State')
#Now we plot the coefficients of both models side by side.
nhpr.plot <- ggplot(nhpr, aes(x=Predictor, y=Estimate, fill=State)) +
  geom_bar(stat="identity", position=position_dodge()) +
  geom_errorbar(aes(ymin=Estimate-std, ymax=Estimate+std), width=.2,
                position=position_dodge(.9))
nhpr.plot<-nhpr.plot+ scale_fill_brewer(palette="Paired") + theme_minimal()+coord_flip()+labs(x='Predictor',y='Coefficient')
png('nh_pr.png')
nhpr.plot
dev.off()
nhpr.plot
#Part B Model Building
#Libraries /packages used :
library(corrplot)
library(caret)
library(leaps)
library(MASS)
library(pls)
# correlation plot
setwd("C:/Users/User/Desktop/MIS-749/us-census-demographic-data/")
uscensus <- read.csv("us_county_data.csv")
names(uscensus)
summary(uscensus)
data_nonfactors <-uscensus[c(4:37)] #this a dataframe upon which we study correlation
names(data_nonfactors)
corrplot(cor(data_nonfactors),method="pie")
corrplot(cor(data_nonfactors), type="full", order="hclust", col=c("black", "white"), bg="lightblue")
#result : highly correlated variables are removed
uscensus.sub <- uscensus[,-c(1,2,3,5,6,13,16,17,19,20,32)]
names(uscensus.sub)

##########################################################
# Models on uncorrelated predictors
##########################################################
uscensus <- read.csv("acs2015_county_data.csv")
names(uscensus)
str(uscensus)
#missing data , removing using na omit
uscensus.sub<- na.omit(uscensus.sub)
sum(complete.cases(uscensus.sub))
sum(!complete.cases(uscensus.sub)) #count of incomplete rows
regfit.full <- regsubsets(Income ~., data = uscensus.sub,nvmax = 20)
regfit.full
reg.summary <- summary(regfit.full)
names(reg.summary)
par(mfrow=c(2,2))
plot(reg.summary$rss ,xlab="Number of Variables ",ylab="RSS", type="l")
plot(reg.summary$adjr2 ,xlab="Number of Variables ", ylab="Adjusted RSq",type="l")
max <- which.max(reg.summary$adjr2)
points(max,reg.summary$adjr2[max], col="red",cex=2,pch=20)
#max = 18
plot(reg.summary$cp ,xlab="Number of Variables ",ylab="Cp", type="l")
min <- which.min(reg.summary$cp )

points(min,reg.summary$cp[min], col="red",cex=2,pch=20)
#min = 17
plot(reg.summary$bic ,xlab="Number of Variables ",ylab="BIC", type="l")
min <- which.min(reg.summary$bic )
points(min,reg.summary$bic[min], col="red",cex=2,pch=20)
#min = 15
#based on Rsquare, cp and bic, model with 15 variables has lowest bic
coef(regfit.full,min)
#TotalPop, Hispanic, White, Native, Asian, IncomeErr, Poverty, Service, Office, Construction, Production,
#MeanCommute, PrivateWork, PublicWork, Unemployment
#Using forward subset selection
regfit.fwd = regsubsets(Income ~., data=uscensus.sub, nvmax=20, method="forward")
summary(regfit.fwd)
reg.fwd.summary <- summary(regfit.fwd)
reg.fwd.summary
names(reg.fwd.summary)
reg.fwd.summary$rsq
plot(reg.fwd.summary$bic ,xlab="Number of Variables ",ylab="BIC", type="l")
min <- which.min(reg.fwd.summary$bic )
points(min,reg.fwd.summary$bic[min], col="red",cex=2,pch=20)
coef(regfit.fwd,min)

#Backward subset selection
#Using forward subset selection
regfit.bwd = regsubsets(Income ~., data=uscensus.sub, nvmax=20, method="backward")
summary(regfit.bwd)
reg.bwd.summary <- summary(regfit.bwd)
reg.bwd.summary
names(reg.bwd.summary)
reg.bwd.summary$rsq
plot(reg.bwd.summary$bic ,xlab="Number of Variables ",ylab="BIC", type="l")
min <- which.min(reg.bwd.summary$bic )
points(min,reg.bwd.summary$bic[min], col="red",cex=2,pch=20)
coef(regfit.bwd,min)
uscensus.sub <- na.omit(uscensus.sub)
ctrl <- trainControl(method = "cv", number=10)
#lcv on forward
set.seed(195) #SEED
d.tfwd <- train(Income ~ ., data= uscensus.sub, method = "leapForward", tuneLength=10, trControl=ctrl) #tunelength = number of k..
d.tfwd
varImp(d.tfwd)
plot(varImp(d.tfwd))
#lcv on forward
set.seed(195) #SEED
d.tbwd <- train(Income ~ ., data= uscensus.sub, method = "leapBackward", tuneLength=10, trControl=ctrl)
d.tbwd
varImp(d.tbwd)
getTrainPerf(d.tfwd)
getTrainPerf(d.tbwd)

#Ridge regression
set.seed(195) #SEED
d.ridge <- train(Income ~ ., preProcess=c("scale"),
                 data= uscensus.sub,
                 method = "ridge", tuneLength=10, trControl=ctrl) #looks throu 10 values of lambda
d.ridge
plot(d.ridge)
varImp(d.ridge)
#Lasso Regression
set.seed(195) #SEED
d.lasso <- train(Income~ .,
                 data= uscensus.sub,
                 method = "lasso", tuneLength=10, trControl=ctrl)
d.lasso
varImp(d.lasso)
plot(d.lasso)
#PCA
set.seed(195) #SEED
d.pcr <- train(Income ~ ., data= uscensus.sub, method = "pcr", tuneLength=10, trControl=ctrl)
d.pcr
plot(d.pcr)
plot(varImp(d.pcr)) # plotting the important predictors
#PLS
set.seed(195) #SEED
d.pls <- train(Income ~ ., data= uscensus.sub, method = "pls", tuneLength=10, trControl=ctrl)
d.pls
plot(d.pls)
#regular regression
set.seed(195)

lm.train <- train(Income ~ ., data=uscensus.sub, method="lm",trControl=ctrl)
#smooth spline regression
#gamSpline in caret will expand each predictor with smooth spline searching for df value
set.seed(195)
gam.train <- train(Income ~ ., data=uscensus.sub, method="gamSpline",tuneLength=10,
                   trControl=ctrl)
#decision tree
set.seed(195)
rpart.train <- train(Income ~ ., data=uscensus.sub, method="rpart",tuneLength=10,
                     trControl=ctrl)
rpart.train
#bagging tree
set.seed(195)
bag.train <- train(Income ~ ., data=uscensus.sub, method="treebag",tuneLength=10, trControl=ctrl)
bag.train
#random forest
set.seed(195)
rf.train <- train(Income ~ ., data=uscensus.sub, method="rf",tuneLength=10,trControl=ctrl)
rf.train
#boosting
set.seed(195)
boost.train <- train(Income ~ ., data=uscensus.sub, method="gbm",tuneLength=10,trControl=ctrl)
boost.train
#lets gather the models
#first lets put all trained models in a list object
models<- list("lm" =lm.train, "Fwd"=d.tfwd, "Bwd" = d.tbwd,
              "Ridge" = d.ridge, "lasso" = lasso.train,
              "PCR" = d.pcr,
              "pls" = d.pls,
              "gam" = gam.train,
              "DT"=rpart.train, "RF" =rf.train,
              "BaggingTree"=bag.train,
              "BoostingTree" = boost.train)
d.resamples<- resamples(models)
summary(d.resamples)
#plot performances
bwplot(d.resamples, metric="RMSE")
bwplot(d.resamples, metric="Rsquared")
####################################################################
#Best Subset Selection - Running models on best predictors - Using just 7 variables
####################################################################
best_sub <- Full[c(18,37,11,8,21,24,4,14)]
names(best_sub)
best_sub <- na.omit(best_sub)
head(best_sub)
ctrl <- trainControl(method = "cv", number=10)
#Ridge regression
set.seed(195) #SEED
d.ridge <- train(Income ~ .,
                 preProcess=c("scale"),
                 data= best_sub, method = "ridge",
                 tuneLength=10, trControl=ctrl) #looks throu 10 values of lambda
d.ridge
plot(d.ridge)
varImp(d.ridge)
#Lasso Regression
set.seed(195) #SEED
d.lasso <- train(Income~ ., data= best_sub, method = "lasso", tuneLength=10, trControl=ctrl)
d.lasso
varImp(d.lasso)
plot(d.lasso)
#PCA
library(pls)
set.seed(195) #SEED
d.pcr <- train(Income ~ ., data= best_sub, method = "pcr", tuneLength=10, trControl=ctrl)
d.pcr
plot(d.pcr)
plot(varImp(d.pcr))
set.seed(195) #SEED
d.pls <- train(Income ~ ., data= best_sub, method = "pls", tuneLength=10, trControl=ctrl)
d.pls
plot(d.pls)
#regular regression
lm.train <- train(Income ~ ., data=best_sub, method="lm", trControl=ctrl)
#lasso
set.seed(195)
lasso.train <- train(Income ~ ., data=best_sub, method="lasso",tuneLength=10,trControl=ctrl)
#smooth spline regression
#gamSpline in caret will expand each predictor with smooth spline searching for df value
set.seed(195)
gam.train <- train(Income ~ ., data=best_sub, method="gamSpline",tuneLength=10,trControl=ctrl)
#decision tree
set.seed(195)
rpart.train <- train(Income ~ ., data=best_sub, method="rpart",tuneLength=10, trControl=ctrl)
rpart.train
#bagging tree
set.seed(195)
bag.train <- train(Income ~ ., data=best_sub, method="treebag",tuneLength=10,trControl=ctrl)
bag.train
#random forest
set.seed(195)
rf.train <- train(Income ~ ., data=best_sub, method="rf",tuneLength=10,trControl=ctrl)
rf.train
#boosting
set.seed(195)
boost.train <- train(Income ~ ., data=best_sub, method="gbm",tuneLength=10,trControl=ctrl)
boost.train
#lets gather the models
#first lets put all trained models in a list object
models<- list("lm" =lm.train, "Fwd"=d.tfwd, "Bwd" = d.tbwd,
              "Ridge" = d.ridge, "lasso" = lasso.train,
              "PCR" = d.pcr,
              "pls" = d.pls,
              "gam" = gam.train,
              "DT"=rpart.train, "RF" =rf.train,
              "BaggingTree"=bag.train,
              "BoostingTree" = boost.train)
d.resamples<- resamples(models)
summary(d.resamples)
#plot performances
trellis.strip <- function (b = 1, s = 1)
{
  s.b <- trellis.par.get("strip.background")
  s.b$col <- rep(b, length(s.b$col))
  trellis.par.set("strip.background", s.b)
  s.s <- trellis.par.get("strip.shingle")
  s.s$col <- rep(s, length(s.s$col))
  trellis.par.set("strip.shingle", s.s)
}
trellis.device(color=FALSE)
lset(theme=col.blackbg())
bwplot(d.resamples, metric="RMSE", colr=1)
bwplot(d.resamples, metric="Rsquared")
###################################################
#Decision trees
###################################################
names(uscensus.sub)
str(uscensus.sub)
#using rpart for regression tree
library(rpart) #faster than tree
library(tree) #has useful functions to use with rpart
par(mfrow=c(1,1))
#create tree
d.rtree <- rpart(Income ~., data=uscensus.sub)
#summarize full tree (no pruning)
d.rtree
#by default tree plot needs some adjustments and labeling
plot(d.rtree)
text(d.rtree, pretty=0)
#rather than using default lets use new library
library(rpart.plot)
#very readable defaults
rpart.plot(d.rtree)
#tree is too bushy and has too much variance (overfit)
printcp(d.rtree) #display cross validated error for each tree size
plotcp(d.rtree) #plot cv error
#select CP with lowest cross validated error
#manually this is 0.04477601
#we can grab this from the plotcp table automatically with
opt.cp <- d.rtree$cptable[which.min(d.rtree$cptable[,"xerror"]),"CP"]
#lets prune the tree
d.rtree.pruned <- prune(d.rtree, cp=opt.cp)
#lets review the final tree
rpart.plot(d.rtree.pruned)
##MSE training Error of pruned decision tree
yhat.rtree<- predict(d.rtree.pruned, uscensus.sub)
mean((uscensus.sub$Income - yhat.rtree)^2)
#Part C Unsupervised - PCA Code
###########################################
# PCA
############################################
#unsupervised learning
#removing income for unsupervised learning
uscensus.sub <-uscensus.sub[,-8]
names(uscensus.sub)
apply(uscensus.sub , 2, mean)
#scaling the data -best practise
pr.out =prcomp (uscensus.sub, scale =TRUE)
names(pr.out)
pr.out$rotation
dim(pr.out$x) #gives the dimensionality
biplot (pr.out , scale =10)
summary(pr.out)
pr.var =pr.out$sdev ^2
pr.var
pve=pr.var/sum(pr.var )
pve
plot(pve , xlab=" Principal Component ", ylab=" Proportion of
     Variance Explained ", ylim=c(0,1))
pve1 =100* pr.out$sdev ^2/ sum(pr.out$sdev ^2)
par(mfrow =c(1,2))
plot(pve1 , type ="o", ylab="PVE ", xlab=" Principal Component ",
     col =" blue")
plot(cumsum (pve1 ), type="o", ylab =" Cumulative PVE", xlab="
     Principal Component ", col =" brown3 ")
#Part D Unsupervised Clustering Code:
  country <- as.data.frame(read.csv("country.csv"))
str(country)
country <- country[,-c(1,2,3,5,6,13,16,17,19,20,32)]
country <- na.omit(country) # listwise deletion of missing
names(country)
country <- scale(country) # standardize variables
# Determine number of clusters
wss <- (nrow(country)-1)*sum(apply(country,2,var))
for (i in 2:15) wss[i] <- sum(kmeans(country,
                                     centers=i)$withinss)
plot(1:15, wss, type="b", xlab="Number of Clusters",
     ylab="Within groups sum of squares")
# K-Means Cluster Analysis
fit <- kmeans(country, 9) # 6 cluster solution

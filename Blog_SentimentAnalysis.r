setwd("C:\\Users\\user\\Desktop\\Blogs\\Text Analytics")
Tweets=read.csv("twitter-airline-sentiment.csv")
dim(Tweets)
names(Tweets)
###Analyze emotions
library(ggplot2)

a= ggplot(Tweets, aes(x=airline_sentiment))
  
a+geom_bar(aes(y=..count.., fill=airline_sentiment)) +
  scale_fill_brewer(palette="Dark2") + labs(x="Emotion Categories", y="")+
  ggtitle("Sentiment Comparison")+coord_flip()+
  scale_x_discrete(labels=c("Positive","Neutral","Negative"))+guides(fill=FALSE)

#Preparing for sentiment analysis by creating a corpus of tweets
library(tm)

#Need iconv to correct potential issues with emoji
Tweets$text <- iconv(Tweets$text, "latin1", "ASCII", sub = "")
Tweets$text <- gsub("http(s?)([^ ]*)", " ", Tweets$text, ignore.case = T) #Remove links
Tweets$text <- gsub("&amp", "and", Tweets$text) #remove html '&amp'

#Remove words starting with @
Tweets$text=gsub("@\\w+ *", "",Tweets$text)

#Remove words starting with #
Tweets$text=gsub("#\\w+ *", "",Tweets$text)
head(Tweets$text,10)


Tweet.corpus=Corpus(VectorSource(Tweets$text))
inspect(Tweet.corpus[1:10])

#Data (corpus/tweet) cleaning as part of data preparation
Tweet.corpus=tm_map(Tweet.corpus,tolower)
Tweet.corpus=tm_map(Tweet.corpus,stripWhitespace)
Tweet.corpus=tm_map(Tweet.corpus,removeNumbers)

#converting/encoding elements of character vectors to the native encoding or UTF-8 respectively,
Tweet.corpus=tm_map(Tweet.corpus, function(x) iconv(enc2utf8(x), sub = "byte"))
Tweet.corpus=tm_map(Tweet.corpus,removePunctuation)
more_stopwords=c(stopwords('english'),'http*',"@VirginAmerica","@NYTimes","flight",
                 "cancelled","thanks","AA","DM")
Tweet.corpus=tm_map(Tweet.corpus,removeWords,more_stopwords)

inspect(Tweet.corpus[1:10])

#Remove non-eglish words if any
Tweet.corpus=tm_map(Tweet.corpus,function(x) iconv(x,"latin1","ASCII",sub = ""))

Tweet.corpus=tm_map(Tweet.corpus,stemDocument)


#Building a term document matrix
Tweets.TDM=TermDocumentMatrix(Tweet.corpus)
inspect(Tweets.TDM[1:5,1:5])
Tweets.IMP=removeSparseTerms(Tweets.TDM,0.98)
inspect(Tweets.IMP[1:12,1:12])

wordFreq=data.frame(apply(Tweets.IMP,1,sum))
names(wordFreq)="Frequency"
wordFreq$Terms=row.names(wordFreq)
row.names(wordFreq)=NULL
wordFreq=wordFreq[,c(2,1)]
summary(wordFreq)
boxplot(wordFreq$Frequency)

a=ggplot(wordFreq,aes(Terms,Frequency, fill=Terms))
a+geom_bar(stat = "identity")+coord_flip()+ggtitle("Frequency Comparison")+guides(fill=FALSE)

findFreqTerms(Tweets.IMP,1000)
#High frequency i.e. very commonly used terms are now, hour,help,get

findAssocs(Tweets.IMP,"now",0.05)
#greater than 5 percent correlation of word with  with hour, delay, miss, hrs, wait

findAssocs(Tweets.IMP,"help",0.1)
#help has a minimum correlation of 10% with words pleas,can,need

library("RColorBrewer")
display.brewer.all()
display.brewer.pal(8,"Dark2")
pal=brewer.pal(8,"Dark2")

library(wordcloud)
#wordcloud1
wordcloud(Tweet.corpus,min.freq = 100,max.words = 10000,random.order = TRUE,
          colors=pal,vfont=c("script","plain"))
#wordcloud2
wordcloud(Tweet.corpus,min.freq = 250,max.words = 30000,random.order = TRUE,
          colors=pal,vfont=c("script","plain"))
#wordcloud3
wordcloud(Tweet.corpus,min.freq = 100,max.words = 40000,random.order = TRUE,
          colors=pal,vfont=c("script","plain"))

#Model Building
#converting the corpus to data.frame and embedding with sentiment
head(Tweets[,c(2,11)])
Tweets$text=data.frame(text = sapply(Tweet.corpus, as.character),
                       stringsAsFactors = FALSE)
Tweets=Tweets[,c(2,11)]

library(RTextTools)
library(e1071)

#Data Splitting
library(caret)
#Building model on the first 2000 tweets due to memory limitations
Tweets1=Tweets[1:2000,]
Index=createDataPartition(Tweets1$airline_sentiment,times = 1,p=0.7,list = FALSE)

Tweets1$type=NA
Tweets1$type[Index]="train"
Tweets1$type[-Index]="test"
table(Tweets1$type)


Tweets1$text <- gsub("http(s?)([^ ]*)", " ", Tweets1$text, ignore.case = T) #Remove links
Tweets1$text <- gsub("&amp", "and", Tweets1$text) #remove html '&amp'

#Remove words starting with @
Tweets1$text=gsub("@\\w+ *", "",Tweets1$text)

#Remove words starting with #
Tweets1$text=gsub("#\\w+ *", "",Tweets1$text)
head(Tweets1$text,10)
Tweet.corpus=Corpus(VectorSource(Tweets1$text))

#converting/encoding elements of character vectors to the native encoding or UTF-8 respectively,
Tweet.corpus=tm_map(Tweet.corpus, function(x) iconv(enc2utf8(x), sub = "byte"))
Tweet.corpus=tm_map(Tweet.corpus,removePunctuation)
more_stopwords=c(stopwords('english'),'http*',"@VirginAmerica","@NYTimes","flight",
                 "cancelled","thanks","AA","DM")
Tweet.corpus=tm_map(Tweet.corpus,removeWords,more_stopwords)

inspect(Tweet.corpus[1:10])

#Remove non-eglish words if any
Tweet.corpus=tm_map(Tweet.corpus,function(x) iconv(x,"latin1","ASCII",sub = ""))
Tweets1$text= data.frame(text = sapply(Tweet.corpus, as.character), stringsAsFactors = FALSE)

head(Tweets1$text,10)




#create dtm
DTM=create_matrix(Tweets1$text,language = "english",removeNumbers = TRUE,
                  removePunctuation = TRUE,
                  removeStopwords = TRUE,
                  removeSparseTerms = 0,
                  stripWhitespace = TRUE,
                  toLower = TRUE)
###removeSparseTerms
train.imp=removeSparseTerms(DTM, 0.97)

#convert to matrix datatype
mat=as.matrix(DTM)


#Build container to train models

container=create_container(mat,as.numeric(Tweets1$airline_sentiment),virgin = FALSE,
                           trainSize = as.numeric(row.names(Tweets1[Tweets1$type=="train",])),
                           testSize = as.numeric(row.names(Tweets1[Tweets1$type=="test",])))

models = train_models(container, algorithms=c("RF","TREE","SVM","MAXENT","BAGGING"))

#Test the model
results = classify_models(container, models)
class(results)
head(results)

CM_RF=table(Tweets1$airline_sentiment[as.numeric(row.names(Tweets1[Tweets1$type=="test",]))], results[,"FORESTS_LABEL"])
Acc_RF=sum(diag(CM_RF)/sum(CM_RF))

CM_Tree=table(Tweets1$airline_sentiment[as.numeric(row.names(Tweets1[Tweets1$type=="test",]))], results[,"TREE_LABEL"])
Acc_Tree=sum(diag(CM_Tree)/sum(CM_Tree))

CM_SVM=table(Tweets1$airline_sentiment[as.numeric(row.names(Tweets1[Tweets1$type=="test",]))], results[,"SVM_LABEL"])
Acc_SVM=sum(diag(CM_SVM)/sum(CM_SVM))

CM_MAXENT=table(Tweets1$airline_sentiment[as.numeric(row.names(Tweets1[Tweets1$type=="test",]))], results[,"MAXENTROPY_LABEL"])
Acc_MAXENT=sum(diag(CM_MAXENT)/sum(CM_MAXENT))


CM_BAGGING=table(Tweets1$airline_sentiment[as.numeric(row.names(Tweets1[Tweets1$type=="test",]))], results[,"BAGGING_LABEL"])
Acc_BAGGING=sum(diag(CM_BAGGING)/sum(CM_BAGGING))
Compare=data.frame(Models=c("RF","DecisionTree","SVM","MAXENT","BAGGING"),Accuracy=c(Acc_RF,Acc_Tree,Acc_SVM,Acc_MAXENT,Acc_BAGGING))
Compare

#####Ensemble
analytics = create_analytics(container, results)
summary(analytics)
Compare
head(analytics@document_summary)

#----------------------------------ENSEMBLE AGREEMENT----------------------------------

#Coverage: simply refers to the percentage of documents that meet the recall accuracy 
#threshold

analytics@ensemble_summary

#Four models should be chosen for ensemble to best combination of coverage(84%) & accuracy(74%)
#Individually SVM was giving the best result, but an ensemble can give an higher accuracy as can be seen from the ensemble summary
names(results)

#--------------------------------CROSS VALIDATION----------------------------
#N=4
#set.seed(2014)
#cross_validate(container,N,"MAXENT")
#cross_validate(container,N,"TREE")
#cross_validate(container,N,"SVM")
#cross_validate(container,N,"RF")
#cross_validate(container,N,"BAGGING")


#Choosing the models with 4 best accuracy results. Decision Tree loses out.
results1<-results[,c(1,5,7,9)]

#For each row
results1$majority=NA
for(i in 1:nrow(results1))
{
  #Getting the frequency distribution of the classifications 
  p<-data.frame(table(c(results1$FOREST_LABEL[i],results1$SVM_LABEL[i],
                        results1$MAXENTROPY_LABEL[i],results1$BAGGING_LABEL[i])))
  #Choosing the classification that occurs maximum
  #Putting this value into the new column "majority"
  
  results1$majority[i]<-paste(p$Var1[p$Freq==max(p$Freq)])
  rm(p)
}
results1$majority<-as.numeric(results1$majority)
table(results1$majority)

Compare=data.frame(Models=c("RF","DecisionTree","SVM","MAXENT","BAGGING","ENSEMBLE"),
                   Accuracy=c(Acc_RF,Acc_Tree,Acc_SVM,Acc_MAXENT,Acc_BAGGING,0.74))
Compare


Text Analytics - Mining the Abundance of Wealth underneath the vastness of Text

A blog is written in Medium with the above topic. Link to the same is 

https://medium.com/analytics-vidhya/text-analytics-mining-the-abundance-of-wealth-underneath-the-vastness-of-text-324149e9e449

The Foundations - Decoding & Quantifying Text:

While text is considered unstructured, there is an enormous amount of complexity and nuance contained in high-level human language, which makes text analytics extremely fertile ground for gleaning insights about people and what they’re thinking and feeling.

The challenge though is obvious. The data is unstructured as well as voluminous, and unless a method is found to quantify various aspects of it, the information derivation will always be slow, subjective and limited. The process by which text mining solves the problems of structure and scale is where data science comes in. The basic approach is to turn text into numbers, so that we can use machines to analyze the large volumes of documents and discover insights through mathematical algorithms.

Lets go through a real example of dealing with a dataset and the steps to convert the unstructured data to a structured one for being able to apply the algorithm of our choice depending on our goal. I downloaded a dataset about tweets of passengers about US airlines. The objective is to build a model that can predict the sentiment of a customer based on what he/she comments (without a human intervention to interpret). The data can be downloaded from data.world and link to it is Twitters About US Airline.

One of the first steps in the text mining process is to organize and structure the data in some fashion so it can be subjected to both qualitative and quantitative analysis. The foundation structure is to convert the text to either what is technically called as Term Document Matrix(TDM) or Document Term Matrix (DTM). Additionally some data visualization can be done to get some initial insights to what words are more frequently used, so on and so forth. As such many things can be done at this stage, but the major or essential must do’s are given below

i. Cleaning of the column of interest in the dataset which is the text that we want to derive information from. Cleaning essentially involves steps like removing white-space, links, emoticons, non- English words, numbers, punctuation, non-value added words, sparsely used words etc.

ii. Plotting a word cloud which gives a graphical representation of word frequency in the collection of tweets.

iii. Visualization to get initial insights of how the levels of the target variable is distributed

iv. Converting the text to a matrix format which can then be used for model building.

#### Programming Assignment. Getting & Cleaning Data ####################################################################################

#1. Create and load new files

# setwd("C:/Users/G13519/Documents/EB/Data Specialization/Getting and Cleaning Data")
library(data.table)
library(dplyr)
library(reshape2)

#Create folder, download and unzip file w/dataset
if(!file.exists("./prog")){dir.create("./prog")}
fileURL<-"http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL,destfile="./prog/run.zip")
unzip(zipfile="./prog/run.zip",exdir="./prog") #extraer en esa misma carpeta

#Load datasets, features, activities, subjects

test<-read.table("./prog/UCI HAR Dataset/test/X_test.txt")
train<-read.table("./prog/UCI HAR Dataset/train/X_train.txt")
ytest<-read.table("./prog/UCI HAR Dataset/test/y_test.txt")
ytrain<-read.table("./prog/UCI HAR Dataset/train/y_train.txt")
subjtest<-read.table("./prog/UCI HAR Dataset/test/subject_test.txt")
subjtrain<-read.table("./prog/UCI HAR Dataset/train/subject_train.txt")
act<-read.table("./prog/UCI HAR Dataset/activity_labels.txt")
feat<-read.table("./prog/UCI HAR Dataset/features.txt")
feat[,2]<-as.character(feat[,2])


#Only features' means and standard deviations

ms<- grep(".*mean.*|.*std.*", feat[,2])
ms.names <- feat[ms,2]
ms.names = gsub('-mean', 'Mean', ms.names)
ms.names = gsub('-std', 'Std', ms.names)
ms.names <- gsub('[-()]', '', ms.names)

test<-test[ms]  #extract only the desired data
train<-train[ms]

test<-cbind(subjtest,ytest,test)
train<-cbind(subjtrain,ytrain,train)


# Merge and set tidy names
DATA<- rbind(train, test)
colnames(DATA) <- c("subject", "activity", ms.names)

# activities & subjects into factors so we can melt the data
DATA$activity <- factor(DATA$activity, levels = act[,1], labels = act[,2])
DATA$subject <- as.factor(DATA$subject)

DATA.melted <- melt(DATA, id = c("subject", "activity"))
DATA.mean <- dcast(DATA.melted, subject + activity ~ variable, mean)

write.table(DATA.mean, "FINAL.txt", row.names = FALSE, quote = FALSE) #writes final tidy table w/means

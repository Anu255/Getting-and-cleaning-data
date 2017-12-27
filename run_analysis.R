setwd("Your working directory")
library(reshape2)
File <- "UCI HAR Dataset.zip"

## Download and unzip the dataset:
if (!file.exists(File)){
  URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(URL, File, method="curl")
}  
unzip(File) 
#load labels , features and extract only mean and standard dev data
activityLabel <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabel[,2] <- as.character(activityLabel[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])
WantedFeatures <- grep(".*mean.*|.*std.*", features[,2])
WantedFeatures.names <- features[WantedFeatures,2]
WantedFeatures.names = gsub('-mean', 'Mean', WantedFeatures.names)
WantedFeatures.names = gsub('-std', 'Std', WantedFeatures.names)
WantedFeatures.names <- gsub('[-()]', '', WantedFeatures.names)

#load datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[WantedFeatures]
TActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
TSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(TSubjects, TActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[WantedFeatures]
testAct <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSub <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSub, testAct, test)

# merge datasets and add labels
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", WantedFeatures.names)

# turn activities & subjects into factors
allData$activity <- factor(allData$activity, levels = activityLabel[,1], labels = activityLabel[,2])
allData$subject <- as.factor(allData$subject)

allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
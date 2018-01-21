library(reshape2)

file <- "getdata_dataset.zip"

## Download and extract data
if (!file.exists(file)){
        fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
        download.file(fileURL, file)
}  

if (!file.exists("UCI HAR Dataset")) { 
        unzip(file) 
}

# Load activity labels 
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])

# Load activity features
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract only the data with mean and std
featuresWanted <- grep(".*mean.*|.*std.*", features[,2])
featuresWanted.names <- features[featuresWanted,2]
featuresWanted.names <- gsub('-mean', 'Mean', featuresWanted.names)
featuresWanted.names <- gsub('-std', 'Std', featuresWanted.names)
featuresWanted.names <- gsub('[-()]', '', featuresWanted.names)

# Load needed datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresWanted]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresWanted]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# Merge two data sets to create one
Merged_data <- rbind(train, test)
# Adding labels
colnames(Merged_data) <- c("subject", "activity", featuresWanted.names)

# Turn activities & subjects into factors
Merged_data$activity <- factor(Merged_data$activity, levels = activityLabels[,1], labels = activityLabels[,2])
Merged_data$subject <- as.factor(Merged_data$subject)

Merged_data.melted <- melt(Merged_data, id = c("subject", "activity"))
Merged_data.mean <- dcast(Merged_data.melted, subject + activity ~ variable, mean)

# Create ouput.txt file
write.table(Merged_data.mean, "tidy_data_set.txt", row.names = FALSE, quote = FALSE)

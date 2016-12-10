# Get the data set if we don't already have it
dataName <- "UCI HAR Dataset"
zipName <- paste0(dataName, ".zip")
if (!file.exists(dataName)) {
    download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
                  destfile=zipName, method="curl")
    unzip(zipName)
}

# Step 1. Merges the training and the test sets to create one data set.
#
# The files look like read.fwf should be used to read them in. There are 561
# variables and each is 16 characters wide. But read.fwf was really slow and
# used too much memory. Found advice to use LaF library instead:
# https://www.r-bloggers.com/laf-ing-about-fixed-width-formats/
#
# First get the feature names from features.txt, we will use those to set the
# column names when we read in the data.
features <- read.table(file.path(dataName, "features.txt"), sep=" ",
                       col.names=c("number", "name"),
                       stringsAsFactors = FALSE)
featureNames <- features$name
numberOfFeatures <- length(featureNames)

library(LaF)
trainingSet <- laf_open_fwf(file.path(dataName, "train", "X_train.txt"),
                            column_widths=rep(16, numberOfFeatures), 
                            column_types=rep("numeric", numberOfFeatures),
                            column_names=featureNames)
testSet <- laf_open_fwf(file.path(dataName, "test", "X_test.txt"),
                        column_widths=rep(16, numberOfFeatures), 
                        column_types=rep("numeric", numberOfFeatures),
                        column_names=featureNames)

# Step 2. Extracts only the measurements on the mean and standard deviation for
# each measurement.
#
# Use grepl to find the feature names that contain "mean" or "std", possibly
# capitalized in different ways. Then delete all of the columns from
# trainingSet and testSet that don't match.
matchingNames <- grepl("mean|std", featureNames, ignore.case=TRUE)
trainingSet <- trainingSet[,matchingNames]
testSet <- testSet[,matchingNames]
# Now we can merge trainingSet and testSet together. rbind didn't work on the
# data we got from laf_open_fwf but it works now.
dataSet <- rbind(trainingSet, testSet)

# Step 3. Uses descriptive activity names to name the activities in the data
# set
#
# Use merge to apply the activity names to the "labels" files.
trainingLabels <- read.table(file.path(dataName, "train", "y_train.txt"),
                             col.names=c("activityid"), colClasses="integer")
testLabels <- read.table(file.path(dataName, "test", "y_test.txt"),
                         col.names=c("activityid"), colClasses="integer")
labels <- rbind(trainingLabels, testLabels)
activity <- read.table(file.path(dataName, "activity_labels.txt"), sep=" ",
                       col.names=c("activityid", "activityname"),
                       stringsAsFactors=FALSE)
activityMerged <- merge(labels, activity, by.x="activityid", by.y="activityid",
                        all=TRUE)
# Now make that a new column in "dataSet"
dataSet$activityname <- factor(activityMerged$activityname)

# Step 4. Appropriately labels the data set with descriptive variable names.
#
# The names from features.txt were used for variable names in step 1. But they
# mix lowercase and uppercase letters and have dots in them, so clean them
# up.
colnames(dataSet) <- tolower(gsub("\\.", "", colnames(dataSet)))

# Step 5. From the data set in step 4, creates a second, independent tidy data
# set with the average of each variable for each activity and each subject.
#
# Need to add a "subjectid" column to "dataSet"
trainingSubjects <- read.table(file.path(dataName, "train", "subject_train.txt"),
                               col.names=c("subjectid"), colClasses="integer")
testSubjects <- read.table(file.path(dataName, "test", "subject_test.txt"),
                           col.names=c("subjectid"), colClasses="integer")
subjects <- rbind(trainingSubjects, testSubjects)
dataSet$subjectid <- subjects$subjectid
# Now use group_by from dplyr to group by activity and subject, and summarize
# from dplyr to get the means
library(dplyr)
groupedData <- group_by(dataSet, activityname, subjectid)
newDataSet <- summarize_each(groupedData, c("mean"))
# Sort it so it looks nicer
newDataSet <- newDataSet[order(newDataSet$activityname, newDataSet$subjectid),]

# Done! Write the new tidy data set.
write.csv(newDataSet, file="new_tidy_data.csv")

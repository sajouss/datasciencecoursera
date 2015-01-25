# Script run_analysis.R
# Author: Steven Sajous
# This script merges the training and the test sets  for the
# Human Activity Recognition Using Smartphones Dataset to create one data set.
# It then extracts only the measurements on the mean and standard deviation for each measurement. 
# It renames the activites with more descriptive labels in the data set
# It then renames the columns with more human readable names 
# As a last step it outputs a tidy data set with the average of each variable for each activity and each subject.
# This is all done using the ools provided in teh "tidyr" library

library(tidyr)
library(data.table)

# For effenciency most of the data is read in using fread()
# but because of a bug in fread, had to use read.table and as.data.table for the bigger files
# First we merge all the rows of the similar data. Then we add the columns together
test_data_raw <- read.table("data/test/X_test.txt")
test_data_raw <- as.data.table(test_data_raw)

training_data_raw <- read.table("data/train/X_train.txt")
training_data_raw <- as.data.table(training_data_raw)


# Merge this data and delete the variables we will not use
# NOTE: All merges are done with test data first then training data second!!!
complete_raw_data <- rbind(test_data_raw,training_data_raw)

rm(test_data_raw)
rm(training_data_raw)


test_activities_raw <- fread("data/test/y_test.txt")
test_subjects_raw  <- fread("data/test/subject_test.txt")
training_activities_raw <- fread("data/train/y_train.txt")
training_subjects_raw  <- fread("data/train/subject_train.txt")

# Merge all activities
# Then merge all subjects
all_activities <- rbind(test_activities_raw,training_activities_raw)
all_subjects <- rbind(test_subjects_raw,training_subjects_raw)

# Remove all variables we will no longer use
rm(test_activities_raw)
rm(test_subjects_raw)
rm(training_activities_raw)
rm(training_subjects_raw)


# Let's bind all the data together. Putting subjects and activities as the first columns
# do.call() allows to us to do it all at once
# We end up with:
# Subject Activity DATA_COLUMNS
complete_raw_data <- do.call(cbind,list(all_subjects,all_activities,complete_raw_data))

# Get the features data and turn it into an array of headers. 
# Following the way the data is stored in our set we prepend
# "Subject" "Activity" to the column headers

features <- fread("data/features.txt")
headers <- features[,V2]
headers <- c("Subject","Activity",headers)

# Set the column names and delete the headers variable
setnames(complete_raw_data,headers)
rm(headers)

## We have names, now let's get the values we are interested in.
# We only keep columns with mean() and std() in their names
final_data <- complete_raw_data %>%
  select(Subject,Activity,contains("mean()"),contains("std()"))

# Again we no longer need the huge data set. We have what we need in final_data
rm(complete_raw_data)

## variable to hold the pretty values for Activity Types
## The orider matters since:
# 1 WALKING
# 2 WALKING_UPSTAIRS
# 3 WALKING_DOWNSTAIRS
# 4 SITTING
# 5 STANDING
# 6 LAYING
pretty_activity_labels <- c("WALKING","WALKING_UPSTAIRS","WALKING_DOWNSTAIRS","SITTING","STANDING","LAYING")

##Given an activity number this function returns it's pretty value
transformActivityLabels <-function(x) {
  pretty_activity_labels[x]
}


#Transform the numeric values of the activities labels into their pretty values 
final_data <- mutate(final_data,Activity=transformActivityLabels(Activity))

## Let's do some cleanup of the column names now
cnames <- names(final_data)

## Using Perl style regex we are converting the pattern:
## tSOMENAME-mean()-X to avgSOMENAMETimeXAxis
## fSOMENAME-mean()-X to avgSOMENAMEFreqencyXAxis
## If there is no trailing -X we ommit the Axis part
## We do the same for -std() and prepend std to the name so we end up with
## stdSOMENAMEFrequencyXAxis for example.

headers <- cnames %>%
  gsub(pattern="^t(\\w*)-mean\\(\\)-(\\w*)",replacement="avg\\1Time\\2Axis", perl=TRUE) %>%
  gsub(pattern="^f(\\w*)-mean\\(\\)-(\\w*)",replacement="avg\\1Frequency\\2Axis", perl=TRUE) %>%
  gsub(pattern="^t(\\w*)-mean\\(\\)",replacement="avg\\1Time\\2", perl=TRUE) %>%
  gsub(pattern="^f(\\w*)-mean\\(\\)",replacement="avg\\1Frequency\\2", perl=TRUE) %>%
  gsub(pattern="^t(\\w*)-std\\(\\)-(\\w*)",replacement="std\\1Time\\2Axis", perl=TRUE) %>%
  gsub(pattern="^f(\\w*)-std\\(\\)-(\\w*)",replacement="std\\1Frequency\\2Axis", perl=TRUE) %>%
  gsub(pattern="^t(\\w*)-std\\(\\)",replacement="std\\1Time\\2", perl=TRUE) %>%
  gsub(pattern="^f(\\w*)-std\\(\\)",replacement="std\\1Frequency\\2", perl=TRUE) 

#Rename the columns with our pretty names...
setnames(final_data,headers)  

# Group the data by Subject and Activity using the group_by
# Use summarise_each function of tidyr, we apply mean to all the numeric columns all at once
averages <-
  final_data %>%
  group_by(Subject,Activity) %>%
  summarise_each(funs(mean)) %>%
  arrange(Subject,Activity)

# Uncomment the following line if writing the averages data to a file
# write.table(averages,"averages.txt",row.name=FALSE)


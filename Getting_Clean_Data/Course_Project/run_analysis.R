library(tidyr)

##because of a bug in fread, had to use read.table and as.data.table for the bigger files
test_data_raw <- read.table("X_test.txt")
test_data_raw <- as.data.table(test_data_raw)

training_data_raw <- read.table("X_train.txt")
training_data_raw <- as.data.table(training_data_raw)

##combine and delete the variables we will not use
complete_raw_data <- rbind(test_data_raw,training_data_raw)

rm(test_data_raw)
rm(training_data_raw)


test_activities_raw <- fread("y_test.txt")
test_subjects_raw  <- fread("subject_test.txt")
training_activities_raw <- fread("y_train.txt")
training_subjects_raw  <- fread("subject_train.txt")

## Now we combine the activities together
all_activities <- rbind(test_activities_raw,training_activities_raw)
all_subjects <- rbind(test_subjects_raw,training_subjects_raw)

rm(test_activities_raw)
rm(test_subjects_raw)
rm(training_activities_raw)
rm(training_subjects_raw)


##Let's bind all the data together. Putting subjects and activities as the first columns
complete_raw_data <- do.call(cbind,list(all_subjects,all_activities,complete_raw_data))

### Get the features data and turn it into an array of headers. With Subject and Activity
## as the first columns
features <- fread("features.txt")
headers <- features[,V2]
headers <- c("Subject","Activity",headers)

setnames(complete_raw_data,headers)
rm(headers)

## We have names, now let's get the values we are interested in.
# We only keep columns with mean() and std() in their names
final_data <- complete_raw_data %>%
  select(Subject,Activity,contains("mean()"),contains("std()"))

rm(complete_raw_data)

## variable to hold the pretty values for Activity Types
## The orider matters since:
## 1 -> "Walking"
## 2 -> "Walking Upstairs"
## etc.. based on the activity_labels.txt file
pretty_activity_labels <- c("Walking","Walking Upstairs","Walking Downstairs","Sitting","Standing","Laying")

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

#Rename the columns with our pretty names
setnames(final_data,headers)  
 
#Using the group_by and summarise_each function of tidyr, we apply mean to all the numeric columns
averages <-
  final_data %>%
  group_by(Subject,Activity) %>%
  summarise_each(funs(mean)) %>%
  arrange(Subject,Activity)

write.table(averages,"averages.txt",row.name=FALSE)


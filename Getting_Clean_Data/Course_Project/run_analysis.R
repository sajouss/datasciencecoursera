#raw_test_data %>%
#  select(Activity,contains("mean()")) ##& contains("std")) %>%
#print

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


complete_raw_data <- do.call(cbind,list(all_subjects,all_activities,complete_raw_data))

### features
features <- fread("features.txt")
headers <- features[,V2]
headers <- c("Subject","Activity",headers)

setnames(complete_raw_data,headers)

## We have names, now let's get the values we are interested in
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

result3 <-
  final_data %>%
  group_by(Subject,Activity) %>%
  summarise_each(funs(mean)) %>%
  arrange(Subject,Activity)



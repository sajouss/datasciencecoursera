Creates a tidy data set from data of the Human Activity Recognition Using Smartphones Data Set
* Save the run_analysis.R to a directory of your choice
* Donwload the data from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
* Unzip it in the same directory as the script and rename the directory to data
* Launch RStudio
* Install the tidyr package by running library(tidyr) in the RStudio console
* Using setwd(''), move to the directory of your script
* Open the script
* Edit the script and uncomment the last line if you would like to save the tidy data set into a file named averages.txt and save it
* In R Studio run: source('run_analysis.R')
* The variable final_data holds the data set with all the tidy data that was constructed


The data set created by the script only holds the columns with the Subject number, Activity Name and all the columns 
with -mean() and -std() in their names. Those are the mean and standard deviations for each measurements. For better readability 
the measurement column names were renamed by applying regular expressions to the existing names to transform
tBodyAcc-mean()-Y into avgBodyAccTimeYAxis and tBodyGyro-std()-X into stdBodyGyroTimeXAxis for example.

"final_data" contains all the mean and standard deviations of each measurement for all subject and activity.
"averages" contains all the averages for all the values for the 30 subjects and 6 activities for a total of 180 rows


---
title: "README.md"
author: "Ali Hassanzadeh, MD"
date: "2023-06-26"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## Activity Tidy Data

First, we load our data to R; Unzip the Samsung activity data that you have downloaded from COURSERA and move the zipped folder *UCI HAR Dataset* to your main directory, this will take a minute, be patient!:

```{loading data}
x_test <- read.table("UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("UCI HAR Dataset/test/y_test.txt")
x_train <- read.table("UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("UCI HAR Dataset/train/y_train.txt")
act_labs <- read.table("UCI HAR Dataset/activity_labels.txt")
feats <- read.table("UCI HAR Dataset/features.txt")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
```

## Row binding the test and train data!

As you have reviewed the data, We have three parts in our data: 1) X data: consisting of lots of numbers from the sensors along the time of the observation, 2) Y data: consisting of activity labels from 1 to 6 (the labels are in the `act_labs`, and 3) subjects id for 30 people. first to unite the train and test data for each of items above, we use `rbind` function.

```{binding the rows of desired variables}
x_df <- rbind(x_test, x_train)
y_df <- rbind(y_test, y_train)
subjects <- rbind(subject_test, subject_train)
```

## Labeling Variables

For naming each row, We will use `names` function and the names of each variable will be assigned to it. for `x_df` the names are in the `feats` dataframe. so we will use it:

```{naming variables}
names(x_df) <- feats$V2
names(y_df) <- "act_cat"
names(subjects) <- "subj"
```

## Extracting Mean and SD columns from `x_df`

I wrote a loop function to loop over the `x_df` columns and use `grepl` function to search the mean or std regular expression in the column names and if that's `FALSE` for a column, it will exclude it. Unfortunately you need to run this loop function 6-7 times (I don't know how to debug it), each time it omits a number of columns until it reaches 79. I'm desperately appreciate any comments to fix this bug, although it works!

```{omitting the non-related columns from x_df}
for (i in 1:ncol(x_df)) {
        if (!grepl(pattern = "mean|std", names(x_df))[i]) {
                x_df <- x_df[,-i]
        }
}
grepl(pattern = "mean|std", names(x_df))
```

## Labeling `act_cat`

We'll assign each level in the activity categories its own name. the names are in `act_labs` and we will use loop in loop functions to assign them properly! I love loop functions!!!

```{labeling ACTIVITY!}         
for (i in 1:nrow(y_df)) {
        for (j in 1:6) {
                if (y_df$act_cat[i]==act_labs[j,1]) {
                        y_df$act_cat[i] <- act_labs[j,2]
                }
        }
}
summary(as.factor(y_df$act_cat))
```

## Merging dataset

So after labelings and primary cleaning, it is time to unite our datasets in to one major dataset, including all of the data (IDs, activities, and sensors' results); Let's call it `tot_df` standing for *total dataframe*:

```{Our primary united dataset}
tot_df <- cbind(subjects,x_df, y_df)
```

## Naming variables appropriately

As variable names have their standards to ease the precise analysis, let's take alook at our variables' names:

``` {Take a look at the names!}
names(tot_df)
```

It is better to omit the parentheses and convert to lowercase, to standardize a little bit more! we will use `tolower` and `gsub` finctions for this purpose:

```{let's make some improvements!}
names(tot_df) <- tolower(gsub(pattern = "\\()", replacement = "", x = names(tot_df)))
```

Now if you run the `names(tot_df)` function, you will see the changes.

## Averages by subjects and activities

As the assignment asked, we need to calculate the averages for each numeric variable, grouped by subjects and activity levels, It is a bit like generating `xtabs` but we have 79 variables not one! so I used `aggregate` function and defined the `FUN` to be mean! Finally, I sorted the dataframe by subjects and activity levels! 

```
summary_df <- aggregate(. ~ subj + act_cat, data = tot_df, FUN = mean, na.rm = TRUE)
library(dplyr)
summary_df <- arrange(.data = summary_df, subj, act_cat)
```

So let's save this dataframe to a text file at your directory:

```{Save}
write.table(summary_df, file = "project.txt", quote = FALSE, row.names = FALSE)
```
THANK YOU! At the following you can see my codebook:

 "subj" : subject ID for 30 subjects.
 
 Accelerometer and gyroscope data (mean and std) for each of them:
tBodyAcc-XYZ
tGravityAcc-XYZ
tBodyAccJerk-XYZ
tBodyGyro-XYZ
tBodyGyroJerk-XYZ
tBodyAccMag
tGravityAccMag
tBodyAccJerkMag
tBodyGyroMag
tBodyGyroJerkMag
fBodyAcc-XYZ
fBodyAccJerk-XYZ
fBodyGyro-XYZ
fBodyAccMag
fBodyAccJerkMag
fBodyGyroMag
fBodyGyroJerkMag

act_cat: activity category consisting of:
1 WALKING
2 WALKING_UPSTAIRS
3 WALKING_DOWNSTAIRS
4 SITTING
5 STANDING
6 LAYING


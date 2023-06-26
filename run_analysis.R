# Reading Data
x_test <- read.table("UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("UCI HAR Dataset/test/y_test.txt")
x_train <- read.table("UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("UCI HAR Dataset/train/y_train.txt")
act_labs <- read.table("UCI HAR Dataset/activity_labels.txt")
feats <- read.table("UCI HAR Dataset/features.txt")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")


#Merging X and Y
x_df <- rbind(x_test, x_train)
y_df <- rbind(y_test, y_train)
subjects <- rbind(subject_test, subject_train)


#Labeling variables
names(x_df) <- feats$V2
names(y_df) <- "act_cat"
names(subjects) <- "subj"

#Extracting mean and SD variables from X data set

for (i in 1:ncol(x_df)) {
        if (!grepl(pattern = "mean|std", names(x_df))[i]) {
                x_df <- x_df[,-i]
        }
}       #Unfortunately you need to run this loop function 6-7 times (I don't know how to debug it), each time it omits a number of columns until it reaches 79

grepl(pattern = "mean|std", names(x_df))        #79 TRUEs


#Labeling Activities
for (i in 1:nrow(y_df)) {
        for (j in 1:6) {
                if (y_df$act_cat[i]==act_labs[j,1]) {
                        y_df$act_cat[i] <- act_labs[j,2]
                }
        }
}
summary(as.factor(y_df$act_cat))

#Merging dataset
tot_df <- cbind(subjects,x_df, y_df)


#Naming variables appropriately
names(tot_df)   #It is better to omit the parentheses and convert to lowercase
names(tot_df) <- tolower(gsub(pattern = "\\()", replacement = "", x = names(tot_df)))


#Averages

summary_df <- aggregate(. ~ subj + act_cat, data = tot_df, FUN = mean, na.rm = TRUE)
summary_df <- arrange(.data = summary_df, subj, act_cat)

write.table(summary_df, file = "project.txt", quote = FALSE, row.names = FALSE)

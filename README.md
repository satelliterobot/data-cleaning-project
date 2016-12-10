# data-cleaning-project
Getting and Cleaning Data Course Project

This repository contains a script that makes a smaller version of the
[Human Activity Recognition Using Smartphones Data Set](https://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones).

You should have the LaF and dplyr libraries installed before using this.

To run the script, start R and type  
source("run_analysis.R")

The script will download the dataset, and create a new file named
"new_tidy_data.txt".

There are detailed comments in the R script, but in summary what the script does is

1. reads the variable names from features.txt
2. uses the LaF library to read in the training and test data sets
3. uses grep to keep just the variables whose name contain "mean" or "std"
4. uses rbind to make the training and test data into a single data set
5. uses left_join from the dplyr library to turn the activity codes in y_train.txt and y_test.txt into activity names
6. uses tolower and gsub to tidy the variable names
7. uses group_by and summarize_each from the dplyr library to group the data by activity and subject
8. finally, uses write.table to write out the new data set.

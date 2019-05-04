# Cloud-Detection

The goal of this project is the exploration and modeling of cloud detection in the polar regions based on radiance recorded automatically by the MISR sensor abroad the NASA satellite Terra. We will build a classification model to distinguish the presence of cloud from the absence of clouds in the images using given features. 

## Table of Contents
- [Getting Started](#gettingstarted)
- [Plotting Images](#plottingimages)
- [Splitting the Data](#splittingthedata)
- [CVgeneric Function](#cvgenericfunction)
- [Classifiers](#classifiers)
- [ROC Curves](#roccurves)


## Getting Started

The instructions below will help you recreate a copy of the project and running on your local machine for testing purposes. 

### Installation

To recreate this project, you would need to use Rscript or RStudio. Once you have finished installing the programs, you are ready to start. The main packages used in this project are listed below:

```
library(ggplot2)
library(readr)
library(caret)
library(anchors)
library(plotROC)
library(xtable)
library(kableExtra)
```
Install these packages before calling on library using:

```
install.package("package_name")
```
---

## Plotting Images

To produce the Image1, Image2, and Image3, we used ggplot to map the x and y coordinates while setting the color to the expert labels within each data frame. Below is the code to reproduce Image1:

```
ggplot(data = image1, aes(x = x, y = y, color = factor(label))) + geom_point() + xlab("x coordinate") + ylab("y coordinate") + ggtitle("Image 1") + scale_color_manual(values=c("darkblue", "lightblue", "white")) + labs(col="Expert Label")
```
We also performed EDA on our data set to see the relationship between the expert labels and the individual features. See [a relative link](https://github.com/irenej98/Cloud-Detection/blob/master/Stat%20154%20Project%202-%20Cloud%20Data%20Code.Rmd) for more on how we performed EDA.

After EDA, we chose three features that had the most correlation to our data: SD, AN, and NDAI.

---

## Splitting the Data
In this paper we used two methods for splitting the data. 

### Method 1: Random
We first deleted all the unlabeled points in image1, image2, and image3, then proceeded to set 80% of the data as our training set and 20% as our test set. From the training set, we used crossvalidation and created four folds. While training for our model, we will use one fold as a validation set and the rest as training sets.

### Method 2: Geographical Blocking
We first separated the image into 9 blocks based on the x and y coordinate, then proceeded to remove all the unlabeled points from each block. We set two blocks as the test set, choosing the max and min number of observations for each.

---

## CVgeneric Function
We created two CVgeneric function, one for each method of split. The CVgeneric function takes in two functions, a split function and a predictions function. 

### Split Function
The split function helps split the data using methods 1 and 2 and outputs a list of all the train sets and test sets. 

```
method1_split <- function(data, fold){
...
  return(list(folds, test_im))
}
```
This function takes in two parameters, a data set and the number of fold you want to create for each of the data sets. Usually for data parameter, you would imput image1, image2, or image3.

### Prediction Function
The prediction functions calls on the split function and trains the folds on four different classifiers, then outputs a list of true labels, predicted labels, the accuracies for each fold and the test accuracies.

```
method1_predictions <- function(data, model, features, labels, folds){
  data_point = method1_split(data, folds)
...
  return(list(y_true, y_pred, pred, accuracy_test))
}
```
This function takes in five parameters, a data set, the model you want to use (i.e. "glm", "lda", "qda", and "knn"). The features for this model should be an array of features that you want to train your data on, for example:
```
c("SD", "AN", "NDAI")
``` 
The labels is a string and since logistic regression requires a binary classification, you need to set the labels column of your data as a factor:
```
"factor(label)"
```
The folds parameter is the number of folds that you want to create for the data set.

### Generic Function
The last function is the CV generic function which is similar to the prediction function, but takes in an extra parameter of loss.

```
CVgeneric1 <- function(data, model, features, labels, folds, loss){
...
}
```
The loss function that we created for our models is mean squared error, but you can input any loss function into the CVgeneric function to get a loss on the predicted and true labels. The loss function takes in an array of true labels and an array of predicted labels. The MSE function is shown below as an example:

```
MSE <- function(y_true, y_pred){
  return(mean((as.numeric(y_true) - as.numeric(y_pred))^2))
}
```

---

## Classifiers
To train our model, we used four different classifiers to train our model: Logistic regression, LDA, QDA, and k-Nearest Neighbors. After training the models, we realised that kNN was the most accurate classifier, especially for the first method of splitting.

---

## ROC Curves
The ROC Curves shows the trade off between true positives and false positives. It plots many different cut-off values for decision rules, and their corresponding true positive and false positive rates. The goal is to choose a cutoff value that maximizes the true positive rate without sacrificing an increase in false positive rate. 







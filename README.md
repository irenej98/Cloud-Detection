# Cloud-Detection

The goal of this project is the exploration and modeling of cloud detection in the polar regions based on radiance recorded automatically by the MISR sensor abroad the NASA satellite Terra. We will build a classification model to distinguish the presence of cloud from the absence of clouds in the images using given features. 

## Table of Contents
- [Getting Started](#gettingstarted)
- [Plotting Images](#plottingimages)
- [Creating Tables](#creatingtables)
- [ROC curves](#roccurves)


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
``


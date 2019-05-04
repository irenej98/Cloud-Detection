#CVgeneric Function for two types of split

#Method 1 Split: Random

method1_split <- function(data, fold){
  #Take out all the unlabeled points
  new_im <- data[data$label != 0, ]
  new_im <- replace.value(new_im, "label", -1, 0)
  #80% of the sample size
  im_sample <- floor(0.8 * nrow(new_im))
  
  set.seed(2)
  train_ind <- sample(seq_len(nrow(new_im)), size = im_sample)
  
  #Split the data into 80% train and 20% test
  train_im <- new_im[train_ind, ]
  test_im <- new_im[-train_ind, ]
  
  #You then split the train data into 4 folds by random sampling
  set.seed(3)
  rand <- sample(nrow(train_im))
  
  k_row <- c()
  for(i in 1:fold){
    a <- rand[rand %% fold + 1 == i]
    k_row[[i]] <- a
  }
  
  folds <- c()
  for(i in 1:fold){
    b <- train_im[k_row[[i]], ]
    folds[[i]] <- b
  }
  
  return(list(folds, test_im))
}


#Method 2 Split: Geographical Blocking

method2_split <- function(data) {
  
  # create 9 blocks within the image
  i1 <- data[order(data$x), ]
  i1$g_x <- as.numeric(cut(i1$x, 3))
  i1 <- i1[order(data$y), ]
  i1$g_y <- as.numeric(cut(i1$y, 3))
  
  block1 <- i1[i1$g_x == 1 & i1$g_y == 1, ]
  block2 <- i1[i1$g_x == 1 & i1$g_y == 2, ]
  block3 <- i1[i1$g_x == 1 & i1$g_y == 3, ]
  block4 <- i1[i1$g_x == 2 & i1$g_y == 1, ]
  block5 <- i1[i1$g_x == 2 & i1$g_y == 2, ]
  block6 <- i1[i1$g_x == 2 & i1$g_y == 3, ]
  block7 <- i1[i1$g_x == 3 & i1$g_y == 1, ]
  block8 <- i1[i1$g_x == 3 & i1$g_y == 2, ]
  block9 <- i1[i1$g_x == 3 & i1$g_y == 3, ]
  
  blocks = list(block1, block2, block3, block4, block5, block6, block7, block8, block9)
  
  # take out unlabeled points and replace all -1 with 0
  new_blocks <- c()
  for(i in 1:length(blocks)) {
    new_im <- blocks[[i]][blocks[[i]]$label != 0, ]
    new_im <- replace.value(new_im, 'label', -1, 0)
    new_blocks[[i]] <- new_im
  }
  
  # find test blocks as the 2 blocks with min and max number of observations
  rows <- c()
  for(i in 1:length(new_blocks)){
    rows[[i]] = nrow(new_blocks[[i]])
  }
  test1 <- new_blocks[[which.max(rows)]]
  test2 <- new_blocks[[which.min(rows)]]
  
  # the train blocks are the 7 blocks that aren't the test blocks
  train <- new_blocks[- c(which.max(rows), which.min(rows))]
  
  return(list(train, test1, test2))
}



#loss function: MSE
MSE <- function(y_true, y_pred){
  return(mean((as.numeric(y_true) - as.numeric(y_pred))^2))
}


#Prediction Function to return the true labels, the predicted labels and the accuracies of each fold and test sets

# Method 1 Predictions

method1_predictions <- function(data, model, features, labels, folds){
  #Here you split the data frame into the total number of folds
  data_point = method1_split(data, folds)
  test = data_point[[2]]
  train = data_point[[1]]
  a = labels
  b = features
  formula_train = as.formula(paste(a, paste(b, collapse=" + "), sep=" ~ "))
  
  #You use one of the folds as a validation and the other k-1 folds as the training set. You then run this process k times
  k = 1
  pred = c()
  while(k<(folds+1)){
    b = k
    val = train[[b]]
    y_true = val$label
    training = train[-b]
    
    models = c()
    for(i in 1:(folds-1)){
      if(model == "glm"){
        mod_fit = mod_fit = train(formula_train, data = training[[i]], method = model, family = "binomial")
      } else{
        mod_fit = train(formula_train, data = training[[i]], method = model)
      }
      models[[i]] = mod_fit
    }
    y_pred = predict(models[[1]], newdata = val)
    accuracy = sum(y_pred == y_true)/length(y_true)
    pred = c(pred, accuracy)
    k = k + 1
  }
  pred_test = predict(models[[1]], newdata = test)
  test_labels = test$label
  accuracy_test = sum(pred_test == test_labels)/length(test_labels)
  return(list(y_true, y_pred, pred, accuracy_test))
}


#Method 2 Prediction

method2_predictions <- function(data, model, features, labels, folds) {
  # split the data frame into the total number of folds
  data_point <- method2_split(data)
  test1 <- data_point[[2]]
  test2 <- data_point[[3]]
  train <- data_point[[1]]
  a <- labels
  b <- features
  formula_train <- as.formula(paste(a, paste(b, collapse = " + "), sep = " ~ "))
  
  k <- 1
  pred <- c()
  while(k < (folds + 1)){
    b <- k
    val = train[[b]]
    y_true = val$label
    training = train[-b]
    
    models = c()
    for(i in 1:(folds-1)){
      if(model == "glm"){
        mod_fit = mod_fit = train(formula_train, data = training[[i]], method = model, family = "binomial")
      } else{
        mod_fit = train(formula_train, data = training[[i]], method = model)
      }
      models[[i]] = mod_fit
    }
    y_pred = predict(models[[1]], newdata = val)
    accuracy = sum(y_pred == y_true)/length(y_true)
    pred = c(pred, accuracy)
    k = k + 1
  }
  pred_test1 = predict(models[[4]], newdata = test1)
  pred_test2 = predict(models[[4]], newdata = test2)
  test1_labels = test1$label
  test2_labels = test2$label
  accuracy_test1 = sum(pred_test1 == test1_labels)/length(test1_labels)
  accuracy_test2 = sum(pred_test2 == test2_labels)/length(test2_labels)
  return(list(y_true, y_pred, pred, accuracy_test1, accuracy_test2))
}



# Use either CVgeneric1 or CVgeneric2 based on split method
CVgeneric1 <- function(data, model, features, labels, folds, loss){
  list_pred = method1_predictions(data, model, features, labels, folds)
  Total_loss = loss(list_pred[[1]], list_pred[[2]])
  return(list(list_pred[[3]], list_pred[[4]], Total_loss))
}

CVgeneric2 <- function(data, model, features, labels, folds, loss){
  list_pred = method2_predictions(data, model, features, labels, folds)
  Total_loss = loss(list_pred[[1]], list_pred[[2]])
  return(list(list_pred[[3]], list_pred[[4]], list_pred[[5]], Total_loss))
}
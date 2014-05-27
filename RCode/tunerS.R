library(e1071)
library(rpart)

train <- read.csv("digits_resized_reduced_400.csv", sep= " ", header=FALSE)

labels <- factor(c(train[,1]))
train <- train[,-1]
train <- cbind(labels, train)

tunec <- tune.control(sampling = "cross", cross = 10)

tune <- tune.svm(labels~., data = train, kernel="polynomial",
            gamma = 2^(-1:1), cost = 2^(2:4), degree = c(1:9),
            tunecontrol = tunec)
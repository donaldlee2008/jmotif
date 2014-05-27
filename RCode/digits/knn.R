library(FNN)

train <- read.csv("train_cropped_resized_normalized.csv", sep=" ", header=FALSE)
test <- read.csv("test_cropped_resized_normalized.csv", sep=" ", header=FALSE)

labels <- train[,1]
train <- train[,-1]

knnm <- knn(train, test, labels, k = 1)

write(results, file="knn_benchmark.csv", ncolumns=1) 

labels <- train[,1]
train <- train[,-1]
train <- cbind(labels, train)
names(test) <- names(train)[2:785]

#res <- kknn(labels~., train, test, distance = 1,m kernel = "triangular")
res <- kknn(labels~., train, test, k = 10, distance = 2.82, kernel = "optimal")


library(e1071)
library(rpart)
data(Glass, package="mlbench")
index <- 1:nrow(Glass)
testindex <- sample(index, trunc(length(index)/3))
testset <- Glass[testindex,]
trainset <- Glass[-testindex,]

svm.model <- tune.svm(Type~., data = trainset, kernel="polynomial", degree=c(c(1:2), gamma = 0.1, cost = 10))
print(summary(svm.model))

svm(Type ~ ., data = trainset, cost = 100, gamma = 1)
svm.pred <- predict(svm.model, testset[,-10])
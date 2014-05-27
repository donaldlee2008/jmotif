# after cropping in java next macro applied:
# run("Canvas Size...", "width=28 height=28 position=Center zero");
# run("8-bit");
# run("Despeckle");
#
#
#run("Canvas Size...", "width=28 height=28 position=Center zero");
#run("8-bit");
#run("Skeletonize (2D/3D)");
#
#
library(FNN)

train <- read.csv("../data/digits/train.csv", sep=" ", header=F)

test <- train[30000:42000,]
train <- train[1:30000,]

labels <- train[,1]
train <- train[,-1]

results <- (0:9)[knn(train, test, labels, k = 10, algorithm="cover_tree")]

write(results, file="knn_benchmark_centered.csv", ncolumns=1) 

#ibrary(kknn)
#train <- read.csv("data/digits/train_centered.csv", sep=" ", header=FALSE)
#test <- read.csv("data/digits/test_cenetered.csv", sep=" ", header=FALSE)
#labels <- train[,1]
#train <- train[,-1]
#train <- cbind(labels, train)
#names(test) <- names(train)[2:785]
#res <- kknn(labels~., train, test, distance = 1,m kernel = "triangular")
#res <- kknn(labels~., train, test, k = 10, distance = 2.82, kernel = "optimal")



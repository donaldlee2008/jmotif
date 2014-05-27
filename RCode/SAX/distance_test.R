##
## This code provides example of SAX & lower bounding distance computation
##
## last edited 02-03-2009, seninp@gmail.com
##

## source the code
#
source("PAA_SAX.R")

## test data definitions
#
ts1.name <- "../data/timeseries01.csv"
ts2.name <- "../data/timeseries02.csv"

## load the data
#
ts1.data <- as.matrix(read.csv(file=ts1.name, header=FALSE, sep = ",", quote="\"", dec=".", fill = TRUE, comment.char=""))
ts2.data <- as.matrix(read.csv(file=ts2.name, header=FALSE, sep = ",", quote="\"", dec=".", fill = TRUE, comment.char=""))
ts1.data <- reshape(ts1.data, 1, nrow(ts1.data))
ts2.data <- reshape(ts2.data, 1, nrow(ts2.data))

## get the series dimensions
ts.length <- max(dim(ts2.data)[2], dim(ts1.data)[2])
ts.max <- max(max(ts2.data), max(ts1.data))

## init graphical device
par(mfrow=c(2,2))

## plot the original data
#
plot(NULL, xlim=c(0,ts.length), ylim=c(0,ts.max), main="Devtime, trajectory1 & trajectory2", xlab="ticks", ylab="Hrs")
lines(ts1.data[1,], lwd=2, col="mediumspringgreen")
points(ts1.data[1,], pch=3, cex=1, col="mediumspringgreen")
lines(ts2.data[1,], lwd=2, col="royalblue")
points(ts2.data[1,], pch=18, cex=1.5, lwd=2, col="royalblue")

## get normalized sequences
#
ts1.norm <- znorm(ts1.data)
ts2.norm <- znorm(ts2.data)

## get the distance
#
dist <- as.character(round(euclidean(ts1.norm[1,],ts2.norm[1,]), digits=4))
title<- substitute( paste("Z normalized data, ", Delta, "=", dist ), list (dist=dist))

## plot the normalized series
#
plot(NULL, xlim=c(0,14), ylim=c(-2,2), main=title, xlab="ticks", ylab='')
lines(ts1.norm[1,], lwd=2, col="mediumspringgreen")
points(ts1.norm[1,], pch=3, cex=1, col="mediumspringgreen")
lines(ts2.norm[1,], lwd=2, col="royalblue")
points(ts2.norm[1,], pch=18, cex=1.5, lwd=2, col="royalblue")
for(i in 1:14){segments(i, ts1.norm[1,i], i, ts2.norm[1,i], lty=2, col="darkorange3")}

## plot the string conversion and distance
## fixing the alphabet size = 5
#
aSize   <- 5
paaSize <- 10

## convert to PAA 9
#
ts1.paa <- paa(ts1.norm, paaSize);
ts2.paa <- paa(ts2.norm, paaSize);

## get the distance
#
dist <- as.character(round(euclidean(ts1.paa[1,],ts2.paa[1,]), digits=4))
title<- substitute( paste("PAA to 10 points, ", Delta, "=", dist ), list (dist=dist))

plot(NULL, xlim=c(0,11), ylim=c(-2,2), main=title, xlab="ticks", ylab='')
int <- c(1:11) - 0.5
for(i in 1:10){segments(int[i], ts1.paa[1,i], int[i+1], ts1.paa[1,i], lty=1, lwd=2, col="mediumspringgreen")}
for(i in 1:9){segments(int[i+1], ts1.paa[1,i], int[i+1], ts1.paa[1,i+1], lty=1, lwd=2, col="mediumspringgreen")}
for(i in 1:10){segments(int[i], ts2.paa[1,i], int[i+1], ts2.paa[1,i], lty=1, lwd=2, col="royalblue")}
for(i in 1:9){segments(int[i+1], ts2.paa[1,i], int[i+1], ts2.paa[1,i+1], lty=1, lwd=2, col="royalblue")}
int <- c(1:10)
for(i in 1:10){segments(i, ts1.paa[1,i], i, ts2.paa[1,i], lty=2, col="darkorange3")}


## plot the string conversion and distance
## fixing the alphabet size = 9, paa size =7
#
aSize   <- 9
paaSize <- 7

## convert to PAA 9
#
ts1.paa <- paa(ts1.norm, paaSize);
ts2.paa <- paa(ts2.norm, paaSize);

## get the distance
#
dist <- as.character(round(euclidean(ts1.paa[1,],ts2.paa[1,]), digits=4))
title<- substitute( paste("PAA to 7 points, ", Delta, "=", dist ), list (dist=dist))

plot(NULL, xlim=c(0,8), ylim=c(-2,2), main=title, xlab="ticks", ylab='')
int <- c(1:8) - 0.5
for(i in 1:7){segments(int[i], ts1.paa[1,i], int[i+1], ts1.paa[1,i], lty=1, lwd=2, col="mediumspringgreen")}
for(i in 1:6){segments(int[i+1], ts1.paa[1,i], int[i+1], ts1.paa[1,i+1], lty=1, lwd=2, col="mediumspringgreen")}
for(i in 1:7){segments(int[i], ts2.paa[1,i], int[i+1], ts2.paa[1,i], lty=1, lwd=2, col="royalblue")}
for(i in 1:6){segments(int[i+1], ts2.paa[1,i], int[i+1], ts2.paa[1,i+1], lty=1, lwd=2, col="royalblue")}
int <- c(1:7)
for(i in 1:7){segments(i, ts1.paa[1,i], i, ts2.paa[1,i], lty=2, col="darkorange3")}


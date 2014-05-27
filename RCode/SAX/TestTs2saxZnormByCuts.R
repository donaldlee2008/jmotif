##
## This code provides example of PAA and SAX algorithms usage
##
## last edited 06-06-2009, seninp@gmail.com
##

## source the code
#
source("PAA_SAX.R")
library("Cairo")

## get the data
#
ts1.name <- "../data/timeseries01.csv"
ts2.name <- "../data/timeseries02.csv"
ts1.data <- t(as.matrix(read.csv(file=ts1.name, header=FALSE, sep = ",", quote="\"", dec=".", fill = TRUE, comment.char="")))
ts2.data <- t(as.matrix(read.csv(file=ts2.name, header=FALSE, sep = ",", quote="\"", dec=".", fill = TRUE, comment.char="")))

## get the series dimensions
#
ts1.length <- dim(ts1.data)[2]; ts1.min <- min(ts1.data); ts1.max <- max(ts1.data)
ts2.length <- dim(ts2.data)[2]; ts2.min <- min(ts2.data); ts2.max <- max(ts2.data)
plot.min <- min(ts1.min, ts2.min)
plot.max <- max(ts1.max, ts2.max)


## init graphical device
par(mfrow=c(2,2))

## plot the original data
#
plot(NULL, xlim=c(0,max(ts1.length, ts2.length)), ylim=c(plot.min,plot.max), main="ts1 & ts2", xlab="ticks", ylab="values")
lines(ts1.data[1,], lwd=2, col="mediumspringgreen")
points(ts1.data[1,], pch=3, cex=1, col="mediumspringgreen")
lines(ts2.data[1,], lwd=2, col="royalblue")
points(ts2.data[1,], pch=3, cex=1, col="royalblue")

## get znorm
#
ts1.norm <- znorm(ts1.data)
ts2.norm <- znorm(ts2.data)
plot(NULL, xlim=c(0,max(ts1.length, ts2.length)), ylim=c(min(c(ts1.norm,ts2.norm)),
  max(c(ts1.norm,ts2.norm))), main="Znorm (ts1 & ts2)", xlab="ticks", ylab="values")
lines(ts1.norm[1,], lwd=2, col="mediumspringgreen")
points(ts1.norm[1,], pch=3, cex=1, col="mediumspringgreen")
lines(ts2.norm[1,], lwd=2, col="royalblue")
points(ts2.norm[1,], pch=3, cex=1, col="royalblue")


## get the PAA to 10 points of both
#
ts1.paa10 <- paa(ts1.norm, 10)
ts2.paa10 <- paa(ts2.norm, 10)
plot(NULL, xlim=c(0,10), ylim=c(min(c(ts1.paa10,ts2.paa10)),
  max(c(ts1.paa10,ts2.paa10))), main="PAA to 10 ( Znorm (ts1 & ts2) )", xlab="ticks", ylab="values")
lines(ts1.paa10[1,], lwd=2, col="mediumspringgreen")
points(ts1.paa10[1,], pch=3, cex=1, col="mediumspringgreen")
lines(ts2.paa10[1,], lwd=2, col="royalblue")
points(ts2.paa10[1,], pch=3, cex=1, col="royalblue")

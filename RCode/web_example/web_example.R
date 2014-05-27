##
## This code provides example of PAA and SAX algorithms usage
##
## last edited 28-02-2009, seninp@gmail.com
##

## source the code
#
source("../SAX/PAA_SAX.R")

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
par(mfrow=c(1,2), mar=c(5,5,4,4), cex.main=1.0, cex.sub=0.8, cex.lab=0.7, cex.axis=0.7)

## plot the original data
#
plot(NULL, xlim=c(0,ts.length), ylim=c(0,ts.max), main="trajectory1 & trajectory2", xlab="ticks", ylab="Hrs")
i<-0; while(i < 9){
 abline(h=i, lty=2, lwd=1, col="darkolivegreen3"); i <- i+2;
}
i<-0; while(i < 15){
 abline(v=i, lty=2, lwd=1, col="darkolivegreen3"); i <- i+2;
}
lines(ts1.data[1,], lwd=2, col="mediumspringgreen")
points(ts1.data[1,], pch=3, cex=1, col="mediumspringgreen")
lines(ts2.data[1,], lwd=2, col="royalblue")
points(ts2.data[1,], pch=18, cex=1.5, lwd=2, col="royalblue")

## get normalized sequences
#
ts1.norm <- znorm(ts1.data)
ts2.norm <- znorm(ts2.data)

## plot the normalized series
#
plot(NULL, xlim=c(0,14), ylim=c(-2,2), main="Z normalized data", xlab="ticks", ylab='')
i<--2; while(i <= 2){
 abline(h=i, lty=2, lwd=1, col="darkolivegreen3"); i <- i+0.5;
}
i<-0; while(i < 15){
 abline(v=i, lty=2, lwd=1, col="darkolivegreen3"); i <- i+2;
}
lines(ts1.norm[1,], lwd=2, col="mediumspringgreen")
points(ts1.norm[1,], pch=3, cex=1, col="mediumspringgreen")
lines(ts2.norm[1,], lwd=2, col="royalblue")
points(ts2.norm[1,], pch=18, cex=1.5, lwd=2, col="royalblue")

##########################################
##########################################
##########################################
## do PAA with reduction to 9 points
paaSize  <- 9
ts1.paa10 <- paa(ts1.norm, paaSize)
ts2.paa10 <- paa(ts2.norm, paaSize)

## plot the PAA series
#
plot(NULL, xlim=c(0,paaSize+1), ylim=c(-2,2), main="Z normalized data, PAA to 9 points", xlab="ticks", ylab='')
i<--2; while(i <= 2){
 abline(h=i, lty=2, lwd=1, col="darkolivegreen3"); i <- i+0.5;
}
i<-1; while(i < 10){
 abline(v=i, lty=2, lwd=1, col="darkolivegreen3"); i <- i+1;
}
lines(ts1.paa10[1,], lwd=2, col="mediumspringgreen")
points(ts1.paa10[1,], pch=3, cex=1, col="mediumspringgreen")
lines(ts2.paa10[1,], lwd=2, col="royalblue")
points(ts2.paa10[1,], pch=18, cex=1.5, lwd=2, col="royalblue")

## convert to string and extract labels
#
aSize <- 7
ts1.str <- ts2string(ts1.paa10, aSize); ts1.labels <- ts1.str
ts2.str <- ts2string(ts2.paa10, aSize); ts2.labels <- ts2.str

## compose the title
#
title   <- "SAX to 7 chars alphabet -  '"
for(i in 1: paaSize){
 title <- paste(title, ts1.str[i], sep="");
}
title <- paste(title, "', '", sep="");
for(i in 1: paaSize){
 title <- paste(title, ts2.str[i], sep="");
}
title <- paste(title, "'", sep="");

## setup the plotting space
#
plot(NULL, xlim=c(0,11), ylim=c(-2,2), main=title, xlab="ticks", ylab='', yaxt =  "n")

cuts <- alphabet2cut(aSize)

labels <- rep(" ", paaSize)
for(i in 1:paaSize){
 ts1.labels[i] <- paste(round(ts1.paa10[1,i],  digits=2), ts1.labels[i], sep= ", ")
 ts2.labels[i] <- paste(round(ts2.paa10[1,i],  digits=2), ts2.labels[i], sep= ", ")
}

labels <- rep(" ", aSize-1)
for(i in 1:aSize-1){
 labels[i] <- paste(cuts[i+1], num2letter(i), sep= ", ")
}

cuts   <- c(-2, cuts[2:length(cuts)], 2)
labels <- c("-2.0", labels, "2.0")

# draw the major tick marks and label than
axis(2, at = cuts, labels=labels, las=1)

for(i in 2:aSize){
 abline(h=cuts[i], lty=2, lwd=1, col="darkolivegreen3")
}

lines(ts1.paa10[1,], lwd=2, col="mediumspringgreen")
points(ts1.paa10[1,], pch=3, cex=1, col="mediumspringgreen")
lines(ts2.paa10[1,], lwd=2, col="royalblue")
points(ts2.paa10[1,], pch=3, cex=1, col="royalblue")

pointsD <- rbind(c(1:ncol(ts1.paa10)), ts1.paa10[1,])
labels  <- ts1.labels
for(i in 1:ncol(pointsD)){
 if(i %in% c(3, 4) ){
  text(pointsD[1,i], pointsD[2,i]+0.2, labels[i], cex=0.5, col="mediumspringgreen")
 }
 if(i %in% c(6, 7) ){
  text(pointsD[1,i]+0.8, pointsD[2,i]+0.05, labels[i], cex=0.5, col="mediumspringgreen")
 }
 if(i %in% c(1, 2, 5, 8) ){
  text(pointsD[1,i]-0.8, pointsD[2,i]+0.05, labels[i], cex=0.5, col="mediumspringgreen")
 }
 if(i %in% c(9) ){
  text(pointsD[1,i]-0.3, pointsD[2,i]-0.2, labels[i], cex=0.5, col="mediumspringgreen")
 }
}

pointsD <- rbind(c(1:ncol(ts2.paa10)), ts2.paa10[1,])
labels  <- ts2.labels
for(i in 1:ncol(pointsD)){
 if(i %in% c(7, 8, 6) ){
  text(pointsD[1,i]+1, pointsD[2,i]+0.08, labels[i], cex=0.5, col="royalblue")
 }
 if(i %in% c(1, 2, 3, 4, 5, 9) ){
  text(pointsD[1,i]+0.8, pointsD[2,i]-0.1, labels[i], cex=0.5, col="royalblue")
 }
}
##
## This code provides example of PAA algorithm usage
##
## last edited 2-2-2010, seninp@gmail.com
##

## source the R code
#
source("../SAX/PAA_SAX.R")

## example data definitions
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

## plot the raw data
#
library(Cairo)
Cairo(width = 460, height = 320, file="raw_data.png", type="png", pointsize=9,
bg = "white", canvas = "white", units = "px", dpi = 300)
plot(NULL, xlim=c(0,16), ylim=c(0,10), main="PAA example: raw timeseries", 
	xlab="Time ticks", ylab="Values", xaxt="n", cex.main=2, cex.axis=1.6, cex.lab=1.8)
axis(1,at=seq(0, 17, by = 2), cex.axis=1.6)
i<-0; while(i < 11){
 abline(h=i, lty=2, lwd=1, col="darkolivegreen3"); i <- i+2;
}
i<-0; while(i < 17){
 abline(v=i, lty=2, lwd=1, col="darkolivegreen3"); i <- i+2;
}
lines(ts1.data[1,], lwd=2, col="mediumspringgreen")
points(ts1.data[1,], pch=3, cex=1, col="mediumspringgreen")
lines(ts2.data[1,], lwd=2, col="royalblue")
points(ts2.data[1,], pch=18, cex=1.5, lwd=2, col="royalblue")
dev.off()


## get normalized sequences
#
ts1.norm <- znorm(ts1.data)
ts2.norm <- znorm(ts2.data)

## do PAA with reduction to 9 points
#
paaSize  <- 9
ts1.paa9 <- paa(ts1.norm, paaSize)

paa9.x <- t(as.matrix(seq(1,16,by=15/9)))

## plot the PAA series
#
Cairo(width = 460, height = 320, file="paa9_data.png", type="png", pointsize=9,
bg = "white", canvas = "white", units = "px", dpi = 300)
plot(NULL, xlim=c(0,16), ylim=c(-2,2), main="PAA example: TS1 into 9-pieces", xlab="Time ticks", ylab="Values", 
										xaxt="n", cex.main=2, cex.axis=1.6, cex.lab=1.8)
axis(1,at=seq(0, 17, by = 2), cex.axis=1.6)

i <- -2; while(i < 3){
 if(i != 0){
   abline(h=i, lty=2, lwd=1, col="darkolivegreen3");
 }
 i <- i+1;
}
abline(h=0, lty=2, lwd=2, col="red2");
i<-0; while(i < 17){
 abline(v=i, lty=2, lwd=1, col="darkolivegreen3"); i <- i+2;
}
#
lines(ts1.norm[1,], lwd=2, lty=3, col="mediumspringgreen")
points(ts1.norm[1,], pch=3, cex=1, col="mediumspringgreen")

idnt <- 0.0
for(i in 1:ncol(paa9.x)){
 if(i==1) {
   segments(paa9.x[i]-0.5,ts1.paa9[i],paa9.x[i+1]-idnt,ts1.paa9[i], lwd=2, col="springgreen4");
   segments(paa9.x[i+1]-idnt,ts1.paa9[i],paa9.x[i+1]+idnt,ts1.paa9[i+1], lwd=2, col="springgreen4");
 } else if( i == ncol(paa9.x) ) {
   segments(paa9.x[i]+idnt,ts1.paa9[i],paa9.x[i]+0.5,ts1.paa9[i], lwd=2, col="springgreen4");
 } else {
   segments(paa9.x[i]+idnt,ts1.paa9[i],paa9.x[i+1]-idnt,ts1.paa9[i], lwd=2, col="springgreen4");
   segments(paa9.x[i+1]-idnt,ts1.paa9[i],paa9.x[i+1]+idnt,ts1.paa9[i+1], lwd=2, col="springgreen4");
 }
}

dev.off()


## do PAA with reduction to 9 points
#
paaSize  <- 5
ts2.paa5 <- paa(ts2.norm, paaSize)
paa5.x <- t(as.matrix(seq(1,16,by=15/5)))

## plot the PAA series
#
Cairo(width = 460, height = 320, file="paa5_data.png", type="png", pointsize=9,
bg = "white", canvas = "white", units = "px", dpi = 300)
plot(NULL, xlim=c(0,16), ylim=c(-2,2), main="PAA example: TS2 into 5-pieces", xlab="Time ticks", ylab="Values", 
										xaxt="n", cex.main=2, cex.axis=1.6, cex.lab=1.8)
axis(1,at=seq(0, 17, by = 2), cex.axis=1.6)

i <- -2; while(i < 3){
 if(i != 0){
   abline(h=i, lty=2, lwd=1, col="darkolivegreen3");
 }
 i <- i+1;
}
abline(h=0, lty=2, lwd=2, col="red2");
i<-0; while(i < 17){
 abline(v=i, lty=2, lwd=1, col="darkolivegreen3"); i <- i+2;
}
#
lines(ts2.norm[1,], lwd=2, lty=3, col="royalblue")
points(ts2.norm[1,], pch=3, cex=1, col="royalblue")

idnt <- 0.0
for(i in 1:ncol(paa5.x)){
 if(i==1) {
   segments(paa5.x[i]-0.5,ts2.paa5[i],paa5.x[i+1]-idnt,ts2.paa5[i], lwd=2, col="royalblue4");
   segments(paa5.x[i+1]-idnt,ts2.paa5[i],paa5.x[i+1]+idnt,ts2.paa5[i+1], lwd=2, col="royalblue4");
 } else if( i == ncol(paa9.x) ) {
   segments(paa5.x[i]+idnt,ts2.paa5[i],paa5.x[i]+0.5,ts2.paa5[i], lwd=2, col="royalblue4");
 } else {
   segments(paa5.x[i]+idnt,ts2.paa5[i],paa5.x[i+1]-idnt,ts2.paa5[i], lwd=2, col="royalblue4");
   segments(paa5.x[i+1]-idnt,ts2.paa5[i],paa5.x[i+1]+idnt,ts2.paa5[i+1], lwd=2, col="royalblue4");
 }
}

dev.off()
##
## Z-Normalization primer
##
## Pavel Senin, seninp@gmail.com, 02-06-2010
##
##

## source the SAX library code
#
(WD <- getwd()); if (!is.null(WD)) setwd(WD)
source("../SAX/PAA_SAX.R")

## load the test data
#
# define the file name
ts1.name <- "../data/timeseries01.csv"
# load it 'as matrix'
ts1.data <- as.matrix(read.csv(file=ts1.name, header=FALSE, sep = ",", quote="\"", 
								dec=".", fill = TRUE, comment.char=""))
# reshape it, one row, 14 columns
ts1.data <- reshape(ts1.data, 1, nrow(ts1.data))
# same deal with the dataset 2
ts2.name <- "../data/timeseries02.csv"
ts2.data <- as.matrix(read.csv(file=ts2.name, header=FALSE, sep = ",", quote="\"", 
								dec=".", fill = TRUE, comment.char=""))
ts2.data <- reshape(ts2.data, 1, nrow(ts2.data))

## display data
# 
print("Timeseries #1:"); print(ts1.data, zero.print = ".")
print("Timeseries #2:"); print(ts2.data, zero.print = ".");

## get the series dimensions
#
ts.length <- max(dim(ts2.data)[2], dim(ts1.data)[2])
ts.max <- max(max(ts2.data), max(ts1.data))

## plot the raw data
#
library(Cairo)
Cairo(width = 460, height = 320, file="raw_data.png", type="png", pointsize=9,
bg = "white", canvas = "white", units = "px", dpi = 300)
plot(NULL, xlim=c(0,15), ylim=c(0,10), main="Z normalization example: raw timeseries", xlab="Time ticks", ylab="Values", 
										xaxt="n", cex.main=2, cex.axis=1.6, cex.lab=1.8)
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

## Normalize data
#
ts1.norm <- znorm(ts1.data)
ts2.norm <- znorm(ts2.data)

## plot the normal data
#
library(Cairo)
Cairo(width = 460, height = 320, file="znormalized_data.png", type="png", pointsize=9,
bg = "white", canvas = "white", units = "px", dpi = 300)
plot(NULL, xlim=c(0,15), ylim=c(-2,2), main="Z normalization example: normalized timeseries", xlab="Time ticks", ylab="Values", 
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
lines(ts1.norm[1,], lwd=2, col="mediumspringgreen")
points(ts1.norm[1,], pch=3, cex=1, col="mediumspringgreen")
lines(ts2.norm[1,], lwd=2, col="royalblue")
points(ts2.norm[1,], pch=18, cex=1.5, lwd=2, col="royalblue")
dev.off()
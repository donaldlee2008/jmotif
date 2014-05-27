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
plot(NULL, xlim=c(0,16), ylim=c(0,10), main="SAX example: raw timeseries, 15 points", 
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

## plot the normal data
#
library(Cairo)
Cairo(width = 460, height = 320, file="znormalized_data.png", type="png", pointsize=9,
bg = "white", canvas = "white", units = "px", dpi = 300)
plot(NULL, xlim=c(0,15), ylim=c(-2,2), main="SAX example: step1: Z-normalization", xlab="Time ticks", ylab="Values", 
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

## do PAA with reduction to 9 points
#
paaSize  <- 9
ts1.paa9 <- paa(ts1.norm, paaSize)
ts2.paa9 <- paa(ts2.norm, paaSize)

paa9.x <- t(as.matrix(seq(1:9)))

## plot the PAA series
#
Cairo(width = 460, height = 320, file="paa9_data.png", type="png", pointsize=9,
bg = "white", canvas = "white", units = "px", dpi = 300)
plot(NULL, xlim=c(0,10), ylim=c(-2,2), main="SAX example, step 2: PAA: 15 points into 9", xlab="Time ticks", ylab="Values", 
										xaxt="n", cex.main=2, cex.axis=1.6, cex.lab=1.8)
axis(1,at=seq(0, 10, by = 1), cex.axis=1.6)

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

idnt <- 0.0
for(i in 1:ncol(paa9.x)){
 if(i==1) {
   segments(paa9.x[i]-0.5,ts1.paa9[i],paa9.x[i+1]-idnt,ts1.paa9[i], lwd=2, col="mediumspringgreen");
   segments(paa9.x[i+1]-idnt,ts1.paa9[i],paa9.x[i+1]+idnt,ts1.paa9[i+1], lwd=2, col="mediumspringgreen");
 } else if( i == ncol(paa9.x) ) {
   segments(paa9.x[i]+idnt,ts1.paa9[i],paa9.x[i]+0.5,ts1.paa9[i], lwd=2, col="mediumspringgreen");
 } else {
   segments(paa9.x[i]+idnt,ts1.paa9[i],paa9.x[i+1]-idnt,ts1.paa9[i], lwd=2, col="mediumspringgreen");
   segments(paa9.x[i+1]-idnt,ts1.paa9[i],paa9.x[i+1]+idnt,ts1.paa9[i+1], lwd=2, col="mediumspringgreen");
 }
}

idnt <- 0.0
for(i in 1:ncol(paa9.x)){
 if(i==1) {
   segments(paa9.x[i]-0.5,ts2.paa9[i],paa9.x[i+1]-idnt,ts2.paa9[i], lwd=2, col="royalblue");
   segments(paa9.x[i+1]-idnt,ts2.paa9[i],paa9.x[i+1]+idnt,ts2.paa9[i+1], lwd=2, col="royalblue");
 } else if( i == ncol(paa9.x) ) {
   segments(paa9.x[i]+idnt,ts2.paa9[i],paa9.x[i]+0.5,ts2.paa9[i], lwd=2, col="royalblue");
 } else {
   segments(paa9.x[i]+idnt,ts2.paa9[i],paa9.x[i+1]-idnt,ts2.paa9[i], lwd=2, col="royalblue");
   segments(paa9.x[i+1]-idnt,ts2.paa9[i],paa9.x[i+1]+idnt,ts2.paa9[i+1], lwd=2, col="royalblue");
 }
}

dev.off()

## plot the SAX alphabet cuts and SAX series itself
#
Cairo(width = 460, height = 320, file="paa9_sax_data.png", type="png", pointsize=9,
bg = "white", canvas = "white", units = "px", dpi = 300)
plot(NULL, xlim=c(0,10), ylim=c(-2,2), main="SAX example, step 3: SAX \"alphabet cuts\"", xlab="Time ticks", ylab="Values", 
								yaxt="n", xaxt="n", cex.main=2, cex.axis=1.6, cex.lab=1.8)
rect(-1,0.67,11,2.5,border = NA, col="lemonchiffon2")
rect(-1,0,11,0.67,border = NA, col="lightsteelblue1")
rect(-1,-0.67,11,0,border = NA, col="lemonchiffon2")
rect(-1,-2.5,11,-0.67,border = NA, col="lightsteelblue1")

rect(3,ts2.paa9[3],4,ts1.paa9[3],border = NA, col="lightsalmon1")
rect(7,ts1.paa9[7],8,ts2.paa9[7],border = NA, col="lightsalmon1")

axis(1,at=seq(0, 10, by = 1), cex.axis=1.6)
axis(2,at=seq(-2, 2, by = 1), cex.axis=1.6)

i <- -2; while(i < 3){
 if(i != 0){
   abline(h=i, lty=2, lwd=1, col="darkolivegreen3");
 }
 i <- i+1;
}
i<-0; while(i < 17){
 abline(v=i, lty=2, lwd=1, col="darkolivegreen3"); i <- i+2;
}
cuts <- c(-0.67, 0, 0.67)
for(i in c(1:3)){
 abline(h=cuts[i], lty=2, lwd=2, col="red2");
 i <- i + 1;
}

text(0.4, 1.4, "d", cex=2.8, col="slateblue4"); text(9.6, 1.4, "d", cex=2.8, col="slateblue4"); 
text(0.4, 0.3, "c", cex=2.8, col="slateblue4"); text(9.6, 0.3, "c", cex=2.8, col="slateblue4")
text(0.4, -0.3, "b", cex=2.8, col="slateblue4"); text(9.6, -0.3, "b", cex=2.8, col="slateblue4")
text(0.4, -1.4, "a", cex=2.8, col="slateblue4"); text(9.6, -1.4, "a", cex=2.8, col="slateblue4")




#
idnt <- 0.0
for(i in 1:ncol(paa9.x)){
 if(i==1) {
   segments(paa9.x[i]-0.5,ts1.paa9[i],paa9.x[i+1]-idnt,ts1.paa9[i], lwd=2, col="mediumspringgreen");
   segments(paa9.x[i+1]-idnt,ts1.paa9[i],paa9.x[i+1]+idnt,ts1.paa9[i+1], lwd=2, col="mediumspringgreen");
 } else if( i == ncol(paa9.x) ) {
   segments(paa9.x[i]+idnt,ts1.paa9[i],paa9.x[i]+0.5,ts1.paa9[i], lwd=2, col="mediumspringgreen");
 } else {
   segments(paa9.x[i]+idnt,ts1.paa9[i],paa9.x[i+1]-idnt,ts1.paa9[i], lwd=2, col="mediumspringgreen");
   segments(paa9.x[i+1]-idnt,ts1.paa9[i],paa9.x[i+1]+idnt,ts1.paa9[i+1], lwd=2, col="mediumspringgreen");
 }
}

idnt <- 0.0
for(i in 1:ncol(paa9.x)){
 if(i==1) {
   segments(paa9.x[i]-0.5,ts2.paa9[i],paa9.x[i+1]-idnt,ts2.paa9[i], lwd=2, col="royalblue");
   segments(paa9.x[i+1]-idnt,ts2.paa9[i],paa9.x[i+1]+idnt,ts2.paa9[i+1], lwd=2, col="royalblue");
 } else if( i == ncol(paa9.x) ) {
   segments(paa9.x[i]+idnt,ts2.paa9[i],paa9.x[i]+0.5,ts2.paa9[i], lwd=2, col="royalblue");
 } else {
   segments(paa9.x[i]+idnt,ts2.paa9[i],paa9.x[i+1]-idnt,ts2.paa9[i], lwd=2, col="royalblue");
   segments(paa9.x[i+1]-idnt,ts2.paa9[i],paa9.x[i+1]+idnt,ts2.paa9[i+1], lwd=2, col="royalblue");
 }
}

dev.off()


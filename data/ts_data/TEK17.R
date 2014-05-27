##
## This code supports the WiKi tutorial on the motif frequency search.
##
## last edited 3-27-2010, seninp@gmail.com
##
library(Cairo)

## source the R code
#
source("../../RCode/SAX/PAA_SAX.R")

## example data definitions
#
ts.name <- "TEK17.txt"

## load the data
#
ts.data <- as.matrix(read.csv(file=ts.name, header=FALSE, sep = "\t", quote="\"", dec=".", fill = TRUE, comment.char=""))

Cairo(width = 600, height = 180, file="TEK17_raw.png", type="png", pointsize=9,
bg = "white", canvas = "white", units = "px", dpi = 240)
par(mfrow=c(1, 1), mar=c(3,2,2,1))

xlabLX.at=seq(0,5000,200)
xlabSX.at=seq(100,4900,200)
plot(NULL, xlim=c(0,5000), ylim=c(min(ts.data[,1]), max(ts.data[,1])), xlab="", ylab="")
lines(ts.data[,1], col="red", lwd=0.5)
lines(seq(2101,2201),ts.data[2101:2201,1], col="blue", lwd=2)
dev.off()

Cairo(width = 280, height = 280, file="TEK17_discord.png", type="png", pointsize=9,
bg = "white", canvas = "white", units = "px", dpi = 240)
plot(NULL, xlim=c(1900,2500), ylim=c(min(ts.data[,1]), max(ts.data[,1])), xlab="", ylab="")
lines(ts.data[,1], col="red", lwd=0.5)
lines(seq(2101,2201),ts.data[2101:2201,1], col="blue", lwd=2)

dev.off()

Cairo(width = 280, height = 280, file="TEK17_cluster.png", type="png", pointsize=9,
bg = "white", canvas = "white", units = "px", dpi = 240)
plot(NULL, xlim=c(-20,110), ylim=c(-2, 16), xlab="", yaxt="n", ylab="")
lines(seq(0,100),ts.data[2101:2201,1], col="blue", lwd=2)
lines(seq(0,100),ts.data[111:211,1]+3, col="red", lwd=1)
lines(seq(0,100),ts.data[1101:1201,1]+6, col="red", lwd=1)
lines(seq(0,100),ts.data[3101:3201,1]+8, col="red", lwd=1)
lines(seq(0,100),ts.data[4111:4211,1]+10, col="red", lwd=1)
text(-10,ts.data[2101,1], labels="s1", col="blue")
text(-10,ts.data[111,1]+3, labels="s2", col="red")
text(-10,ts.data[1101,1]+6, labels="s3", col="red")
text(-10,ts.data[3101,1]+8, labels="s4", col="red")
text(-10,ts.data[4111,1]+10, labels="s5", col="red")
dev.off()

s1 <- ts.data[2101:2201,1]
s2 <- ts.data[111:211,1]
s3 <- ts.data[1101:1201,1]
s4 <- ts.data[3101:3201,1]
s5 <- ts.data[4111:4211,1]
s <- rbind(s1,s2,s3,s4,s5)

Cairo(width = 280, height = 280, file="TEK17_cluster1.png", type="png", pointsize=9, bg = "white",
 canvas = "white", units = "px", dpi = 240)

plot(hc,mar=c(1,2,2,1), xlab="", ylab="", main="segments clustering", sub="")

dev.off()



stop()

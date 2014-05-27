## source the code
#
source("PAA_SAX.R")

## time series with two peaks here
#
ts1 <- as.matrix(c(5.0, 7.0, 2.0, 8.0, 11.0, 11.0, 6.0, 3.0,
                    4.0, 5.0, 9.0, 8.0, 2.0))

## plot is as raw
#
par(mfrow=c(1,1), cex.main=0.9, cex.axis=0.6, cex.lab=0.7, mar=c(1,1,2,1))
plot(NULL, xlim=c(0,dim(ts1)[1]), ylim=c(1,max(ts1)), main="RAW series", xlab="ticks", ylab="values")
lines(ts1, lwd=4, col="mediumspringgreen")
points(ts1, pch=1, cex=2, lwd=2, col="mediumspringgreen")

ts2 <- as.matrix(c(ts1[,1], NaN, NaN )) 
ts3 <- as.matrix(c(NaN, NaN, ts1[,1])) 
## plot is as raw
#
par(mfrow=c(1,1), cex.main=0.9, cex.axis=0.6, cex.lab=0.7, mar=c(1,1,2,1))
plot(NULL, xlim=c(0,dim(ts2)[1]), ylim=c(1,max(ts1)), main="RAW series", xlab="ticks", ylab="values")
lines(ts2, lwd=4, col="mediumspringgreen")
points(ts2, pch=1, cex=2, lwd=2, col="mediumspringgreen")
lines(ts3, lwd=4, col="royalblue")
points(ts3, pch=1, cex=2, lwd=2, col="royalblue")

ts2 <- as.matrix(c(ts1[,1], 0.0, 0.0 )) 
ts3 <- as.matrix(c(0.0, 0.0, ts1[,1])) 

euclidean(ts2, ts3)

ts1 <- as.matrix(c(-5.0, -7.0, 2.0, 18.0, 41.0, 51.0, 60.0, 30.0,
                    40.0, 50.0, 10.0, -18.0, 2.0))
ts4 <- as.matrix(c(0.04, 0.3, -0.1, 0.4, 0.9, 0.8, 0.6, 0.3,
                    -0.4, 0.2, 0.3, -0.1, -0.2))
par(mfrow=c(1,1), cex.main=0.9, cex.axis=0.6, cex.lab=0.7, mar=c(1,1,2,1))
plot(NULL, xlim=c(0,dim(ts2)[1]), ylim=c(min(ts1),max(ts1)), main="RAW series", xlab="ticks", ylab="values")
lines(ts1, lwd=4, col="mediumspringgreen")
points(ts1, pch=1, cex=2, lwd=2, col="mediumspringgreen")
lines(ts4, lwd=4, col="royalblue")
points(ts4, pch=1, cex=2, lwd=2, col="royalblue")

ts1.norm <- znorm(t(ts1))
ts4.norm <- znorm(t(ts4))

par(mfrow=c(1,1), cex.main=0.9, cex.axis=0.6, cex.lab=0.7, mar=c(1,1,2,1))
plot(NULL, xlim=c(0,dim(ts2)[1]), ylim=c(-3,3), main="Z-normalized series", xlab="ticks", ylab="values")
lines(t(ts1.norm), lwd=4, col="mediumspringgreen")
points(t(ts1.norm), pch=1, cex=2, lwd=2, col="mediumspringgreen")
lines(t(ts4.norm), lwd=4, col="royalblue")
points(t(ts4.norm), pch=1, cex=2, lwd=2, col="royalblue")

###
###
###

stream_data   <- as.matrix(read.csv("devtime.csv", header=TRUE, sep = ",", 
                           quote="\"", na.strings=c("NaN"), dec=".", 
                           fill = TRUE, comment.char=""))
x <- as.matrix(as.numeric(stream_data[,4]))[1:200,]
par(mfrow=c(1,1), cex.main=0.9, cex.axis=0.6, cex.lab=0.7, mar=c(1,1,2,1))
plot(NULL, xlim=c(1,201), ylim=c(-1,4), main="", xlab="ticks", ylab="values")
lines(x, lwd=4, col="mediumspringgreen")
points(x, pch=1, cex=1, lwd=2, col="mediumspringgreen")

plot(x)
plot(t(x)[1:100,], ylim=c(-5, 5), type = "l", col="royalblue", main = "plot", lwd=2,
       xlab="days", ylab="raw values")
  points(x, cex = 1, col=stream_colors[1])

  for(i in 2:8){
   lines(x <- stream_data[,i], col=stream_colors[i], lwd=2)
   points(x, cex = 1, col=stream_colors[i])
  }

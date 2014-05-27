library('Cairo')
library('dtw')

#####
##### part #1, construct timeseries and plot them
#####

## episodes constituting the timeline
##steep spike
spike1 <- c(1,2,5,8,6,4,2,0)
##low 
spike2 <- c(0,1,2,4,3,2,1)
## wide
spike3 <- c(1,3,4,6,7,7,6,5,3,2,1)
## randow
spike4 <- c(1,2,0,5,1,7,0)
## steady run
run_low <- c(2,3,3,4,2,3)
run_high <- c(5,4,6,4,4,5)


## load the data
ts1.data <- c(spike1,run_low,spike3,run_low,spike4,run_high,spike2,run_high)
ts1.l <- length(ts1.data)

ts2.data <- as.vector(c(1,2,5,7,5,2,1))
ts2.l <- length(ts2.data)


## find means and standard deviations
ts1.mean <- mean(ts1.data); ts1.mean
ts1.dev <- sd(ts1.data); ts1.dev
ts2.mean <- mean(ts2.data); ts2.mean
ts2.dev <- sd(ts2.data); ts2.dev

## normalize timeseries
ts1.norm <- (ts1.data - ts1.mean)/ts1.dev
ts2.norm <- (ts2.data - ts2.mean)/ts2.dev

## get the max values for the plot
plot.xmax <- max(length(ts2.data), length(ts1.data))
plot.ymax <- max(c(ts1.data,ts2.data))
norm.xmax <- max(length(ts2.data), length(ts1.data))
norm.ymax <- max(c(ts1.norm,ts2.norm))

par(mfrow=c(2,1))

## plot the raw data
plot(NULL, xlim=c(0,plot.xmax), ylim=c(0,plot.ymax), main="raw series", xlab="Time ticks", ylab="Hrs")
lines(ts1.data, lwd=2, col="mediumspringgreen")
points(ts1.data, pch=3, cex=1, col="mediumspringgreen")
lines(ts2.data, lwd=2, col="royalblue")
points(ts2.data, pch=18, cex=1.5, lwd=2, col="royalblue")

## plot the normalized data
plot(NULL, xlim=c(0,norm.xmax), ylim=c(-norm.ymax,norm.ymax), main="normalized series", xlab="Time ticks", ylab="Hrs")
lines(ts1.norm, lwd=2, col="mediumspringgreen")
points(ts1.norm, pch=3, cex=1, col="mediumspringgreen")
lines(ts2.norm, lwd=2, col="royalblue")
points(ts2.norm, pch=18, cex=1.5, lwd=2, col="royalblue")


#####
##### part #2, plot the normalized curves, hits and plot Euclidean distances below
#####

## amount if minimas to track
##
mins <- 12

## get all distances
##
e.dist = as.vector(c())
for(i in 1:(length(ts1.norm)-length(ts2.norm))) {
 dd <- dist(rbind(ts1.norm[i:(i+length(ts2.norm)-1)],ts2.norm))
 e.dist <- cbind(e.dist, as.vector(dd))
}

## prepeare the color labels
##
e.colors=rep("deepskyblue3",57)
e.min5 = sort(e.dist)[1:mins]
e.min_idx = as.vector(c())
for(i in 1:mins){
 print(as.vector(which(e.dist == e.min5[i])))
 e.min_idx <- unique(c(e.min_idx, as.vector(which(e.dist == e.min5[i]))))
 e.colors[which(e.dist == e.min5[i])] = "firebrick2"
}

## do the plotting
##
par(mfrow=c(3,1), mar=c(4,3,5,3))

## plot the normalized data
plot(NULL, xlim=c(0,norm.xmax), ylim=c(-norm.ymax,norm.ymax), main="normalized series", xlab="Time ticks", ylab="Hrs")
lines(ts1.norm, lwd=2, col="mediumspringgreen")
points(ts1.norm, pch=3, cex=1, col="mediumspringgreen")
lines(ts2.norm, lwd=2, col="royalblue")
points(ts2.norm, pch=18, cex=1.5, lwd=2, col="royalblue")

## plot the normalized data PLUS the minimas
plot(NULL, xlim=c(0,norm.xmax), ylim=c(-norm.ymax,norm.ymax), 
  main="normalized curves", xlab="Time ticks", ylab="Hrs", bty="l")
lines(ts1.norm, lwd=2, col="mediumspringgreen")
points(ts1.norm, pch=3, cex=1, col="mediumspringgreen")
lines(ts2.norm, lwd=2, col="royalblue")
points(ts2.norm, pch=18, cex=1.5, lwd=2, col="royalblue")

for(i in 1:length(e.min_idx)){
 xstart=e.min_idx[i]
 xcoords=c(xstart:(xstart+length(ts2.norm)-1))
 lines(xcoords, ts2.norm, lwd=2, col="firebrick")
 points(xcoords, ts2.norm, pch=18, cex=1.5, lwd=2, col="firebrick")
}

## and finally distances
e.p <- c(e.dist, c(0,0,0,0,0,0))
barplot(e.p, ylim=c(0,6), names.arg=c(1:56),
             main="Euclidean distance based similarity",
             col=e.colors)



##
## now plot the DTW sliding window part 
##

## amount if minimas to track
##
mins <- 15

## do the computation
dtw.dist = as.vector(c())
for(i in 1:(ts1.l-ts2.l)) {
 s <- i; e <- i+ts2.l
 if( i>2 ){ s <- i-2}
 if( ts1.l-ts2.l >2 ) {e <- i+ts2.l+1}
 q <- ts2.norm
 r <- ts1.norm[s:e]
 
 al <- dtw(q,r,open.end=T,window.type="sakoechiba",window.size=3)
 wq <- warp(al,index.reference=F)
 dd <- dist(rbind(q[wq],r))

 dtw.dist <- cbind(dtw.dist,as.vector(dd))
}

## color labels
dtw.colors=rep("deepskyblue3",57)
dtw.min5 = sort(dtw.dist)[1:mins]
dtw.min_idx = as.vector(c())
for(i in 1:mins){
 dtw.min_idx <- unique(c(dtw.min_idx, as.vector(which(dtw.dist == dtw.min5[i]))))
 dtw.colors[which(dtw.dist == dtw.min5[i])] = "firebrick2"
}


## do the plotting
##
par(mfrow=c(3,1), mar=c(4,3,5,3))

## plot the normalized data
plot(NULL, xlim=c(0,norm.xmax), ylim=c(-norm.ymax,norm.ymax), main="normalized series", xlab="Time ticks", ylab="Hrs")
lines(ts1.norm, lwd=2, col="mediumspringgreen")
points(ts1.norm, pch=3, cex=1, col="mediumspringgreen")
lines(ts2.norm, lwd=2, col="royalblue")
points(ts2.norm, pch=18, cex=1.5, lwd=2, col="royalblue")

## plot the normalized data PLUS the minimas
plot(NULL, xlim=c(0,norm.xmax), ylim=c(-norm.ymax,norm.ymax), 
  main="normalized curves", xlab="Time ticks", ylab="Hrs", bty="l")
lines(ts1.norm, lwd=2, col="mediumspringgreen")
points(ts1.norm, pch=3, cex=1, col="mediumspringgreen")
lines(ts2.norm, lwd=2, col="royalblue")
points(ts2.norm, pch=18, cex=1.5, lwd=2, col="royalblue")

for(i in 1:length(dtw.min_idx)){
 xstart=dtw.min_idx[i]
 xcoords=c(xstart:(xstart+length(ts2.norm)-1))
 lines(xcoords, ts2.norm, lwd=2, col="firebrick")
 points(xcoords, ts2.norm, pch=18, cex=1.5, lwd=2, col="firebrick")
}


e.p <- c(dtw.dist, c(0,0,0,0,0,0))
barplot(e.p, ylim=c(0,6), names.arg=c(1:56),
             main="DTW distance based similarity",
             col=dtw.colors)


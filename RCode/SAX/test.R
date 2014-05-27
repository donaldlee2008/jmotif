ts1.data=t(as.matrix(c(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 6.0, 1.0, 2.0, 3.0, 0.0, 1.0, 3.0, 1.0, 1.0, 0.0, 0.0, 2.0, 0.0, 2.0, 0.0)))
ts1.data=t(as.matrix(c(6.0, 0.0, 0.0, 0.0, 1.0, 2.0, 0.0, 0.0, 1.0, 4.0, 12.0, 8.0, 5.0, 3.0, 6.0, 2.0, 0.0, 1.0, 0.0, 7.0, 8.0, 5.0, 1.0, 1.0)))

ts.length <- dim(ts1.data)[2]
ts.min <- min(ts1.data)
ts.max <- max(ts1.data)

par(mfrow=c(2,3))

plot(NULL, xlim=c(0,ts.length+1), ylim=c(ts.min,ts.max), main="Raw Series", xlab="ticks", ylab="Hrs")
lines(ts1.data[1,], lwd=2, col="mediumspringgreen")
points(ts1.data[1,], pch=3, cex=1, col="mediumspringgreen")

ts1.norm <- znorm(ts1.data)
plot(NULL, xlim=c(0,ts.length+1), ylim=c(-2,2), main="Z Normalized series", xlab="ticks", ylab='')
lines(ts1.norm[1,], lwd=2, col="mediumspringgreen")
points(ts1.norm[1,], pch=3, cex=1, col="mediumspringgreen")

ts1.paa <- paa(ts1.norm, 6)
plot(NULL, xlim=c(0,7), ylim=c(-2,2), main="PAA approximated series", xlab="ticks", ylab='')
lines(ts1.paa[1,], lwd=2, col="mediumspringgreen")
points(ts1.paa[1,], pch=3, cex=1, col="mediumspringgreen")

aSize  <- 5

ts1.str <- ts2string(ts1.paa, aSize); ts1.labels <- ts1.str


title   <- "SAX to 10 chars alphabet - '"
for(i in 1:14){
  title <- paste(title, ts1.str[i], sep="");
}
title <- paste(title, "', '", sep="");
for(i in 1:14){
  title <- paste(title, ts2.str[i], sep="");
}
title <- paste(title, "'", sep="");


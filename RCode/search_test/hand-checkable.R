r<-ts1.norm[1:11]
r<-c(c(-1,-1),ts1.norm[1:11])
q<-ts2.norm

par(mfrow=c(2,2))

plot(NULL, xlim=c(1,length(r)), ylim=c(-norm.ymax,norm.ymax), main="normalized curves", xlab="Time ticks", ylab="Hrs")
points(q, pch=3, cex=1, col="blue")
lines(q, lwd=2, col="blue")
lines(r, lwd=2, col="red")
points(r, pch=18, cex=1.5, lwd=2, col="red")

al <- dtw(q,r)
wq <- warp(al, index.reference=FALSE)
print(wq)
plot(NULL, xlim=c(1,length(r)), ylim=c(-norm.ymax,norm.ymax), main="warped query", xlab="Time ticks", ylab="Hrs")
points(q[wq], pch=3, cex=1, col="blue")
lines(q[wq], lwd=2, col="blue")
lines(r, lwd=2, col="red")
points(r, pch=18, cex=1.5, lwd=2, col="red")

al <- dtw(q,r,open.end=T,window.type="sakoechiba",window.size=3)
wq <- warp(al, index.reference=FALSE)
print(wq)
plot(NULL, xlim=c(1,length(r)), ylim=c(-norm.ymax,norm.ymax), main="warped query, opeEnd = TRUE", xlab="Time ticks", ylab="Hrs")
points(q[wq], pch=3, cex=1, col="blue")
lines(q[wq], lwd=2, col="blue")
lines(r, lwd=2, col="red")
points(r, pch=18, cex=1.5, lwd=2, col="red")


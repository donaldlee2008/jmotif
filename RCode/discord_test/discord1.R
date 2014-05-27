px <- seq(0,pi*30,0.1)
py <- sin(px)
inc = 0.1
dif <- py[length(px)/2-30]
for(i in (length(px)/2-50):(length(px)/2-30)){
 py[i] <- py[i-1]+inc
}
dif <- py[length(px)/2-30] - dif 
for(i in ((length(px)/2-30)+1):length(px)){
 print(i)
 py[i] <- py[i]+dif
}
plot(py)
res <- rbind(t(as.matrix(px)),t(as.matrix(py)))
# write.csv(t(res), file="data.csv", row.names = FALSE)

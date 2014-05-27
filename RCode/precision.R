require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require("lattice")

dat = read.csv("cbf/cbf_performance6077_log2_nored.csv",header=F,skip=1)
dat = read.csv("../docs/performance6077_exact.csv",header=F,skip=1)
names(dat)=c("train","jmotif_error","euclidean_error","jmotif_train","jmotif_classifier","euclidean_time")
names(dat)=c("train","jmotif_error","euclidean_error","jmotif_time","euclidean_time")

index=sort(unique(dat$train))
jmotif_error=rep(-1,length(index))
for(i in 1:(length(index))){
  jmotif_error[i]=mean(dat[dat$train==index[i],2])
}
jmotif_runtime=rep(-1,length(index))
for(i in 1:(length(index))){
  jmotif_runtime[i]=mean(dat[dat$train==index[i],4])
}
euclidean_error=rep(-1,length(index))
for(i in 1:(length(index))){
  euclidean_error[i]=mean(dat[dat$train==index[i],3])
}
euclidean_runtime=rep(-1,length(index))
for(i in 1:(length(index))){
  euclidean_runtime[i]=mean(dat[dat$train==index[i],5])
}

d=data.frame(index,euclidean_error,jmotif_error)
dm=melt(d,id.var="index")
p1 <- ggplot(dm, aes(index, value, color=variable)) + geom_line(lwd=1) +
  geom_point() + theme_bw() +
  scale_x_continuous("TRAIN dataset size") + 
  scale_y_log10("Classification error") +
  ggtitle("Accuracy, CBF: Euclidean 1-NN and JMotif Nored") +
  theme(plot.title=element_text(size=18),axis.text.x=element_text(size=10), 
        axis.text.y=element_text(size=10),axis.title.x=element_text(size=14), 
        axis.title.y=element_text(size=14))
p1

index=sort(unique(dat$train))
jmotif_error=rep(-1,length(index))
for(i in 1:(length(index))){
  jmotif_error[i]=mean(dat[dat$train==index[i],2])
}
jmotif_train=rep(-1,length(index))
for(i in 1:(length(index))){
  jmotif_train[i]=mean(dat[dat$train==index[i],4])
}
jmotif_classifier=rep(-1,length(index))
for(i in 1:(length(index))){
  jmotif_classifier[i]=mean(dat[dat$train==index[i],5])
}
euclidean_error=rep(-1,length(index))
for(i in 1:(length(index))){
  euclidean_error[i]=mean(dat[dat$train==index[i],3])
}
euclidean_runtime=rep(-1,length(index))
for(i in 1:(length(index))){
  euclidean_runtime[i]=mean(dat[dat$train==index[i],6])
}

d=data.frame(index,euclidean_error,jmotif_error)
dm=melt(d,id.var="index")
p1 <- ggplot(dm, aes(index, value, color=variable)) + geom_line(lwd=1) +
  geom_point() + theme_bw() +
  scale_x_continuous("TRAIN dataset size") + 
  scale_y_log10("Classification error") +
  ggtitle("Accuracy, CBF: Euclidean 1-NN and JMotif Nored") +
  theme(plot.title=element_text(size=18),axis.text.x=element_text(size=10), 
        axis.text.y=element_text(size=10),axis.title.x=element_text(size=14), 
        axis.title.y=element_text(size=14))
p1

d=data.frame(index,euclidean_runtime,jmotif_train,jmotif_classifier)
dm=melt(d,id.var="index")
p2 <- ggplot(dm, aes(index, value, color=variable)) + geom_line(lwd=1) +
  geom_point() + theme_bw() +
  scale_x_continuous("TRAIN dataset size") + 
  scale_y_continuous("Classification time, ms")+
                     #, limits=c(0,9000), breaks=seq(0,9000,1000)) +
  ggtitle("Runtime, CBF: Euclidean 1-NN and JMotif Nored") +
  theme(plot.title=element_text(size=18),axis.text.x=element_text(size=10), 
        axis.text.y=element_text(size=10),axis.title.x=element_text(size=14), 
        axis.title.y=element_text(size=14))
p2

Cairo(width = 800, height = 600, file="cbf/p_comparison.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(p1, p2, ncol=1))
dev.off()
#
#
#
#
dat = read.csv("../docs/performance.csv")

cd = cbind(dat[,1:2],dat[,4],dat[,6],dat[,8])
names(cd)=c("train_size","Euclidean","DTW","DTW-SC","JMotif")
data=melt(cd, id.vars="train_size")

p <- ggplot(data, aes(train_size, value, color=variable)) + geom_line() +
  geom_point() + theme_bw() +
  scale_x_continuous("TRAIN dataset size", limits=c(0,500), breaks=seq(0,500,25)) + 
  scale_y_continuous("Classification error", limits=c(0,0.5), breaks=seq(0,0.5,0.1)) +
  ggtitle("1-NN Euclidean, DTW, DTW-SC, and JMotif accuracy comparison, CBF data") +
  theme(plot.title=element_text(size=18),axis.text.x=element_text(size=10), 
        axis.text.y=element_text(size=10),axis.title.x=element_text(size=14), 
        axis.title.y=element_text(size=14))
p
Cairo(width = 800, height = 600, file="cbf/ppt_comparison.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
p
dev.off()

p <- ggplot(data, aes(train_size, value, color=variable)) + geom_line() +
  geom_point() + theme_bw() +
  scale_x_continuous("TRAIN dataset size", limits=c(0,50), breaks=seq(0,50,10)) + 
  scale_y_continuous("Classification error", limits=c(0,0.5), breaks=seq(0,0.5,0.1)) +
  ggtitle("1-NN Euclidean, DTW, DTW-SC, and JMotif accuracy comparison, CBF data") +
  theme(plot.title=element_text(size=18),axis.text.x=element_text(size=10), 
        axis.text.y=element_text(size=10),axis.title.x=element_text(size=14), 
        axis.title.y=element_text(size=14))
p
Cairo(width = 800, height = 600, file="cbf/ppt_comparison_zoom.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
p
dev.off()

cd = data.frame(cbind(dat[,1],dat[,3],dat[,5],dat[,9]))
names(cd)=c("train_size","Euclidean","DTW","JMotif")
data=melt(cd, id.vars="train_size")

p1 <- ggplot(data, aes(train_size, value, color=variable)) + geom_line() +
  geom_point() + theme_bw() +
  scale_x_continuous("TRAIN dataset size", limits=c(0,500), breaks=seq(0,500,25)) + 
  scale_y_log10("Classification time, ms") +
  ggtitle("1-NN Euclidean, DTW, and JMotif runtime comparison, CBF data") +
  theme(plot.title=element_text(size=18),axis.text.x=element_text(size=10), 
        axis.text.y=element_text(size=10),axis.title.x=element_text(size=14), 
        axis.title.y=element_text(size=14))
p1
Cairo(width = 800, height = 600, file="cbf/ppt_comparison_runtime.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
p1
dev.off()


p1 <- ggplot(data, aes(train_size, value, color=variable)) + geom_line() +
  geom_point() + theme_bw() +
  scale_x_continuous("TRAIN dataset size", limits=c(0,50), breaks=seq(0,50,10)) + 
  scale_y_continuous("Classification time, ms",limits=c(0,400000)) +
  ggtitle("1-NN Euclidean, DTW, and JMotif runtime comparison, CBF data") +
  theme(plot.title=element_text(size=18),axis.text.x=element_text(size=10), 
        axis.text.y=element_text(size=10),axis.title.x=element_text(size=14), 
        axis.title.y=element_text(size=14))
p1
Cairo(width = 800, height = 600, file="cbf/ppt_comparison_runtime_c.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
p1
dev.off()


p1 <- ggplot(data, aes(train_size, value, color=variable)) + geom_line() +
  geom_point() + theme_bw() +
  scale_x_continuous("TRAIN dataset size", limits=c(0,50), breaks=seq(0,50,10)) + 
  scale_y_log10("Classification time, ms") +
  ggtitle("1-NN Euclidean, DTW, and JMotif runtime comparison, CBF data") +
  theme(plot.title=element_text(size=18),axis.text.x=element_text(size=10), 
        axis.text.y=element_text(size=10),axis.title.x=element_text(size=14), 
        axis.title.y=element_text(size=14))
p1
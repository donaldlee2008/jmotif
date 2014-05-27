require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require("lattice")

dat=read.csv("../docs/noise3.csv",header=F)
names(dat)=c("train","jmotif_error","euclidean_error","jmotif_time","euclidean_time")

index=sort(unique(dat$train))

jmotif_error=rep(-1,length(index))
for(i in 1:(length(index))){
  jmotif_error[i]=mean(dat[dat$train==index[i],2])
}

euclidean_error=rep(-1,length(index))
for(i in 1:(length(index))){
  euclidean_error[i]=mean(dat[dat$train==index[i],3])
}

d=data.frame(index,euclidean_error,jmotif_error)
dm=melt(d,id.var="index")

p2 <- ggplot(dm, aes(index, value, color=variable)) + geom_line(lwd=1) +
  geom_point() + theme_bw() +
  scale_x_continuous("TRAIN dataset size") + 
  scale_y_log10("Classification error") +
  ggtitle("Euclidean 1-NN and JMotif accuracy comparison, CBF data with loss and noise") +
  theme(plot.title=element_text(size=18),axis.text.x=element_text(size=10), 
        axis.text.y=element_text(size=10),axis.title.x=element_text(size=14), 
        axis.title.y=element_text(size=14))
p2


print(arrangeGrob(p, p1, p2, p3, ncol=2))

Cairo(width = 900, height = 550, file="precision_plot-noise-log10.png", type="png", pointsize=12, 
      bg = "white", canvas = "white", units = "px", dpi = "auto")
print(p)
dev.off()
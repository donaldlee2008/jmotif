require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require("lattice")

gg_color_hue <- function(n) {
  hues = seq(15, 375, length=n+1)
  hcl(h=hues, l=65, c=100)[1:n]
}
cols = gg_color_hue(5)

dat = read.csv("pkdd/corrupted/cbf_noised_3040performance6077_nored.csv",header=F,skip=1)
names(dat)=c("train","jmotif_error","euclidean_error","jmotif_train", "jmotif_time","euclidean_time")

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

d=data.frame(index,jmotif_error,euclidean_error)
dm=melt(d,id.var="index")
p1 <- ggplot(dm, aes(index, value, colour=variable)) + geom_line(lwd=1.3) +
  geom_point(size=4)+ theme_bw() +
  ggtitle("Error rate on corrupted data") +
  scale_x_continuous("TRAIN dataset size") + 
  scale_y_continuous("error, %",limits=c(0,0.5)) +
  scale_colour_discrete(name = element_blank(), labels=c("SAX-VSM", "1NN Euclidean"),
     guide = guide_legend(title.theme=element_text(size=16, angle=0),
     keywidth = 1.5, keyheight = 1, label.theme=element_text(size=13, angle=0))) +
  theme(plot.title=element_text(size=18),
        axis.title.x=element_text(size=16), axis.text.x=element_text(size=12), 
        axis.title.y=element_text(size=18), axis.text.y=element_text(size=14),
        legend.position = "bottom")
p1

dat = read.table("cbf/cbf_damaged.csv",header=F)

dat=t(dat)

ones=(dat[,dat[1,]==0])[-1,1]
twos=(dat[,dat[1,]==1])[-1,1]
threes=(dat[,dat[1,]==2])[-1,1]

# Take the twelve series and melt (or equivalently, stack) them:
dm <- melt(cbind(ones,twos,threes))
# add an index variable:
dm$index <- rep(1:128, 3)
dm$class <- c(rep("Cylinder",(128*1)), rep("Bell",(128*1)), rep("Funnel",(128*1)))

c = ggplot(dm[dm$X2=="ones",], aes(x = index, y = value, group = X2, color="black")) +
  theme_bw() + geom_line(colour="black",lwd=1) + ggtitle("Cylinder") +
  scale_x_continuous("time ticks", limits=c(0,128), breaks=seq(0,128,25)) + 
  scale_y_continuous("Value")+
  theme(plot.title=element_text(size=18),
        axis.text.x=element_blank(), axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),axis.title.y=element_blank())
c
b = ggplot(dm[dm$X2=="twos",], aes(x = index, y = value, group = X2, color="black")) +
  theme_bw() + geom_line(colour="black",lwd=1) + ggtitle("Bell") +
  scale_x_continuous("time ticks", limits=c(0,128), breaks=seq(0,128,25)) + 
  scale_y_continuous("Value")+
  theme(plot.title=element_text(size=18),
        axis.text.x=element_blank(), axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),axis.title.y=element_blank())
b
f = ggplot(dm[dm$X2=="threes",], aes(x = index, y = value, group = X2, color="black")) +
  theme_bw() + geom_line(colour="black",lwd=1) + ggtitle("Funnel") +
  scale_x_continuous("time ticks", limits=c(0,128), breaks=seq(0,128,25)) + 
  scale_y_continuous("Funnel")+
  theme(plot.title=element_text(size=18),
        axis.text.x=element_blank(), axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),axis.title.y=element_blank())
f
#
grid.arrange(arrangeGrob(c, b, f, ncol=3))
Cairo(width = 1000, height = 400, 
      #file="/media/Stock/csdl-techreports/techreports/2011/11-09/figures/precision-runtime", 
      file="/home/psenin/thesis/csdl-techreports/pkdd/figures/cbf_damaged.ps", 
      type="ps", pointsize=18, 
      bg = "transparent", canvas = "white", units = "px", dpi = 82)
grid.arrange(arrangeGrob(c, b, f, ncol=3))
dev.off()
#
# WORDS
#
dat = read.csv("cbf/cbf_words-nored.csv",header=F,skip=1)
names(dat)=c("train_size","Total","Cylinder","Bell","Funnel")
index=sort(unique(dat$train_size))
total=rep(-1,length(index))
cylinder=rep(-1,length(index))
bell=rep(-1,length(index))
funnel=rep(-1,length(index))
for(i in 1:(length(index))){
  total[i]=mean(dat[dat$train_size==index[i],2])
  cylinder[i]=mean(dat[dat$train_size==index[i],3])
  bell[i]=mean(dat[dat$train_size==index[i],4])
  funnel[i]=mean(dat[dat$train_size==index[i],5])
}
#
#
#
d=data.frame(index,total,cylinder,bell,funnel)
dm=melt(d,id.var="index")
p2 <- ggplot(dm, aes(index, value, color=variable)) + geom_line(lwd=1.3) +
  geom_point(size=4)+ theme_bw() +
  scale_x_continuous("TRAIN dataset size") + 
  scale_y_log10("terms",breaks=c(1000,5000,10000,15000)) +
  ggtitle("Terms count in corpus and classes") +
  scale_colour_discrete(name = element_blank(), labels=c("All terms", "Cylinder", "Bell", "Funnel"),
    guide = guide_legend(title.theme=element_text(size=16, angle=0),
    keywidth = 1, keyheight = 1, label.theme=element_text(size=13, angle=0))) +
  theme(plot.title=element_text(size=18),
    axis.title.x=element_text(size=16), axis.text.x=element_text(size=12), 
    axis.title.y=element_text(size=18), axis.text.y=element_text(size=14),
    legend.position = "bottom")
p2

grid.arrange(arrangeGrob(p1, p2, ncol=2, widths=c(1,1)))

Cairo(width = 1100, height = 400, 
      #file="/media/Stock/csdl-techreports/techreports/2011/11-09/figures/precision-runtime", 
      file="/home/psenin/thesis/csdl-techreports/pkdd/figures/precision-words-corrupted", 
      type="ps", pointsize=18, 
      bg = "transparent", canvas = "white", units = "px", dpi = 82)
print(arrangeGrob(p1, p2, ncol=2, widths=c(1,1),clip=F))
dev.off()
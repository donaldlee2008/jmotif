require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require("lattice")

dat = read.table("../data/Adiac/Adiac_TRAIN",header=F)
dat=t(dat)

ones=(dat[,dat[1,]==1])[-1,1]
twos=(dat[,dat[1,]==9])[-1,1]
threes=(dat[,dat[1,]==13])[-1,1]
fours=(dat[,dat[1,]==20])[-1,1]
fives=(dat[,dat[1,]==29])[-1,1]
sixs=(dat[,dat[1,]==35])[-1,2]

# Take the twelve series and melt (or equivalently, stack) them:
dm <- melt(cbind(ones,twos,threes,fours,fives,sixs))
# add an index variable:
dm$index <- rep(1:176, 6)
dm$class <- c(rep("class 1",(176*1)), rep("class 9",(176*1)), rep("class 13",(176*1)),
              rep("class 20",(176*1)), rep("class 29",(176*1)), rep("class 35",(176*1)))

# dm$variable is a factor with a level for each series; use it
# as a grouping variable. dm$value holds the values of each series.

# This produces a 'spaghetti plot' (familiar to mixed modelers):
p = ggplot(dm, aes(x = index, y = value, group = X2, color=class)) +
  theme_bw() + geom_line() + geom_hline(yintercept=0,lty=2) +
  ggtitle("Sample of six classes from Adiac data set") +
  scale_x_continuous("time ticks", limits=c(0,176), breaks=seq(0,176,25)) + 
  scale_y_continuous("Value",limits=c(-2,2),breaks=seq(-2,2,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p
Cairo(width = 750, height = 250, file="adiac/all_classes.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(p)
dev.off()
#
#
#
p1 = ggplot(dm[dm$X2=="ones",], aes(x = index, y = value, group = X2, color="black")) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 1") +
  scale_x_continuous("time ticks", limits=c(0,176), breaks=seq(0,176,25)) + 
  scale_y_continuous("Value",limits=c(-2,2),breaks=seq(-2,2,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p1
#
#
#
p2 = ggplot(dm[dm$X2=="twos",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 7") +
  scale_x_continuous("time ticks", limits=c(0,176), breaks=seq(0,176,25)) + 
  scale_y_continuous("Value",limits=c(-2,2),breaks=seq(-2,2,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p2
#
#
#
p3 = ggplot(dm[dm$X2=="threes",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 13") +
  scale_x_continuous("time ticks", limits=c(0,176), breaks=seq(0,176,25)) + 
  scale_y_continuous("Value",limits=c(-2,2),breaks=seq(-2,2,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p3
#
#
#
p4 = ggplot(dm[dm$X2=="fours",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 20") +
  scale_x_continuous("time ticks", limits=c(0,176), breaks=seq(0,176,25)) + 
  scale_y_continuous("Value",limits=c(-2,2),breaks=seq(-2,2,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p4
#
#
#
p5 = ggplot(dm[dm$X2=="fives",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 29") +
  scale_x_continuous("time ticks", limits=c(0,176), breaks=seq(0,176,25)) + 
  scale_y_continuous("Value",limits=c(-2,2),breaks=seq(-2,2,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p5
#
#
#
p6 = ggplot(dm[dm$X2=="sixs",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 35") +
  scale_x_continuous("time ticks", limits=c(0,176), breaks=seq(0,176,25)) + 
  scale_y_continuous("Value",limits=c(-2,2),breaks=seq(-2,2,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p6
#
#
print(arrangeGrob(p1, p2, p3, p4, p5, p6, ncol=2))

Cairo(width = 750, height = 500, file="adiac/classes.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(p1, p2, p3, p4, p5, p6, ncol=2))
dev.off()

#
#
#
data=read.csv("synthetic/out.single.exact.csv",head=F)
names(data)=c("paa","Alphabet","WINDOW","acc","Error")
min(data$Error)
data=data.frame(data)
d=data[data[3]==40,]
p=wireframe(Error ~ paa * Alphabet, data = d, scales = list(arrows = FALSE),
            drape = TRUE, colorkey = TRUE, pretty=TRUE, screen = list(z = 10, x = -60, y = 00),
            aspect = c(87/97, 0.6),
            xlim=range(data$paa), ylim=range(data$Alphabet), zlim=c(0, 0.9),
            main=paste("Synthetic Control classifier error rate, SLIDING_WINDOW=40"),
            col.regions = terrain.colors(100, alpha = 1) )
p

Cairo(width = 750, height = 600, file="synthetic/parameters.png", type="png", pointsize=12, 
      bg = "white", canvas = "white", units = "px", dpi = "auto")
print(p)
dev.off()
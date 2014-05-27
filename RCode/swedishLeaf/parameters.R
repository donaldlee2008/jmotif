require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require("lattice")

dat = read.table("../data/SwedishLeaf/SwedishLeaf_TRAIN",header=F)
unique(dat[,1])
range(dat[2,])

dat=t(dat)

ones=(dat[,dat[1,]==1])[-1,2]
twos=(dat[,dat[1,]==4])[-1,1]
threes=(dat[,dat[1,]==7])[-1,1]
fours=(dat[,dat[1,]==9])[-1,1]
fives=(dat[,dat[1,]==11])[-1,1]
sixs=(dat[,dat[1,]==13])[-1,2]

# Take the twelve series and melt (or equivalently, stack) them:
dm <- melt(cbind(ones,twos,threes,fours,fives,sixs))
# add an index variable:
dm$index <- rep(1:128, 6)
dm$class <- c(rep("class 1",(128*1)), rep("class 4",(128*1)), rep("class 7",(128*1)),
              rep("class 9",(128*1)), rep("class 11",(128*1)), rep("class 13",(128*1)))

# dm$variable is a factor with a level for each series; use it
# as a grouping variable. dm$value holds the values of each series.

# This produces a 'spaghetti plot' (familiar to mixed modelers):
p = ggplot(dm, aes(x = index, y = value, group = X2, color=class)) +
  theme_bw() + geom_line() + geom_hline(yintercept=0,lty=2) +
  ggtitle("Sample of six classes from Swedish Leaf data set") +
  scale_x_continuous("time ticks", limits=c(0,128), breaks=seq(0,128,25)) + 
  scale_y_continuous("Value",limits=c(-2,2.5),breaks=seq(-2,2.5,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p
Cairo(width = 750, height = 250, file="swedishLeaf/all_classes.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(p)
dev.off()
#
#
#
p1 = ggplot(dm[dm$X2=="ones",], aes(x = index, y = value, group = X2, color="black")) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 1") +
  scale_x_continuous("time ticks", limits=c(0,128), breaks=seq(0,128,25)) + 
  scale_y_continuous("Value",limits=c(-3,2.5),breaks=seq(-3,2.5,1))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p1
#
#
#
p2 = ggplot(dm[dm$X2=="twos",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 4") +
  scale_x_continuous("time ticks", limits=c(0,128), breaks=seq(0,128,25)) + 
  scale_y_continuous("Value",limits=c(-2,2.5),breaks=seq(-2,2.5,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p2
#
#
#
p3 = ggplot(dm[dm$X2=="threes",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 7") +
  scale_x_continuous("time ticks", limits=c(0,128), breaks=seq(0,128,25)) + 
  scale_y_continuous("Value",limits=c(-2,2.5),breaks=seq(-2,2.5,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p3
#
#
#
p4 = ggplot(dm[dm$X2=="fours",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 9") +
  scale_x_continuous("time ticks", limits=c(0,128), breaks=seq(0,128,25)) + 
  scale_y_continuous("Value",limits=c(-2,2.5),breaks=seq(-2,2.5,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p4
#
#
#
p5 = ggplot(dm[dm$X2=="fives",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 11") +
  scale_x_continuous("time ticks", limits=c(0,128), breaks=seq(0,128,25)) + 
  scale_y_continuous("Value",limits=c(-2,2.5),breaks=seq(-2,2.5,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p5
#
#
#
p6 = ggplot(dm[dm$X2=="sixs",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 13") +
  scale_x_continuous("time ticks", limits=c(0,128), breaks=seq(0,128,25)) + 
  scale_y_continuous("Value",limits=c(-2,2.5),breaks=seq(-2,2.5,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p6
#
#
print(arrangeGrob(p1, p2, p3, p4, p5, p6, ncol=2))

Cairo(width = 750, height = 500, file="swedishLeaf/classes.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(p1, p2, p3, p4, p5, p6, ncol=2))
dev.off()


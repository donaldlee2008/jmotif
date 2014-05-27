require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require("lattice")

dat = read.table("../data/OSULeaf/OSULeaf_TRAIN",header=F)
unique(dat[,1])
range(dat[2,])


dat=t(dat)

ones=(dat[,dat[1,]==1])[-1,1]
twos=(dat[,dat[1,]==2])[-1,1]
threes=(dat[,dat[1,]==3])[-1,1]
fours=(dat[,dat[1,]==4])[-1,1]
fives=(dat[,dat[1,]==5])[-1,1]
sixs=(dat[,dat[1,]==6])[-1,2]

# Take the twelve series and melt (or equivalently, stack) them:
dm <- melt(cbind(ones,twos,threes,fours,fives,sixs))
# add an index variable:
dm$index <- rep(1:427, 6)
dm$class <- c(rep("One",(427*1)), rep("Two",(427*1)), rep("Three",(427*1)),
              rep("Four",(427*1)), rep("Five",(427*1)), rep("Six",(427*1)))

# dm$variable is a factor with a level for each series; use it
# as a grouping variable. dm$value holds the values of each series.

# This produces a 'spaghetti plot' (familiar to mixed modelers):
p = ggplot(dm, aes(x = index, y = value, group = X2, color=class)) +
  theme_bw() + geom_line() + geom_hline(yintercept=0,lty=2) +
  ggtitle("Sample of six classes from OSU Leaf set") +
  scale_x_continuous("time ticks", limits=c(0,427), breaks=seq(0,427,25)) + 
  scale_y_continuous("Value",limits=c(-2.3,3.2),breaks=seq(-2.3,3.2,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p
Cairo(width = 750, height = 250, file="OSULeaf/all_classes.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(p)
dev.off()
#
#
#
d = dm[dm$X2=="ones",]
di=d
di$value[1:358]=NA
di$value[398:427]=NA
di$X2="Best Pattern"
p1 = ggplot(rbind(d,di), aes(x = index, y = value, group = X2, color=X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 1") +
  scale_x_continuous("time ticks", limits=c(0,427), breaks=seq(0,427,50)) + 
  scale_y_continuous("Value",limits=c(-2.3,3.2),breaks=seq(-2.3,3.2,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p1
#
#
#
p2 = ggplot(dm[dm$X2=="twos",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 2") +
  scale_x_continuous("time ticks", limits=c(0,427), breaks=seq(0,427,50)) + 
  scale_y_continuous("Value",limits=c(-2.3,3.2),breaks=seq(-2.3,3.2,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p2
#
#
#
p3 = ggplot(dm[dm$X2=="threes",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 3") +
  scale_x_continuous("time ticks", limits=c(0,427), breaks=seq(0,427,50)) + 
  scale_y_continuous("Value",limits=c(-2.3,3.2),breaks=seq(-2.3,3.2,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p3
#
#
#
p4 = ggplot(dm[dm$X2=="fours",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 4") +
  scale_x_continuous("time ticks", limits=c(0,427), breaks=seq(0,427,50)) + 
  scale_y_continuous("Value",limits=c(-2.3,3.2),breaks=seq(-2.3,3.2,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p4
#
#
#
p5 = ggplot(dm[dm$X2=="fives",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 5") +
  scale_x_continuous("time ticks", limits=c(0,427), breaks=seq(0,427,50)) + 
  scale_y_continuous("Value",limits=c(-2.3,3.2),breaks=seq(-2.3,3.2,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p5
#
#
#
p6 = ggplot(dm[dm$X2=="sixs",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 6") +
  scale_x_continuous("time ticks", limits=c(0,427), breaks=seq(0,427,50)) + 
  scale_y_continuous("Value",limits=c(-2.3,3.2),breaks=seq(-2.3,3.2,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p6
#
#
print(arrangeGrob(p1, p2, p3, p4, p5, p6, ncol=2))

Cairo(width = 750, height = 500, file="OSULeaf/classes.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(p1, p2, p3, p4, p5, p6, ncol=2))
dev.off()


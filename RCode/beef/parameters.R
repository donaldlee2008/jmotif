require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require("lattice")

dat = read.table("../data/Beef/Beef_TRAIN",header=F)

dat=t(dat)

ones=(dat[,dat[1,]==1])[-1,1]
twos=(dat[,dat[1,]==2])[-1,1]
threes=(dat[,dat[1,]==3])[-1,1]
fours=(dat[,dat[1,]==4])[-1,1]
fives=(dat[,dat[1,]==5])[-1,1]
max(c(ones,twos,threes,fours,fives))
# Take the twelve series and melt (or equivalently, stack) them:
dm <- melt(cbind(ones,twos,threes,fours,fives))
# add an index variable:
dm$index <- rep(1:470, 5)
dm$class <- c(rep("One",(470*1)), rep("Two",(470*1)), rep("Three",(470*1)),
              rep("Four",(470*1)), rep("Five",(470*1)))

# dm$variable is a factor with a level for each series; use it
# as a grouping variable. dm$value holds the values of each series.

# This produces a 'spaghetti plot' (familiar to mixed modelers):
p = ggplot(dm, aes(x = index, y = value, group = X2, color=class)) +
  theme_bw() + geom_line() + geom_hline(yintercept=0,lty=2) +
  ggtitle("Sample of five classes from Beef dataset") +
  scale_x_continuous("time ticks", limits=c(0,470), breaks=seq(0,470,25)) + 
  scale_y_continuous("Value",limits=c(0,0.35),breaks=seq(0,0.35,0.05))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p
Cairo(width = 750, height = 250, file="beef/all_classes.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(p)
dev.off()
#
#
#
p1 = ggplot(dm[dm$X2=="ones",], aes(x = index, y = value, group = X2, color="black")) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 1") +
  scale_x_continuous("time ticks", limits=c(0,470), breaks=seq(0,470,50)) + 
  scale_y_continuous("Value",limits=c(0,0.35),breaks=seq(0,0.35,0.05))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p1
#
#
#
p2 = ggplot(dm[dm$X2=="twos",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 2") +
  scale_x_continuous("time ticks", limits=c(0,470), breaks=seq(0,470,50)) + 
  scale_y_continuous("Value",limits=c(0,0.35),breaks=seq(0,0.35,0.05))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p2
#
#
#
p3 = ggplot(dm[dm$X2=="threes",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 3") +
  scale_x_continuous("time ticks", limits=c(0,470), breaks=seq(0,470,50)) + 
  scale_y_continuous("Value",limits=c(0,0.35),breaks=seq(0,0.35,0.05))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p3
#
#
#
p4 = ggplot(dm[dm$X2=="fours",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 4") +
  scale_x_continuous("time ticks", limits=c(0,470), breaks=seq(0,470,50)) + 
  scale_y_continuous("Value",limits=c(0,0.35),breaks=seq(0,0.35,0.05))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p4
#
#
#
p5 = ggplot(dm[dm$X2=="fives",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 5") +
  scale_x_continuous("time ticks", limits=c(0,470), breaks=seq(0,470,50)) + 
  scale_y_continuous("Value",limits=c(0,0.35),breaks=seq(0,0.35,0.05))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p5
#
#
print(arrangeGrob(p1, p2, p3, p4, p5, ncol=2))

Cairo(width = 750, height = 500, file="beef/classes.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(p1, p2, p3, p4, p5, ncol=2))
dev.off()

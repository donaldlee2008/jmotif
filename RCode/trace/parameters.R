require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require("lattice")

dat = read.table("../data/Trace/Trace_TRAIN",header=F)

dat=t(dat)

ones=(dat[,dat[1,]==1])[-1,3]
twos=(dat[,dat[1,]==2])[-1,1]
threes=(dat[,dat[1,]==3])[-1,1]
fours=(dat[,dat[1,]==4])[-1,1]

# Take the twelve series and melt (or equivalently, stack) them:
dm <- melt(cbind(ones,twos,threes,fours))
# add an index variable:
dm$index <- rep(1:275, 4)
dm$class <- c(rep("One",(275*1)), rep("Two",(275*1)), rep("Three",(275*1)),
              rep("Four",(275*1)))

# dm$variable is a factor with a level for each series; use it
# as a grouping variable. dm$value holds the values of each series.

# This produces a 'spaghetti plot' (familiar to mixed modelers):
p = ggplot(dm, aes(x = index, y = value, group = X2, color=class)) +
  theme_bw() + geom_line() + geom_hline(yintercept=0,lty=2) +
  ggtitle("Sample of four classes from Trace dataset") +
  scale_x_continuous("time ticks", limits=c(0,275), breaks=seq(0,275,25)) + 
  scale_y_continuous("Value",limits=c(-2.5,4),breaks=seq(-2.5,4,1))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p
Cairo(width = 750, height = 250, file="trace/all_classes.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(p)
dev.off()
#
#
#
p1 = ggplot(dm[dm$X2=="ones",], aes(x = index, y = value, group = X2, color="black")) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 1") +
  scale_x_continuous("time ticks", limits=c(0,275), breaks=seq(0,275,50)) + 
  scale_y_continuous("Value",limits=c(-2.5,4),breaks=seq(-2.5,4,1))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p1
#
#
#
p2 = ggplot(dm[dm$X2=="twos",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 2") +
  scale_x_continuous("time ticks", limits=c(0,275), breaks=seq(0,275,50)) + 
  scale_y_continuous("Value",limits=c(-2.5,4),breaks=seq(-2.5,4,1))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p2
#
#
#
p3 = ggplot(dm[dm$X2=="threes",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 3") +
  scale_x_continuous("time ticks", limits=c(0,275), breaks=seq(0,275,50)) + 
  scale_y_continuous("Value",limits=c(-2.5,4),breaks=seq(-2.5,4,1))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p3
#
#
#
p4 = ggplot(dm[dm$X2=="fours",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 4") +
  scale_x_continuous("time ticks", limits=c(0,275), breaks=seq(0,275,50)) + 
  scale_y_continuous("Value",limits=c(-2.5,4),breaks=seq(-2.5,4,1))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p4
#
#
print(arrangeGrob(p1, p2, p3, p4, ncol=2))

Cairo(width = 750, height = 400, file="trace/classes.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(p1, p2, p3, p4, ncol=2))
dev.off()

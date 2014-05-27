require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require("lattice")

dat = read.csv("../data/arrowhead/arrowhead_train",sep=' ',header=F)
unique(dat[,1])

dat=t(dat)

ones=(dat[,dat[1,]==0])[-1,1]
twos=(dat[,dat[1,]==1])[-1,1]
threes=(dat[,dat[1,]==2])[-1,1]

# Take the twelve series and melt (or equivalently, stack) them:
dm <- melt(cbind(ones,twos,threes))
# add an index variable:
dm$index <- rep(1:623, 3)
dm$class <- c(rep("Class 0",(623*1)), rep("Class 1",(623*1)), rep("Class 2",(623*1)))

# dm$variable is a factor with a level for each series; use it
# as a grouping variable. dm$value holds the values of each series.

# This produces a 'spaghetti plot' (familiar to mixed modelers):
p = ggplot(dm, aes(x = index, y = value, group = X2, color=class)) +
  theme_bw() + geom_line() + geom_hline(yintercept=0,lty=2) +
  ggtitle("Sample of three classes from Projectile dataset") +
  scale_x_continuous("time ticks", limits=c(0,625), breaks=seq(0,625,25)) + 
  scale_y_continuous("Value",limits=c(-2.5,0.5),breaks=seq(-2.5,0.5,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p

Cairo(width = 750, height = 250, file="chlorine/all_classes.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(p)
dev.off()
#
#
#
p1 = ggplot(dm[dm$X2=="ones",], aes(x = index, y = value, group = X2, color="black")) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 1") +
  scale_x_continuous("time ticks", limits=c(0,166), breaks=seq(0,166,25)) + 
  scale_y_continuous("Value",limits=c(-1.2,4.2),breaks=seq(-2,5,1))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p1
#
#
#
p2 = ggplot(dm[dm$X2=="twos",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 2") +
  scale_x_continuous("time ticks", limits=c(0,166), breaks=seq(0,166,25)) + 
  scale_y_continuous("Value",limits=c(-1.2,4.2),breaks=seq(-2,5,1))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p2
#
#
#
p3 = ggplot(dm[dm$X2=="threes",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 3") +
  scale_x_continuous("time ticks", limits=c(0,166), breaks=seq(0,166,25)) + 
  scale_y_continuous("Value",limits=c(-1.2,4.2),breaks=seq(-2,5,1))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p3

print(arrangeGrob(p1, p2, p3, ncol=3))

Cairo(width = 750, height = 350, file="chlorine/classes.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(p1, p2, p3, ncol=2))
dev.off()


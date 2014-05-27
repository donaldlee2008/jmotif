require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require("lattice")

dat = read.table("../data/Cricket/Cricket_TRAIN",header=F)
unique(dat[,1])

dat=t(dat)
ones=(dat[,dat[1,]==1])[-1,1]
twos=(dat[,dat[1,]==2])[-1,1]
range(twos)
# Take the twelve series and melt (or equivalently, stack) them:
dm <- melt(cbind(ones,twos))
# add an index variable:
dm$index <- rep(1:308, 2)
dm$class <- c(rep("Class 1",(308*1)), rep("Class 2",(308*1)))

# dm$variable is a factor with a level for each series; use it
# as a grouping variable. dm$value holds the values of each series.

# This produces a 'spaghetti plot' (familiar to mixed modelers):
p = ggplot(dm, aes(x = index, y = value, group = X2, color=class)) +
  theme_bw() + geom_line() + geom_hline(yintercept=0,lty=2) +
  ggtitle("Sample of two classes from Cricket dataset") +
  scale_x_continuous("time ticks", limits=c(0,310), breaks=seq(0,310,50)) + 
  scale_y_continuous("Value",limits=c(-0.2,0.1),breaks=seq(-0.2,0.2,0.05))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p
Cairo(width = 750, height = 250, file="cricket/all_classes.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(p)
dev.off()
#
#
#
p1 = ggplot(dm[dm$X2=="ones",], aes(x = index, y = value, group = X2, color="black")) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Cricket dataset, Class 1") +
  scale_x_continuous("time ticks", limits=c(0,310), breaks=seq(0,310,50)) + 
  scale_y_continuous("Value",limits=c(-0.2,0.1),breaks=seq(-0.2,0.2,0.05))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p1
#
#
#
p2 = ggplot(dm[dm$X2=="twos",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Cricket dataset, Class 2") +
  scale_x_continuous("time ticks", limits=c(0,310), breaks=seq(0,310,50)) + 
  scale_y_continuous("Value",limits=c(-0.2,0.1),breaks=seq(-0.2,0.2,0.05))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p2
#
#
#
print(arrangeGrob(p1, p2, ncol=2))

Cairo(width = 750, height = 200, file="cricket/classes.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(p1, p2, ncol=2))
dev.off()
#
#
dat2 = read.table("../data/Cricket/Cricket_new_TEST",header=F)
dat2=t(dat2)
ones2=(dat2[,dat[1,]==1])[-1,1]
twos2=(dat2[,dat[1,]==2])[-1,1]
range(twos)
# Take the twelve series and melt (or equivalently, stack) them:
dm2 <- melt(cbind(ones2,twos2))
# add an index variable:
dm2$index <- rep(1:599, 2)
dm2$class <- c(rep("Class 1",(599*1)), rep("Class 2",(599*1)))

# dm$variable is a factor with a level for each series; use it
# as a grouping variable. dm$value holds the values of each series.

# This produces a 'spaghetti plot' (familiar to mixed modelers):
p = ggplot(dm2, aes(x = index, y = value, group = X2, color=class)) +
  theme_bw() + geom_line() + geom_hline(yintercept=0,lty=2) +
  ggtitle("Sample of two classes from Cricket NEW dataset") +
  scale_x_continuous("time ticks", limits=c(0,610), breaks=seq(0,610,50)) + 
  scale_y_continuous("Value",limits=c(-13,20),breaks=seq(-13,20,5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p

Cairo(width = 750, height = 250, file="cricket/all_classes_new.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(p)
dev.off()
#
#
#
p1 = ggplot(dm2[dm2$X2=="ones2",], aes(x = index, y = value, group = X2, color="black")) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Cricket NEW dataset, Class 1") +
  scale_x_continuous("time ticks", limits=c(0,610), breaks=seq(0,610,50)) + 
  scale_y_continuous("Value",limits=c(-13,20),breaks=seq(-13,20,5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p1
#
#
#
p2 = ggplot(dm2[dm2$X2=="twos2",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Cricket NEW dataset, Class 2") +
  scale_x_continuous("time ticks", limits=c(0,610), breaks=seq(0,610,50)) + 
  scale_y_continuous("Value",limits=c(-13,20),breaks=seq(-13,20,5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p2
#
#
#
print(arrangeGrob(p1, p2, ncol=2))

Cairo(width = 750, height = 200, file="cricket/classes_new.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(p1, p2, ncol=2))
dev.off()
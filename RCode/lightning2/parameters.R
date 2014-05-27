require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require("lattice")

dat = read.table("../data/Lighting2/Lighting2_TRAIN",header=F)
unique(dat[,1])

dat=t(dat)
ones=(dat[,dat[1,]==-1])[-1,1]
twos=(dat[,dat[1,]==1])[-1,1]
# Take the twelve series and melt (or equivalently, stack) them:
dm <- melt(cbind(ones,twos))
# add an index variable:
dm$index <- rep(1:637, 2)
dm$class <- c(rep("Class 1",(637*1)), rep("Class 2",(637*1)))

# dm$variable is a factor with a level for each series; use it
# as a grouping variable. dm$value holds the values of each series.

# This produces a 'spaghetti plot' (familiar to mixed modelers):
p = ggplot(dm, aes(x = index, y = value, group = X2, color=class)) +
  theme_bw() + geom_line() + geom_hline(yintercept=0,lty=2) +
  ggtitle("Sample of two classes from Lightning2 dataset") +
  scale_x_continuous("time ticks", limits=c(0,637), breaks=seq(0,637,100)) + 
  scale_y_continuous("Value",limits=c(-1.5,3.5),breaks=seq(-1.5,3.5,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p
Cairo(width = 750, height = 250, file="lightning2/all_classes.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(p)
dev.off()
#
#
#
p1 = ggplot(dm[dm$X2=="ones",], aes(x = index, y = value, group = X2, color="black")) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Lightning2 dataset, Class 1") +
  scale_x_continuous("time ticks", limits=c(0,637), breaks=seq(0,637,100)) + 
  scale_y_continuous("Value",limits=c(-1.5,3.5),breaks=seq(-1.5,3.5,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p1
#
#
#
p2 = ggplot(dm[dm$X2=="twos",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Lightning2 dataset, Class 2") +
  scale_x_continuous("time ticks", limits=c(0,637), breaks=seq(0,637,100)) + 
  scale_y_continuous("Value",limits=c(-1.5,3.5),breaks=seq(-1.5,3.5,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p2
#
#
#
print(arrangeGrob(p1, p2, ncol=2))

Cairo(width = 750, height = 200, file="lightning2/classes.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(p1, p2, ncol=2))
dev.off()

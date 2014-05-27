require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require(lattice)

dat = read.table("../data/CBF/CBF_TRAIN",header=F)

dat=t(dat)

ones=(dat[,dat[1,]==1])[-1,1]
twos=(dat[,dat[1,]==2])[-1,1]
threes=(dat[,dat[1,]==3])[-1,1]

# Take the twelve series and melt (or equivalently, stack) them:
dm <- melt(cbind(ones,twos,threes))
# add an index variable:
dm$index <- rep(1:128, 3)
dm$class <- c(rep("Cylinder",(128*1)), rep("Bell",(128*1)), rep("Funnel",(128*1)))

# dm$variable is a factor with a level for each series; use it
# as a grouping variable. dm$value holds the values of each series.

# This produces a 'spaghetti plot' (familiar to mixed modelers):
p = ggplot(dm, aes(x = index, y = value, group = X2, color=class)) +
  theme_bw() + geom_line() + geom_hline(yintercept=0,lty=2) +
  ggtitle("Sample of three CBF classes") +
  scale_x_continuous("time", limits=c(0,128), breaks=seq(0,128,25)) + 
  scale_y_continuous("Value",limits=c(-2,3),breaks=seq(-2,3,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p

#
#
#
p1 = ggplot(dm[dm$X2=="ones",], aes(x = index, y = value, group = X2, color="black")) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 1, Cylinder") +
  scale_x_continuous("time", limits=c(0,128), breaks=seq(0,128,25)) + 
  scale_y_continuous("Value",limits=c(-2,3),breaks=seq(-2,3,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p1
#
#
#
p2 = ggplot(dm[dm$X2=="twos",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 2, Bell") +
  scale_x_continuous("time", limits=c(0,128), breaks=seq(0,128,25)) + 
  scale_y_continuous("Value",limits=c(-2,3),breaks=seq(-2,3,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p2
#
#
#
p3 = ggplot(dm[dm$X2=="threes",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 3, Funnel") +
  scale_x_continuous("time", limits=c(0,128), breaks=seq(0,128,25)) + 
  scale_y_continuous("Value",limits=c(-2,3),breaks=seq(-2,3,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p3

Cairo(width = 1200, height = 350, 
      file="thesis/cbf.ps", 
      type="ps", pointsize=10, 
      bg = "transparent", canvas = "white", units = "px", dpi = 82)
grid.arrange(arrangeGrob(p1, p2, p3, ncol=3, clip=F))
dev.off()

df=data.frame("Funnel 1"=(dat[,dat[1,]==3])[-1,8],
              "Funnel 2"=(dat[,dat[1,]==3])[-1,2],
              "Funnel 3"=(dat[,dat[1,]==3])[-1,1])

# Take the twelve series and melt (or equivalently, stack) them:
dm <- melt(df)
# add an index variable:
dm$index <- rep(1:128, 3)

p4 = ggplot(dm, aes(x = index, y = value, linetype=variable)) +
  theme_bw() + geom_line() + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 3, Funnel") +
  scale_x_continuous("time", limits=c(0,128), breaks=seq(0,128,25)) + 
  scale_y_continuous("Value",limits=c(-2,3.1),breaks=seq(-2,3,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p4

Cairo(width = 1200, height = 350, 
      file="thesis/funnels.ps", 
      type="ps", pointsize=10, 
      bg = "transparent", canvas = "white", units = "px", dpi = 82)
print(p4)
grid.arrange(arrangeGrob(p1,p2,p3, ncol=3), p4, ncol=1)
dev.off()



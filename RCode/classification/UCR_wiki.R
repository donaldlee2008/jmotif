require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)

dat = read.csv("clustering/train.ucr.dat",header=F,sep=",")

dat=t(dat)

ones=(dat[,dat[1,]==1])[-1,1]
twos=(dat[,dat[1,]==2])[-1,1]
threes=(dat[,dat[1,]==3])[-1,1]
fours=(dat[,dat[1,]==4])[-1,1]
fives=(dat[,dat[1,]==5])[-1,1]
sixs=(dat[,dat[1,]==6])[-1,1]

# Take the twelve series and melt (or equivalently, stack) them:
dm <- melt(cbind(ones,twos,threes,fours,fives,sixs))
# add an index variable:
dm$index <- rep(1:60, 6)
dm$class <- c(rep("One",(60*1)), rep("Two",(60*1)), rep("Three",(60*1)),
              rep("Four",(60*1)), rep("Five",(60*1)), rep("Six",(60*1)))

# dm$variable is a factor with a level for each series; use it
# as a grouping variable. dm$value holds the values of each series.

# This produces a 'spaghetti plot' (familiar to mixed modelers):
p = ggplot(dm, aes(x = index, y = value, group = X2, color=class)) +
  theme_bw() + geom_line(alpha=0.3, lwd=1.8) +geom_line(alpha=1, lwd=0.3) + 
  ggtitle("Sample of three classes from UCR Synthetic Control set") +
  scale_x_continuous("time ticks", limits=c(0,60), breaks=seq(0,60,5)) + 
  scale_y_continuous("Value",limits=c(-2.3,2.3),breaks=seq(-2,2,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p

Cairo(width = 800, height = 300, file="clustering/first_glance.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(p)
dev.off()
#
#
#
#
dat = read.csv("gun/gun.train.dat",header=F,sep=",")

dat=t(dat)

ones=(dat[,dat[1,]==1])[-1,1:3]
zeroes=(dat[,dat[1,]==0])[-1,1:3]

# Take the twelve series and melt (or equivalently, stack) them:
dm <- melt(cbind(ones,zeroes))
# add an index variable:
dm$index <- rep(1:150, 6)
dm$class <- c(rep("No Gun",(150*3)), rep("Gun",(150*3)))

# dm$variable is a factor with a level for each series; use it
# as a grouping variable. dm$value holds the values of each series.

# This produces a 'spaghetti plot' (familiar to mixed modelers):
p = ggplot(dm, aes(x = index, y = value, group = X2, color=class,lty=class)) +
  theme_bw() + geom_line(alpha=0.8, lwd=0.8) + 
  ggtitle("Sample of data classes from Gun/NoGun set") +
  scale_x_continuous("time ticks", limits=c(0,150), breaks=seq(0,150,25)) + 
  scale_y_continuous("Value",limits=c(-1.5,2.5),breaks=seq(-2,2,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p

Cairo(width = 800, height = 450, file="gun/gun_no_gun.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(p)
dev.off()

#
#
#
#
znorm <- function(ts){
  ts.mean <- mean(ts[1,])
  ts.dev <- sd(ts[1,])
  (ts - ts.mean)/ts.dev
}

dat = t(t(read.csv("Coffee/coffee.ucr.train",header=F,sep=",")))

ones=cbind(znorm((dat[dat[,1]==1,])[1,-1]),znorm(dat[,dat[1,]==1])[-1,1])

dat=t(dat)
len=length(dat[,1])-1
  
ones=cbind(znorm(dat[,dat[1,]==1][-1,1]),znorm(dat[,dat[1,]==1])[-1,1])
zeroes=znorm((dat[,dat[1,]==0])[-1,1:3])

# Take the twelve series and melt (or equivalently, stack) them:
dm <- melt(cbind(ones,zeroes))
# add an index variable:
dm$index <- rep(1:len, 6)
dm$class <- c(rep("1",(len*3)), rep("0",(len*3)))

# dm$variable is a factor with a level for each series; use it
# as a grouping variable. dm$value holds the values of each series.

# This produces a 'spaghetti plot' (familiar to mixed modelers):
p = ggplot(dm, aes(x = index, y = value, group = X2, color=class,lty=class)) +
  theme_bw() + geom_line(alpha=0.8, lwd=0.8) + 
  ggtitle("Sample of data classes from Gun/NoGun set") +
  scale_x_continuous("time ticks", limits=c(0,len), breaks=seq(0,len,15)) + 
  scale_y_continuous("Value",limits=range(ones),breaks=seq(-2,2,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p

Cairo(width = 800, height = 450, file="clustering/gun_no_gun.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(p)
dev.off()

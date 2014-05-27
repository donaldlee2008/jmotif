require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
#
znorm <- function(ts){
  ts.mean <- mean(ts)
  ts.dev <- sd(ts)
  (ts - ts.mean)/ts.dev
}
#
dat = read.table("../data/Gun_Point/Gun_Point_TRAIN",header=F)
#
class=2
frame=25
series=c(0,1,2,4,7)+1
offsets=c(91,86,76,108,87)+1
#
#
pre_series=(dat[dat[,1]==class,-1])[series[1],]
for(i in 2:(length(series))){
  pre_series = rbind(pre_series, (dat[dat[,1]==class,-1])[series[i],])
}
subseries=znorm(as.numeric((pre_series[1,])[(offsets[1]):(offsets[1]+25)]))
for(i in 2:(length(offsets))){
  piece=znorm(as.numeric(((pre_series[i,])[(offsets[i]):(offsets[i]+25)])))
  subseries = rbind(subseries, piece)
}
#
row.names(subseries)=c(paste("series",series,sep=""))
#
dm=melt(subseries)
names(dm)=c("series","x","value")
p3 = ggplot(dm, aes(x = x, y = value, group = series, color=series)) + 
  geom_line()+ theme_bw() + ggtitle("Best pattern of Class 2")
p3
#
#
#
#
class=2
frame=25
series=c(3,5,6,8,9)+1
offsets=c(27,6,0,27,28)+1
#
#
pre_series=(dat[dat[,1]==class,-1])[series[1],]
for(i in 2:(length(series))){
  pre_series = rbind(pre_series, (dat[dat[,1]==class,-1])[series[i],])
}
subseries=znorm(as.numeric((pre_series[1,])[(offsets[1]):(offsets[1]+25)]))
for(i in 2:(length(offsets))){
  piece=znorm(as.numeric(((pre_series[i,])[(offsets[i]):(offsets[i]+25)])))
  subseries = rbind(subseries, piece)
}
#
row.names(subseries)=c(paste("series",series,sep=""))
#
dm=melt(subseries)
names(dm)=c("series","x","value")
p4 = ggplot(dm, aes(x = x, y = value, group = series, color=series)) +
  geom_line()+ theme_bw() + 
  ggtitle("Second best pattern of Class 2")
p4
#
#
#
class=1
frame=25
series=c(0,2,4,5,11)+1
offsets=c(35,19,1,4,21)+1
#
#
pre_series=(dat[dat[,1]==class,-1])[series[1],]
for(i in 2:(length(series))){
  pre_series = rbind(pre_series, (dat[dat[,1]==class,-1])[series[i],])
}
subseries=znorm(as.numeric((pre_series[1,])[(offsets[1]):(offsets[1]+25)]))
for(i in 2:(length(offsets))){
  piece=znorm(as.numeric(((pre_series[i,])[(offsets[i]):(offsets[i]+25)])))
  subseries = rbind(subseries, piece)
}
#
row.names(subseries)=c(paste("series",series,sep=""))
#
dm=melt(subseries)
names(dm)=c("series","x","value")
p1 = ggplot(dm, aes(x = x, y = value, group = series, color=series)) +
  geom_line()+ theme_bw() + 
  ggtitle("Best pattern of Class 1")
p1
#
#
#
class=1
frame=25
series=c(3,4,6,7,8)+1
offsets=c(96,109,109,109,107)+1
#
#
pre_series=(dat[dat[,1]==class,-1])[series[1],]
for(i in 2:(length(series))){
  pre_series = rbind(pre_series, (dat[dat[,1]==class,-1])[series[i],])
}
subseries=znorm(as.numeric((pre_series[1,])[(offsets[1]):(offsets[1]+25)]))
for(i in 2:(length(offsets))){
  piece=znorm(as.numeric(((pre_series[i,])[(offsets[i]):(offsets[i]+25)])))
  subseries = rbind(subseries, piece)
}
#
row.names(subseries)=c(paste("series",series,sep=""))
#
dm=melt(subseries)
names(dm)=c("series","x","value")
p2 = ggplot(dm, aes(x = x, y = value, group = series, color=series)) + 
  geom_line() + theme_bw() + 
  ggtitle("Second best pattern of Class 1")
p2

print(arrangeGrob(p1, p2, p3, p4, ncol=2))

#
#
#
#



#
dm <- melt(t(pre_series[,-1]))
# add an index variable:
dm$index <- rep(1:150, 5)
dm$class <- c(rep("0",150),rep("1",150),rep("2",150),rep("4",150),rep("7",150))

# dm$variable is a factor with a level for each series; use it
# as a grouping variable. dm$value holds the values of each series.

# This produces a 'spaghetti plot' (familiar to mixed modelers):
p = ggplot(dm, aes(x = index, y = value, group = X2, color=class, lty=class)) +
  theme_bw() + geom_line(alpha=0.8, lwd=0.8) + geom_vline(xintercept=offsets) +
  ggtitle("Sample of data classes from Gun/NoGun set") +
  scale_x_continuous("time ticks", limits=c(0,150), breaks=seq(0,150,5)) + 
  scale_y_continuous("Value",limits=c(-1.5,2.5),breaks=seq(-2,2,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p


subseries=as.numeric((pre_series[1,])[(offsets[1]):(offsets[1]+25)])
for(i in 2:(length(offsets))){
  piece=as.numeric(((pre_series[i,])[(offsets[i]):(offsets[i]+25)]))
  subseries = rbind(subseries, piece)
}

data=subseries[,-1]
row.names(data)=c(paste("series",series,sep=""))

dm=melt(data)
names(dm)=c("series","x","value")
p = ggplot(dm, aes(x = x, y = value, group = series, color=series)) + geom_line()
p

dat=t(dat)
ones=(dat[,dat[1,]==2])[-1,1:3]
zeroes=(dat[,dat[1,]==1])[-1,1:3]

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
xstart=75

znorm=c(2.0169139, 2.0169139, 2.0199612, 2.0227683, 2.0267428, 2.0298266, 2.0267712, 2.023226,
        2.0186854, 2.0114456, 1.9896683, 1.9277158, 1.83758, 1.6943583, 1.5212096, 1.3611026,
        1.2183468, 1.075179, 0.95556752, 0.83104282, 0.68869182, 0.52235852, 0.49684735,
        0.30738683, 0.033138263, -0.18203968, -0.33481372, -0.47058911, -0.617252, -0.732267,
        -0.80943854, -0.85853773, -0.87031609, -0.86164539, -0.83881457, -0.80939495, -0.79221792,
        -0.77831912, -0.75982256, -0.74043045)

paa=c(1.1490789804802726, 1.1534081405383518, 1.0691477159836669, 0.5975210026328025, 
      0.08222422329235628, -0.49101756465795987, -1.089455085705295, -1.2689035445693202, -1.2020038679948726)

dat=cbind(ones[75:114,],zeroes[75:114,],t(t(znorm)))
dm <- melt(dat)
# add an index variable:
dm$index <- rep(1:40, 7)
dm$class <- c(rep("No Gun",(40*3)), rep("Gun",(40*3)), rep("Pattern",(40)))

# dm$variable is a factor with a level for each series; use it
# as a grouping variable. dm$value holds the values of each series.

# This produces a 'spaghetti plot' (familiar to mixed modelers):
p = ggplot(dm, aes(x = index, y = value, group = X2, color=class,lty=class)) +
  theme_bw() + geom_line(alpha=0.8, lwd=0.8) +
  ggtitle("Sample of data classes from Gun/NoGun set") +
  scale_x_continuous("time ticks", limits=c(0,40), breaks=seq(0,40,5)) + 
  scale_y_continuous("Value",limits=c(-1.5,2.5),breaks=seq(-2,2,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p
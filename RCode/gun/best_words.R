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
row.names(subseries)=c(paste("#", series))
#
dm=melt(subseries)
names(dm)=c("series","x","value")
p3 = ggplot(dm, aes(x = x, y = value, group = series, color=series)) + 
  geom_line()+ theme_bw() + ggtitle("Best pattern of Class 2") +
  scale_colour_discrete(name = "Series index:",
    guide = guide_legend(title.theme=element_text(size=14, angle=0),
    keywidth = 1, keyheight = 1.5, label.theme=element_text(size=14, angle=0))) +
  theme(plot.title=element_text(size=18),
        axis.text.x=element_blank(), axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),axis.title.y=element_blank())

p3 <- ggplot_gtable(ggplot_build(p3))
p3$heights[[2]] <- p3$heights[[2]]+unit(0.5, "lines")
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
row.names(subseries)=c(paste("#", series))
#
dm=melt(subseries)
names(dm)=c("series","x","value")
p4 = ggplot(dm, aes(x = x, y = value, group = series, color=series)) +
  geom_line()+ theme_bw() + ggtitle("Second best pattern of Class 2") +
  scale_colour_discrete(name = "Series index:",
    guide = guide_legend(title.theme=element_text(size=14, angle=0),
    keywidth = 1, keyheight = 1.5, label.theme=element_text(size=14, angle=0))) +
  theme(plot.title=element_text(size=18),
        axis.text.x=element_blank(), axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),axis.title.y=element_blank())

p4<- ggplot_gtable(ggplot_build(p4))
p4$heights[[2]] <- p4$heights[[2]]+unit(0.5, "lines")
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
row.names(subseries)=c(paste("#", series))
#
dm=melt(subseries)
names(dm)=c("series","x","value")
p1 = ggplot(dm, aes(x = x, y = value, group = series, color=series)) +
  geom_line()+ theme_bw() +   ggtitle("Best pattern of Class 1") +
  scale_colour_discrete(name = "Series index:",
    guide = guide_legend(title.theme=element_text(size=14, angle=0),
    keywidth = 1, keyheight = 1.5, label.theme=element_text(size=14, angle=0))) +
  theme(plot.title=element_text(size=18),
        axis.text.x=element_blank(), axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),axis.title.y=element_blank())

p1<- ggplot_gtable(ggplot_build(p1))
p1$heights[[2]] <- p1$heights[[2]]+unit(0.5, "lines")
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
row.names(subseries)=c(paste("#", series))
#
dm=melt(subseries)
names(dm)=c("series","x","value")
p2 = ggplot(dm, aes(x = x, y = value, group = series, color=series)) + 
  geom_line() + theme_bw() + ggtitle("Second best pattern of Class 1") +
  scale_colour_discrete(name = "Series index:",
      guide = guide_legend(title.theme=element_text(size=14, angle=0),
      keywidth = 1, keyheight = 1.5, label.theme=element_text(size=14, angle=0))) +
  theme(plot.title=element_text(size=18),
        axis.text.x=element_blank(), axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),axis.title.y=element_blank())
p2<- ggplot_gtable(ggplot_build(p2))
p2$heights[[2]] <- p2$heights[[2]]+unit(0.5, "lines")

print(arrangeGrob(p1, p2, p3, p4, ncol=2))

Cairo(width = 900, height = 600, 
      file="/media/Stock/csdl-techreports/techreports/2011/11-09/figures/shapelet-patterns", 
      type="ps", pointsize=11,
      canvas = "white", units = "px", dpi = 80)
print(grid.arrange(p1, p2, p3, p4, ncol=2))
dev.off()
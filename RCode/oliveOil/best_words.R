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
# ROBUSTA
#
dat = read.table("../data/OliveOil/OliveOil_TRAIN",header=F)
#
size=as.numeric(length(dat[1,]))-1
class=1
frame=370
series=c(0,1,2,3,4)+1
offsets=c(152,153,152,152,152)+1
#
#
pre_series=(dat[dat[,1]==class,-1])[series[1],]
pre_segments=(dat[dat[,1]==class,-1])[series[1],]
pre_segments[1:(offsets[1])]=NA
pre_segments[(offsets[1]+frame):size]=NA
for(i in 2:(length(series))){
  seq = (dat[dat[,1]==class,-1])[series[i],]
  pre_series = rbind(pre_series, seq)
  seq[1:(offsets[i])]=NA
  seq[(offsets[i]+frame):size]=NA
  pre_segments = rbind(pre_segments, seq)
}
dm=melt(t(pre_series))
dm$X2=c(rep("# 0",size),rep("# 1",size),rep("# 2",size),rep("# 3",size),rep("# 4",size))
dm$index=c(rep(seq(1:size),5))

dm2=melt(t(pre_segments))
dm2$X2=dm$X2
dm2$index=dm$index

p = ggplot(dm, aes(x = index, y = value, group = X2, color=X2)) + 
  geom_line()+ geom_line(data=dm2,lwd=3) + theme_bw() +
  ggtitle("Greece Koroneiki Olive Oil Spectrograpghy") +
  scale_colour_discrete(name = "Series index:",
    guide = guide_legend(title.theme=element_text(size=14, angle=0),
    keywidth = 1, keyheight = 1.5, label.theme=element_text(size=14, angle=0)))+
  theme(plot.title=element_text(size=18))
p
subseries=znorm(as.numeric((pre_series[1,])[(offsets[1]):(offsets[1]+frame)]))
for(i in 2:(length(offsets))){
  piece=znorm(as.numeric(((pre_series[i,])[(offsets[i]):(offsets[i]+frame)])))
  subseries = rbind(subseries, piece)
}
#
row.names(subseries)=c(paste("#", series))
#
dm=melt(subseries)
names(dm)=c("series","x","value")
p2 = ggplot(dm, aes(x = x, y = value, group = series, color=series)) + 
  geom_line()+ theme_bw() + ggtitle("Best patterns from Greece Koroneiki Olive Oil data") +
  scale_colour_discrete(name = "Series index:",
    guide = guide_legend(title.theme=element_text(size=14, angle=0),
    keywidth = 1, keyheight = 1.5, label.theme=element_text(size=14, angle=0))) +
  theme(plot.title=element_text(size=18),
        axis.text.x=element_blank(), axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),axis.title.y=element_blank())

p2 <- ggplot_gtable(ggplot_build(p2))
p2$heights[[2]] <- p2$heights[[2]]+unit(0.5, "lines")
print(arrangeGrob(p, p2, ncol=1))

Cairo(width = 900, height = 600, file="oliveOil/Greece.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(p, p2, ncol=1))
dev.off()

#
# Italy
#
class=2
series=c(0,1,2,3,5)+1
offsets=c(151,151,151,151,151)+1
#
#
pre_series=(dat[dat[,1]==class,-1])[series[1],]
pre_segments=(dat[dat[,1]==class,-1])[series[1],]
pre_segments[1:(offsets[1])]=NA
pre_segments[(offsets[1]+frame):size]=NA
for(i in 2:(length(series))){
  seq = (dat[dat[,1]==class,-1])[series[i],]
  pre_series = rbind(pre_series, seq)
  seq[1:(offsets[i])]=NA
  seq[(offsets[i]+frame):size]=NA
  pre_segments = rbind(pre_segments, seq)
}
dm=melt(t(pre_series))
dm$X2=c(rep("# 0",size),rep("# 5",size),rep("# 6",size),rep("# 10",size),rep("# 15",size))
dm$index=c(rep(seq(1:size),5))

dm2=melt(t(pre_segments))
dm2$X2=dm$X2
dm2$index=dm$index

p3 = ggplot(dm, aes(x = index, y = value, group = X2, color=X2)) + 
  geom_line()+ geom_line(data=dm2,lwd=3) + theme_bw() +
  ggtitle("Italy, Coratina Olive Oil spectrography") +
  scale_colour_discrete(name = "Series index:",
      guide = guide_legend(title.theme=element_text(size=14, angle=0),
      keywidth = 1, keyheight = 1.5, label.theme=element_text(size=14, angle=0)))+
  theme(plot.title=element_text(size=18))
p3
subseries=znorm(as.numeric((pre_series[1,])[(offsets[1]):(offsets[1]+frame)]))
for(i in 2:(length(offsets))){
  piece=znorm(as.numeric(((pre_series[i,])[(offsets[i]):(offsets[i]+frame)])))
  subseries = rbind(subseries, piece)
}
#
row.names(subseries)=c(paste("#", series))
#
dm=melt(subseries)
names(dm)=c("series","x","value")
p4 = ggplot(dm, aes(x = x, y = value, group = series, color=series)) + 
  geom_line()+ theme_bw() + ggtitle("Best patterns Italy, Coratina Olive Oil") +
  scale_colour_discrete(name = "Series index:",
    guide = guide_legend(title.theme=element_text(size=14, angle=0),
    keywidth = 1, keyheight = 1.5, label.theme=element_text(size=14, angle=0))) +
  theme(plot.title=element_text(size=18),
        axis.text.x=element_blank(), axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),axis.title.y=element_blank())

p4 <- ggplot_gtable(ggplot_build(p4))
p4$heights[[2]] <- p4$heights[[2]]+unit(0.5, "lines")
print(arrangeGrob(p, p3, p2, p4, ncol=2))

Cairo(width = 900, height = 600, file="coffee/best_arabica.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(p3, p4, ncol=1))
dev.off()

Cairo(width = 1200, height = 800, file="coffee/best_patterns.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(p, p3, p2, p4, ncol=2))
dev.off()
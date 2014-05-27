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
dat = read.table("../data/Coffee/Coffee_TRAIN",header=F)
#
size=as.numeric(length(dat[1,]))-1
class=1
frame=90
series=c(0,2,3,4,5)+1
offsets=c(18,18,18,19,19)+1
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

p = ggplot(dm, aes(x = index, y = value, group = X2, color=X2)) + 
  geom_line()+ geom_line(data=dm2,lwd=3) + theme_bw() +
  ggtitle("Robusta spectrograms sample") +
  scale_x_continuous(expand=c(0.01,0.01),"Wavenumbers", limits=range(dm2$index),
    breaks=c(seq(0,286,52)),labels=paste(c(seq(800,1800,200)))) + 
#  scale_x_continuous(expand=c(0.01,0.01),"Wavenumbers", limits=range(dm2$index),
#    breaks=c(seq(0,286,52)),labels=paste(c(seq(800,1800,200)))) + 
#    scale_colour_discrete(name = "Series index:",
#    guide = guide_legend(title.theme=element_text(size=14, angle=0),
#    keywidth = 1, keyheight = 1.5, label.theme=element_text(size=14, angle=0)))+
  theme(plot.title=element_text(size=18), legend.position="none",
        axis.title.y=element_blank(), axis.ticks.y=element_blank(),
        panel.grid.major.y = element_blank(),panel.grid.minor.y = element_blank(),
        axis.text.y=element_blank(),plot.margin = unit(c(0,0,0.2,0), "lines"))
p
#
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
  geom_line()+ theme_bw() + ggtitle("Best subsequence") +
#  scale_colour_discrete(name = "Series index:",
#    guide = guide_legend(title.theme=element_text(size=14, angle=0),
#    keywidth = 1, keyheight = 1.5, label.theme=element_text(size=14, angle=0))) +
  theme(plot.title=element_text(size=18), legend.position="none",
        axis.title=element_blank(), axis.ticks=element_blank(),
        axis.text=element_blank(), plot.margin = unit(c(0,0,1,0), "lines"))
p2 <- ggplot_gtable(ggplot_build(p2))
#p2$heights[[2]] <- p2$heights[[2]]+unit(0.5, "lines")
print(arrangeGrob(p, p2, ncol=2, widths=c(5/7, 2/7)))

Cairo(width = 900, height = 600, file="coffee/best_robusta.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(p, p2, ncol=1))
dev.off()

#
# ROBUSTA
#
size=as.numeric(length(dat[1,]))-1
class=0
frame=90
series=c(0,2,4,6,9)+1
offsets=c(32,32,32,33,33)+1
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
  ggtitle("Arabica spectrograms sample") +
  scale_x_continuous(expand=c(0.01,0.01),"Wavenumbers", limits=range(dm2$index),
                     breaks=c(seq(0,286,52)),labels=paste(c(seq(800,1800,200)))) + 
  #  scale_x_continuous(expand=c(0.01,0.01),"Wavenumbers", limits=range(dm2$index),
  #    breaks=c(seq(0,286,52)),labels=paste(c(seq(800,1800,200)))) + 
  #    scale_colour_discrete(name = "Series index:",
  #    guide = guide_legend(title.theme=element_text(size=14, angle=0),
  #    keywidth = 1, keyheight = 1.5, label.theme=element_text(size=14, angle=0)))+
  theme(plot.title=element_text(size=18), legend.position="none",
        axis.title.y=element_blank(), axis.ticks.y=element_blank(),
        axis.text.y=element_blank(),plot.margin = unit(c(0.2,0,0,0), "lines"))
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
  geom_line()+ theme_bw() + ggtitle("Best subsequence") +
  #  scale_colour_discrete(name = "Series index:",
  #    guide = guide_legend(title.theme=element_text(size=14, angle=0),
  #    keywidth = 1, keyheight = 1.5, label.theme=element_text(size=14, angle=0))) +
  theme(plot.title=element_text(size=18), legend.position="none",
        axis.title=element_blank(), axis.ticks=element_blank(),
        axis.text=element_blank(), plot.margin = unit(c(0.2,0,0.8,0), "lines"))
p4
#p2$heights[[2]] <- p2$heights[[2]]+unit(0.5, "lines")
print(arrangeGrob(p3, p4, ncol=2, widths=c(5/7, 2/7)))
print(arrangeGrob(p, p2, p3, p4, ncol=2, widths=c(5/7, 2/7)))

Cairo(width = 1000, height = 600, file="coffee/paper_patterns.ps", type="ps", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = 80)
print(arrangeGrob(p, p2, p3, p4, ncol=2, widths=c(5/7, 2/7)))
dev.off()
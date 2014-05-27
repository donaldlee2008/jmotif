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
# ACER CIRCINATUM
#
dat = read.table("../data/OSULeaf/OSULeaf_TRAIN",header=F)
#
class=1
frame=35
size=as.numeric(length(dat[1,]))-1
series = c(8,18,21,24)
offsets = c(329,69,145,269)

#
# pick the preseries
pre_series=znorm(as.numeric((dat[dat[,1]==class,-1])[series[1],]))
#make a segment in here too
pre_segments=(dat[dat[,1]==class,-1])[series[1],]
pre_segments[1:(offsets[1])]=NA
pre_segments[(offsets[1]+frame):size]=NA
for(i in 2:(length(series))){
  seq = as.numeric((dat[dat[,1]==class,-1])[series[i],])
  pre_series = rbind(pre_series, (znorm(seq) + (i-1)*7))
  seq[1:(offsets[i])]=NA
  seq[(offsets[i]+frame):size]=NA
  pre_segments = rbind(pre_segments, seq+(i-1)*7)
}
dm=melt(t(pre_series))
dm$X2=c(rep("# 14",size),rep("# 18",size),rep("# 24",size),rep("# 27",size))
dm$index=c(rep(seq(1:size),4))

dm2=melt(t(pre_segments))
dm2$X2=dm$X2
dm2$index=dm$index

p = ggplot(dm, aes(x = index, y = value, group = X2, color=X2)) + 
  geom_line()+ geom_line(data=dm2,lwd=3) + theme_bw() +
  theme(plot.title=element_text(size=18), legend.position = "none", 
    axis.text.x=element_blank(), axis.text.y=element_blank(),
    axis.ticks=element_blank(),
    axis.title.x=element_blank(),axis.title.y=element_blank())
p
#
#
subseries=znorm(as.numeric((pre_series[1,])[(offsets[1]):(offsets[1]+frame)]))
for(i in 2:(length(offsets))){
  piece=znorm(as.numeric(((pre_series[i,])[(offsets[i]):(offsets[i]+frame)])))
  subseries = rbind(subseries, piece)
}
row.names(subseries)=c(paste("#", series))
dm=melt(subseries)
names(dm)=c("series","x","value")
p3 = ggplot(dm, aes(x = x, y = value, group = series, color=series)) + 
  geom_line()+ theme_bw() +
  theme(plot.title=element_text(size=18), legend.position = "none", 
        axis.text.x=element_blank(), axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),axis.title.y=element_blank())
p3
print(arrangeGrob(p, p3, ncol=2, widths=c(2,1), 
  main=textGrob("Acer Circinatum shape curves and second best scoring pattern", gp = gpar(fontsize = 25, face = "bold", col = "black")), 
  sub=textGrob("Examples of Acer Circinatum leafs", gp = gpar(fontsize = 25, face = "bold", col = "black"))))

Cairo(width = 1200, height = 600, file="OSULeaf/Acer_Circinatum.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(p, p3, ncol=2, widths=c(2,1), main = textGrob("Acer Circinatum shape curves and second best scoring pattern", 
                                                                gp = gpar(fontsize = 25, face = "bold", col = "black"))))
dev.off()





#
# ACER GLABRUM
#
dat = read.table("../data/OSULeaf/OSULeaf_TRAIN",header=F)
#
class=3
frame=40
size=as.numeric(length(dat[1,]))-1
series=c(0,5,6,10,15)+1
offsets=c(289,221,353,284,210)+1
#
#
pre_series=(dat[dat[,1]==class,-1])
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
  scale_colour_discrete(name = "Series index:",
    guide = guide_legend(title.theme=element_text(size=14, angle=0),
    keywidth = 1, keyheight = 1.5, label.theme=element_text(size=14, angle=0)))

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
p3 = ggplot(dm, aes(x = x, y = value, group = series, color=series)) + 
  geom_line()+ theme_bw() + ggtitle("Best pattern of Class Acer Glabrum ") +
  scale_colour_discrete(name = "Series index:",
    guide = guide_legend(title.theme=element_text(size=14, angle=0),
    keywidth = 1, keyheight = 1.5, label.theme=element_text(size=14, angle=0))) +
  theme(plot.title=element_text(size=18),
        axis.text.x=element_blank(), axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),axis.title.y=element_blank())

p3 <- ggplot_gtable(ggplot_build(p3))
p3$heights[[2]] <- p3$heights[[2]]+unit(0.5, "lines")
print(arrangeGrob(p, p3, ncol=1))

Cairo(width = 900, height = 600, file="OSULeaf/Acer_Glabrum.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(p, p3, ncol=1))
dev.off()

#
# ACER CIRCINATUM
#
dat = read.table("../data/OSULeaf/OSULeaf_TRAIN",header=F)
#
class=1
frame=40
series=c(0,11,20,23,33)+1
offsets=c(358,357,144,268,227)+1
#
#
pre_series=(dat[dat[,1]==class,-1])
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
dm$X2=c(rep("# 1",size),rep("# 12",size),rep("# 21",size),rep("# 24",size),rep("# 34",size))
dm$index=c(rep(seq(1:size),5))

dm2=melt(t(pre_segments))
dm2$X2=dm$X2
dm2$index=dm$index

p = ggplot(dm, aes(x = index, y = value, group = X2, color=X2)) + 
  geom_line()+ geom_line(data=dm2,lwd=3) + theme_bw() +
  scale_colour_discrete(name = "Series index:",
   guide = guide_legend(title.theme=element_text(size=14, angle=0),
   keywidth = 1, keyheight = 1.5, label.theme=element_text(size=14, angle=0)))

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
p3 = ggplot(dm, aes(x = x, y = value, group = series, color=series)) + 
  geom_line()+ theme_bw() + ggtitle("Best pattern of Class Acer Circinatum") +
  scale_colour_discrete(name = "Series index:",
                        guide = guide_legend(title.theme=element_text(size=14, angle=0),
                                             keywidth = 1, keyheight = 1.5, label.theme=element_text(size=14, angle=0))) +
  theme(plot.title=element_text(size=18),
        axis.text.x=element_blank(), axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),axis.title.y=element_blank())

p3 <- ggplot_gtable(ggplot_build(p3))
p3$heights[[2]] <- p3$heights[[2]]+unit(0.5, "lines")
print(arrangeGrob(p, p3, ncol=1))
Cairo(width = 900, height = 600, file="OSULeaf/Acer_Circinatum.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(p, p3, ncol=1))
dev.off()


#
# Acer Macrophyllum
#
dat = read.table("../data/OSULeaf/OSULeaf_TRAIN",header=F)
#
class=5
frame=40
series=c(3,8,11,12,14)+1
offsets=c(279,310,314,193,331)+1
#
#
pre_series=(dat[dat[,1]==class,-1])
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
dm$X2=c(rep("# 4",size),rep("# 9",size),rep("# 12",size),rep("# 13",size),rep("# 15",size))
dm$index=c(rep(seq(1:size),5))

dm2=melt(t(pre_segments))
dm2$X2=dm$X2
dm2$index=dm$index

p = ggplot(dm, aes(x = index, y = value, group = X2, color=X2)) + 
  geom_line()+ geom_line(data=dm2,lwd=3) + theme_bw() +
  scale_colour_discrete(name = "Series index:",
       guide = guide_legend(title.theme=element_text(size=14, angle=0),
       keywidth = 1, keyheight = 1.5, label.theme=element_text(size=14, angle=0)))
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
p3 = ggplot(dm, aes(x = x, y = value, group = series, color=series)) + 
  geom_line()+ theme_bw() + ggtitle("Best pattern of Class Acer Macrophyllum") +
  scale_colour_discrete(name = "Series index:",
                        guide = guide_legend(title.theme=element_text(size=14, angle=0),
                                             keywidth = 1, keyheight = 1.5, label.theme=element_text(size=14, angle=0))) +
  theme(plot.title=element_text(size=18),
        axis.text.x=element_blank(), axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),axis.title.y=element_blank())

p3 <- ggplot_gtable(ggplot_build(p3))
p3$heights[[2]] <- p3$heights[[2]]+unit(0.5, "lines")
print(arrangeGrob(p, p3, ncol=1))
Cairo(width = 900, height = 600, file="OSULeaf/Acer_Macrophyllum.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(p, p3, ncol=1))
dev.off()
#
# Acer Negundo
#
dat = read.table("../data/OSULeaf/OSULeaf_TRAIN",header=F)
#
class=6
frame=40
series=c(2,7,8,9,9)+1
offsets=c(223,100,208,14,14)+1
#
#
pre_series=(dat[dat[,1]==class,-1])
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
dm$X2=c(rep("# 3",size),rep("# 8",size),rep("# 9",size),rep("# 10",size),rep("# 10",size))
dm$index=c(rep(seq(1:size),5))

dm2=melt(t(pre_segments))
dm2$X2=dm$X2
dm2$index=dm$index

p = ggplot(dm, aes(x = index, y = value, group = X2, color=X2)) + 
  geom_line()+ geom_line(data=dm2,lwd=3) + theme_bw() +
  scale_colour_discrete(name = "Series index:",
                        guide = guide_legend(title.theme=element_text(size=14, angle=0),
                                             keywidth = 1, keyheight = 1.5, label.theme=element_text(size=14, angle=0)))
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
p3 = ggplot(dm, aes(x = x, y = value, group = series, color=series)) + 
  geom_line()+ theme_bw() + ggtitle("Best pattern of Class Acer Negundo") +
  scale_colour_discrete(name = "Series index:",
                        guide = guide_legend(title.theme=element_text(size=14, angle=0),
                                             keywidth = 1, keyheight = 1.5, label.theme=element_text(size=14, angle=0))) +
  theme(plot.title=element_text(size=18),
        axis.text.x=element_blank(), axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),axis.title.y=element_blank())

p3 <- ggplot_gtable(ggplot_build(p3))
p3$heights[[2]] <- p3$heights[[2]]+unit(0.5, "lines")
print(arrangeGrob(p, p3, ncol=1))
Cairo(width = 900, height = 600, file="OSULeaf/Acer_Negundo.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(p, p3, ncol=1))
dev.off()


#
# Quercus Garryana
#
dat = read.table("../data/OSULeaf/OSULeaf_TRAIN",header=F)
#
class=2
frame=40
series=c(4,4,6,8,16)+1
offsets=c(91,92,77,42,241)+1
#
#
pre_series=(dat[dat[,1]==class,-1])
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
dm$X2=c(rep("# 5",size),rep("# 5",size),rep("# 7",size),rep("# 9",size),rep("# 17",size))
dm$index=c(rep(seq(1:size),5))

dm2=melt(t(pre_segments))
dm2$X2=dm$X2
dm2$index=dm$index

p = ggplot(dm, aes(x = index, y = value, group = X2, color=X2)) + 
  geom_line()+ geom_line(data=dm2,lwd=3) + theme_bw() +
  scale_colour_discrete(name = "Series index:",
                        guide = guide_legend(title.theme=element_text(size=14, angle=0),
                                             keywidth = 1, keyheight = 1.5, label.theme=element_text(size=14, angle=0)))
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
p3 = ggplot(dm, aes(x = x, y = value, group = series, color=series)) + 
  geom_line()+ theme_bw() + ggtitle("Best pattern of Class Quercus Garryana") +
  scale_colour_discrete(name = "Series index:",
                        guide = guide_legend(title.theme=element_text(size=14, angle=0),
                                             keywidth = 1, keyheight = 1.5, label.theme=element_text(size=14, angle=0))) +
  theme(plot.title=element_text(size=18),
        axis.text.x=element_blank(), axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),axis.title.y=element_blank())

p3 <- ggplot_gtable(ggplot_build(p3))
p3$heights[[2]] <- p3$heights[[2]]+unit(0.5, "lines")
print(arrangeGrob(p, p3, ncol=1))
Cairo(width = 900, height = 600, file="OSULeaf/Quercus_Garryana.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(p, p3, ncol=1))
dev.off()


#
# Quercus Kelloggii
#
dat = read.table("../data/OSULeaf/OSULeaf_TRAIN",header=F)
#
class=4
frame=40
series=c(3,7,11,31,34)+1
offsets=c(60,375,34,69,87)+1
#
#
pre_series=(dat[dat[,1]==class,-1])
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
dm$X2=c(rep("# 4",size),rep("# 8",size),rep("# 12",size),rep("# 32",size),rep("# 35",size))
dm$index=c(rep(seq(1:size),5))

dm2=melt(t(pre_segments))
dm2$X2=dm$X2
dm2$index=dm$index

p = ggplot(dm, aes(x = index, y = value, group = X2, color=X2)) + 
  geom_line()+ geom_line(data=dm2,lwd=3) + theme_bw() +
  scale_colour_discrete(name = "Series index:",
                        guide = guide_legend(title.theme=element_text(size=14, angle=0),
                                             keywidth = 1, keyheight = 1.5, label.theme=element_text(size=14, angle=0)))
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
p3 = ggplot(dm, aes(x = x, y = value, group = series, color=series)) + 
  geom_line()+ theme_bw() + ggtitle("Best pattern of Class Quercus Kelloggii") +
  scale_colour_discrete(name = "Series index:",
                        guide = guide_legend(title.theme=element_text(size=14, angle=0),
                                             keywidth = 1, keyheight = 1.5, label.theme=element_text(size=14, angle=0))) +
  theme(plot.title=element_text(size=18),
        axis.text.x=element_blank(), axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),axis.title.y=element_blank())

p3 <- ggplot_gtable(ggplot_build(p3))
p3$heights[[2]] <- p3$heights[[2]]+unit(0.5, "lines")
print(arrangeGrob(p, p3, ncol=1))
Cairo(width = 900, height = 600, file="OSULeaf/Quercus_Kelloggii.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(p, p3, ncol=1))
dev.off()
















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
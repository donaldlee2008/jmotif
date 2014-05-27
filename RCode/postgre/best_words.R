znorm <- function(ts){
  if()
  ts.mean <- mean(ts)
  ts.dev <- sd(ts)
  (ts - ts.mean)/ts.dev
}
#
plotseries=function(dat, class, series, title){
  #
  # length of vectors
  size=as.numeric(length(dat[1,]))-1
  #
  #extract first series
  pre_series=znorm(as.numeric((dat[dat[,1]==class,-1])[series[1],]))
  #
  # and the titles for the legend
  x2Seq=rep(paste("#",series[1]),size)
  # and join with the rest
  for(i in 2:(length(series))){
    seq = as.numeric((dat[dat[,1]==class,-1])[series[i],])
    pre_series = rbind(pre_series, (znorm(seq) + (i-1)*9))
    #
    x2Seq=cbind(x2Seq,rep(paste("#",series[i]),size))
  }
  #
  # melt together
  dm=melt(t(pre_series))
  # legend titles
  dm$X2=c(x2Seq)
  dm$index=c(rep(seq(1:size),length(series)))
  #
  p = ggplot(dm, aes(x = index, y = value, group = X2, color=X2)) + 
    geom_line()+ theme_bw() + ggtitle(title) +
    scale_colour_discrete(name = "Series index:",
                          guide = guide_legend(title.theme=element_text(size=14, angle=0),
                                               keywidth = 1, keyheight = 1.5, label.theme=element_text(size=14, angle=0))) +
    theme(plot.title=element_text(size=18),
          axis.text.x=element_blank(), axis.text.y=element_blank(),
          axis.ticks=element_blank(),
          axis.title.x=element_blank(),axis.title.y=element_blank())
  p  
}
#
#bestp_plot=plotwords(datTRAIN, class, frame, bestp_series, bestp_offsets, paste("Best patterns, immersionHeater"))
plotwords=function(dat, class, frame, series, offsets, title){
  #
  # length of vectors
  size=as.numeric(length(dat[1,]))-1
  #
  #extract first series
  pre_series=znorm(as.numeric((dat[dat[,1]==class,-1])[series[1],]))
  #
  #and the segment too
  pre_segments=pre_series;
  pre_segments[1:(offsets[1])]=NA;pre_segments[(offsets[1]+frame):size]=NA
  #
  # and the titles for the legend
  x2Seq=rep(paste("#",series[1]),size)
  # and join with the rest
  for(i in 2:(length(series))){
    seq = znorm(as.numeric((dat[dat[,1]==class,-1])[series[i],]))
    pre_series = rbind(pre_series, (seq + (i-1)*5))
    #
    seq[1:(offsets[i])]=NA
    seq[(offsets[i]+frame):size]=NA
    pre_segments = rbind(pre_segments, seq +(i-1)*5)
    #
    x2Seq=cbind(x2Seq,rep(paste("#",series[i]),size))
  }
  #
  # melt together
  dm=melt(t(pre_series))
  # legend titles
  dm$X2=c(x2Seq)
  dm$index=c(rep(seq(1:size),length(series)))
  
  dms=melt(t(pre_segments))
  dms$X2=dm$X2
  dms$index=dm$index
  
  p = ggplot(dm, aes(x = index, y = value, group = X2, color=X2)) + 
    geom_line()+ geom_line(data=dms,lwd=1.5) + theme_bw() + ggtitle(title) +
    scale_colour_discrete(name = "Series index:",
          guide = guide_legend(title.theme=element_text(size=14, angle=0),
          keywidth = 1, keyheight = 1.5, label.theme=element_text(size=14, angle=0))) +
    theme(plot.title=element_text(size=18),
          axis.text.x=element_blank(), axis.text.y=element_blank(),
          axis.ticks=element_blank(),
          axis.title.x=element_blank(),axis.title.y=element_blank())
  p  
}
#
datTRAIN = read.csv("../data/postgre/postgre_AL_TRAIN",sep=',',header=F)
datTRAIN[is.na(datTRAIN[])] = 0
# best pattern series
class=1
frame=10
bestp_series = c(13,20,31,39,59)
bestp_offsets =  c(25,27,2,30,9)
(datTRAIN[datTRAIN[,1]==class,])[bestp_series[2],]
bestp_plot=plotwords(datTRAIN, class, frame, bestp_series, bestp_offsets, paste("Best patterns, immersionHeater"))
bestp_plot


#
dat = as.matrix(read.csv("../data/postgre/postgre_AL_TRAIN",header=F))
dat[is.na(dat[])] = 0
#
class=1
frame=10
series = c(13,20,31,39,59)
offsets = c(25,27,2,30,9)
#
#
pre_series=(dat[dat[,1]==class,])[series[1],]
pre_series=(dat[dat[,1]==class,-1])[series[1],]
for(i in 2:(length(series))){
  pre_series = rbind(pre_series, (dat[dat[,1]==class,-1])[series[i],])
}
subseries=znorm(as.numeric((pre_series[1,])[(offsets[1]):(offsets[1]+frame)]))
i=2
for(i in 2:(length(offsets))){
  piece=znorm(as.numeric(((pre_series[i,])[(offsets[i]):(offsets[i]+frame)])))
  subseries = rbind(subseries, piece)
}
ts=as.numeric(((pre_series[i,])[(offsets[i]):(offsets[i]+frame)]))
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

(p3) <- ggplot_gtable(ggplot_build(p3))
p3$heights[[2]] <- p3$heights[[2]]+unit(0.5, "lines")

print(arrangeGrob(p3))
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
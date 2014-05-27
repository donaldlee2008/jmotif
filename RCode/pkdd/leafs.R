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
    pre_series = rbind(pre_series, (znorm(seq) + (i-1)*7))
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
    theme(plot.title=element_text(size=18),
          axis.text.x=element_blank(), axis.text.y=element_blank(),
          axis.ticks=element_blank(),
          axis.title.x=element_blank(),axis.title.y=element_blank(),
          legend.position = "none")
  p  
}
#
plotwords=function(dat, class, frame, series, offsets, title){
  #
  # length of vectors
  size=as.numeric(length(dat[1,]))-1
  #
  #extract first series
  pre_series=znorm(as.numeric((dat[dat[,1]==class,-1])[series[1],]))
  #
  #and the segment too
  pre_segments=(dat[dat[,1]==class,-1])[series[1],];pre_segments[1:(offsets[1])]=NA;pre_segments[(offsets[1]+frame):size]=NA
  #
  # and the titles for the legend
  x2Seq=rep(paste("#",series[1]),size)
  # and join with the rest
  for(i in 2:(length(series))){
    seq = as.numeric((dat[dat[,1]==class,-1])[series[i],])
    pre_series = rbind(pre_series, (znorm(seq) + (i-1)*7))
    #
    seq[1:(offsets[i])]=NA
    seq[(offsets[i]+frame):size]=NA
    pre_segments = rbind(pre_segments, seq+(i-1)*7)
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
    geom_line()+ geom_line(data=dms,lwd=3) + theme_bw() + ggtitle(title) +
    theme(plot.title=element_text(size=18),
          axis.text.x=element_blank(), axis.text.y=element_blank(),
          axis.ticks=element_blank(),
          axis.title.x=element_blank(),axis.title.y=element_blank(),
          legend.position = "none")
  p  
}
#
datTRAIN = read.table("../data/OSULeaf/OSULeaf_TRAIN",header=F)
datTEST = read.table("../data/OSULeaf/OSULeaf_TEST",header=F)
#
# ACER CIRCINATUM analysis
#
# best pattern series
class=1
frame=50
bestp_pattern="oqqolhebb"; bestp_weight=0.0233
bestp_series = c(8,12,15,26,33)
bestp_offsets = c(173,207,298,194,295)
bestp_plot=plotwords(datTRAIN, class, frame, bestp_series, bestp_offsets, paste("Acer Circunatum"))
bestp_plot
#
# Quercus Garryana analysis
#
# best pattern series
class=2
frame=50
bestp_pattern="oqqolhebb"; bestp_weight=0.0233
bestp_series = c(3,5,16,18,22)
bestp_offsets = c(297,31,338,39,76)
bestp_plot1=plotwords(datTRAIN, class, frame, bestp_series, bestp_offsets, paste("Quercus Garryana"))
bestp_plot1
#
# Acer Glabrum analysis
#
# best pattern series
class=3
frame=50
bestp_pattern="oqqolhebb"; bestp_weight=0.0233
bestp_series = c(3,4,5,18,20)
bestp_offsets = c(161,291,299,299,314)
bestp_plot3=plotwords(datTRAIN, class, frame, bestp_series, bestp_offsets, paste("Acer Glabrum"))
bestp_plot3
#
#
#
print(arrangeGrob(bestp_plot, bestp_plot3, bestp_plot1, ncol=3))
#
Cairo(width = 1200, height = 500, 
      file="OSULeaf/three_plots.ps", 
      type="ps", pointsize=18, 
      bg = "transparent", canvas = "white", units = "px", dpi = 82)
print(arrangeGrob(bestp_plot, bestp_plot3, bestp_plot1, ncol=3))
dev.off()

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
    pre_series = rbind(pre_series, (znorm(seq) + (i-1)*3))
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
          panel.grid.major.x = element_blank(),panel.grid.major.y = element_blank(),
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
    pre_series = rbind(pre_series, (znorm(seq) + (i-1)*3))
    #
    seq[1:(offsets[i])]=NA
    seq[(offsets[i]+frame):size]=NA
    pre_segments = rbind(pre_segments, seq+(i-1)*3)
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
    theme(plot.title=element_text(size=18),
          panel.grid.major.x = element_blank(),panel.grid.major.y = element_blank(),
          axis.text.x=element_blank(), axis.text.y=element_blank(),
          axis.ticks=element_blank(),
          axis.title.x=element_blank(),axis.title.y=element_blank(),
          legend.position = "none")
  p  
}
#
# Data
#
datTRAIN = read.table("../data/Gun_Point/Gun_Point_TRAIN",header=F)
datTEST = read.table("../data/Gun_Point/Gun_Point_TEST",header=F)
#
# Gun
#
# best pattern series
class=1
frame=32
bestp_series = c(3,4,5,6,7)
bestp_offsets = c(25,26,27,31,25)
bestgun_plot=plotwords(datTRAIN, class, frame, bestp_series, bestp_offsets, paste("Best patterns, Gun"))
bestgun_plot
#
# second best
second_series = c(3,4,5,6,7)
second_offsets = c(36,37,38,42,35)
secondgun_plot=plotwords(datTRAIN, class, frame, second_series, second_offsets, paste("Second best pattern, Gun"))
secondgun_plot
#
# Point
#
# best pattern series
class=2
frame=32
bestp_series = c(7,5,3,1,2)
bestp_offsets = c(95,114,82,99,93)
bestp_plot=plotwords(datTRAIN, class, frame, bestp_series, bestp_offsets, paste("Best patterns, Point"))
bestp_plot
#
# second best
second_series = c(6,5,3,1,2)
second_offsets = c(7,6,27,38,33)
secondp_plot=plotwords(datTRAIN, class, frame, second_series, second_offsets, paste("Second best pattern, Point"))
secondp_plot
#
#
print(arrangeGrob(bestgun_plot, secondgun_plot, bestp_plot, secondp_plot, ncol=2, widths=c(1,1)))





Cairo(width = 800, height = 1200, 
      #file="/media/Stock/csdl-techreports/techreports/2011/11-09/figures/gun-point", 
      file="/home/psenin/thesis/csdl-techreports/pkdd/figures/shapelet-patterns", 
      type="ps", pointsize=18, 
      bg = "transparent", canvas = "white", units = "px", dpi = 82)
print(arrangeGrob(bestgun_plot, bestp_plot, secondgun_plot, secondp_plot, ncol=2, widths=c(1,1)))
dev.off()
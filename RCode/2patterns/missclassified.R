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
    pre_series = rbind(pre_series, (seq + (i-1)*9))
    #
    seq[1:(offsets[i])]=NA
    seq[(offsets[i]+frame):size]=NA
    pre_segments = rbind(pre_segments, seq +(i-1)*9)
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
datTRAIN = read.table("../data/Two_Patterns/Two_Patterns_TRAIN",header=F)
#
# class 3
#
# best pattern series
class=3
frame=106
bestp_series = c(23,31,49,71,79)
bestp_offsets = c(1,1,9,7,1)
#(datTRAIN[datTRAIN[,1]==class,])[bestp_series[2],]
bestp_plot=plotwords(datTRAIN, class, frame, bestp_series, bestp_offsets, paste("Best patterns, class #3"))
bestp_plot
#
# second best
second_series = c(25,45,47,49,91)
second_offsets = c(14,12,5,6,6)
secondp_plot=plotwords(datTRAIN, class, frame, second_series, second_offsets, paste("Second best pattern, class #3"))
secondp_plot
#
thirdp_series = c(7,23,27,31,32)
thirdp_offsets =c(13,20,7,22,2)
thirdp_plot=plotwords(datTRAIN, class, frame, thirdp_series, thirdp_offsets, paste("Third best pattern, class #3"))
thirdp_plot
#
missclassified=c(32,88,92,147,155,936)
missclassified_plot=plotseries(datTRAIN, class, missclassified, paste("Misclassified series"))
missclassified_plot
#
#
#print(arrangeGrob(bestp_plot, secondp_plot, thirdp_plot, missclassified_plot, ncol=2, widths=c(1,1)))
Cairo(width = 900, height = 600, file="2patterns/class3.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(bestp_plot, secondp_plot, thirdp_plot, missclassified_plot, ncol=2))
dev.off()
#
#
# class 2
#
# best pattern series
class=2
frame=106
bestp_series = c(11,18,26,37,44)
bestp_offsets = c(11,14,18,6,4)
#(datTRAIN[datTRAIN[,1]==class,])[bestp_series[2],]
bestp_plot=plotwords(datTRAIN, class, frame, bestp_series, bestp_offsets, paste("Best patterns, class #2"))
bestp_plot
#
# second best
second_series = c(11,18,26,32,53)
second_offsets = c(1,5,9,6,7)
secondp_plot=plotwords(datTRAIN, class, frame, second_series, second_offsets, paste("Second best pattern, class #2"))
secondp_plot
#
thirdp_series = c(7,23,27,31,32)
thirdp_offsets =c(13,20,7,22,2)
thirdp_plot=plotwords(datTRAIN, class, frame, thirdp_series, thirdp_offsets, paste("Third best pattern, class #2"))
thirdp_plot
#
missclassified=c(32,88,92,147,155,936)
missclassified_plot=plotseries(datTRAIN, class, missclassified, paste("Misclassified series"))
missclassified_plot
#
#
#print(arrangeGrob(bestp_plot, secondp_plot, thirdp_plot, missclassified_plot, ncol=2, widths=c(1,1)))
Cairo(width = 900, height = 600, file="2patterns/class3.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(bestp_plot, secondp_plot, thirdp_plot, missclassified_plot, ncol=2))
dev.off()
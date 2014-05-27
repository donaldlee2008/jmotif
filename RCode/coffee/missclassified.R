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
    pre_series = rbind(pre_series, (seq + (i-1)*2))
    #
    seq[1:(offsets[i])]=NA
    seq[(offsets[i]+frame):size]=NA
    pre_segments = rbind(pre_segments, seq +(i-1)*2)
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
datTRAIN = read.table("../data/Coffee/Coffee_TRAIN",header=F)
datTEST = read.table("../data/Coffee/Coffee_TEST",header=F)
#
#
# ACER CIRCINATUM analysis
#
# best pattern series
class=0
frame=90
bestp_series = c(1,3,5,7,10)
bestp_offsets = c(32,32,32,33,33)
bestp_plot=plotwords(datTRAIN, class, frame, bestp_series, bestp_offsets, paste("Best patterns, Arabica"))
bestp_plot
#
# second best
second_series = c(1,2,3,4,5)
second_offsets = c(168,169,168,167,168)
secondp_plot=plotwords(datTRAIN, class, frame, second_series, second_offsets, paste("Second best pattern, Arabica"))
secondp_plot
#
thirdp_series = c(2,4,11,12,13)
thirdp_offsets = c(11,11,11,11,11)
thirdp_plot=plotwords(datTRAIN, class, frame, thirdp_series, thirdp_offsets, paste("Third best pattern, Arabica"))
thirdp_plot
#
missclassified=c()
missclassified_plot=plotseries(datTEST, class, missclassified, paste("Missclassified series"))
#
#
#print(arrangeGrob(bestp_plot, secondp_plot, thirdp_plot, missclassified_plot, ncol=2, widths=c(1,1)))
Cairo(width = 800, height = 1200, file="coffee/Arabica.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(bestp_plot, secondp_plot, thirdp_plot, ncol=1))
dev.off()
#
#
# Quercus Garryana analysis
#
# best pattern series
class=1
frame=90
bestp_series = c(1,3,4,5,6)
bestp_offsets = c(19,19,19,20,20)
bestp_plot=plotwords(datTRAIN, class, frame, bestp_series, bestp_offsets, paste("Best patterns, Robusta"))
bestp_plot
#
# second best
second_series = c(1,3,8,9,10)
second_offsets = c(179,178,179,179,178)
secondp_plot=plotwords(datTRAIN, class, frame, second_series, second_offsets, paste("Second best pattern, Robusta"))
secondp_plot
#
thirdp_series = c(1,2,3,4,5)
thirdp_offsets = c(167,167,166,167,166)
thirdp_plot=plotwords(datTRAIN, class, frame, thirdp_series, thirdp_offsets, paste("Third best pattern, Robusta"))
thirdp_plot
#
missclassified=c(5,22,36,37)
d=datTEST[datTEST[,1]==2,]
missclassified_plot=plotseries(datTEST, class, missclassified, paste("Missclassified series"))
#
#
print(arrangeGrob(bestp_plot, secondp_plot, thirdp_plot, missclassified_plot, ncol=2, widths=c(1,1)))
Cairo(width = 800, height = 1200, file="coffee/Robusta.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(bestp_plot, secondp_plot, thirdp_plot, ncol=1))
dev.off()

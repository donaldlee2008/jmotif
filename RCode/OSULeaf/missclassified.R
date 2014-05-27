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
datTRAIN = read.table("../data/OSULeaf/OSULeaf_TRAIN",header=F)
datTEST = read.table("../data/OSULeaf/OSULeaf_TEST",header=F)
#
#
# ACER CIRCINATUM analysis
#
# best pattern series
class=1
frame=50
bestp_pattern="oqqolhebb"; bestp_weight=0.0233
bestp_series = c(8,12,15,26,33)
bestp_offsets = c(173,207,298,194,295)
bestp_plot=plotwords(datTRAIN, class, frame, bestp_series, bestp_offsets, paste("Best patterns, Acer Circunatum"))
bestp_plot
#
# second best
second_series = c(4,15,21,33)
second_offsets = c(51,279,19,276)
secondp_plot=plotwords(datTRAIN, class, frame, second_series, second_offsets, paste("Second best pattern, Acer Circunatum"))
secondp_plot
#
thirdp_series = c(17,20,30,32)
thirdp_offsets = c(9,2,97,168)
thirdp_plot=plotwords(datTRAIN, class, frame, thirdp_series, thirdp_offsets, paste("Third best pattern, Acer Circunatum"))
thirdp_plot
#
missclassified=c(8,14,24)
missclassified_plot=plotseries(datTEST, class, missclassified, paste("Missclassified series"))
#
#
print(arrangeGrob(bestp_plot, secondp_plot, thirdp_plot, missclassified_plot, ncol=2, widths=c(1,1)))
Cairo(width = 800, height = 600, file="OSULeaf/AcerCircunatum.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(bestp_plot, secondp_plot, thirdp_plot, missclassified_plot, ncol=2, widths=c(1,1)))
dev.off()

Cairo(width = 1200, height = 1000, 
      file="OSULeaf/AcerCircunatum.ps", 
      type="ps", pointsize=18, 
      bg = "transparent", canvas = "white", units = "px", dpi = 82)
print(arrangeGrob(bestp_plot, secondp_plot, thirdp_plot, missclassified_plot, ncol=2, widths=c(1,1)))
dev.off()

#
#
# Quercus Garryana analysis
#
# best pattern series
class=2
frame=50
bestp_pattern="oqqolhebb"; bestp_weight=0.0233
bestp_series = c(3,5,16,18,22)
bestp_offsets = c(297,31,338,39,76)
bestp_plot=plotwords(datTRAIN, class, frame, bestp_series, bestp_offsets, paste("Best patterns, Quercus Garryana"))
bestp_plot
#
# second best
second_series = c(4,15,17,18,22)
second_offsets = c(79,47,261,282,26)
secondp_plot=plotwords(datTRAIN, class, frame, second_series, second_offsets, paste("Second best pattern, Quercus Garryana"))
secondp_plot
#
thirdp_series = c(15,16,20,27)
thirdp_offsets = c(40,95,325,34)
thirdp_plot=plotwords(datTRAIN, class, frame, thirdp_series, thirdp_offsets, paste("Third best pattern, Quercus Garryana"))
thirdp_plot
#
missclassified=c(5,22,36,37)
d=datTEST[datTEST[,1]==2,]
missclassified_plot=plotseries(datTEST, class, missclassified, paste("Missclassified series"))
#
#
print(arrangeGrob(bestp_plot, secondp_plot, thirdp_plot, missclassified_plot, ncol=2, widths=c(1,1)))
Cairo(width = 800, height = 600, file="OSULeaf/QuercusGarryana.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(bestp_plot, secondp_plot, thirdp_plot, missclassified_plot, ncol=2, widths=c(1,1)))
dev.off()

Cairo(width = 1200, height = 1000, 
      file="OSULeaf/AcerGarryana.ps", 
      type="ps", pointsize=18, 
      bg = "transparent", canvas = "white", units = "px", dpi = 82)
print(arrangeGrob(bestp_plot, secondp_plot, thirdp_plot, missclassified_plot, ncol=2, widths=c(1,1)))
dev.off()

#
#
# Acer Glabrum analysis
#
# best pattern series
class=3
frame=50
bestp_pattern="oqqolhebb"; bestp_weight=0.0233
bestp_series = c(3,4,5,18,20)
bestp_offsets = c(161,291,299,299,314)
bestp_plot=plotwords(datTRAIN, class, frame, bestp_series, bestp_offsets, paste("Best patterns, Acer Glabrum"))
bestp_plot
#
# second best
second_series = c(8,9,14,16,28)
second_offsets = c(148,295,229,157,234)
secondp_plot=plotwords(datTRAIN, class, frame, second_series, second_offsets, paste("Second best pattern, Acer Glabrum"))
secondp_plot
#
thirdp_series = c(2,16,23,28,29)
thirdp_offsets = c(131,273,73,281,70)
thirdp_plot=plotwords(datTRAIN, class, frame, thirdp_series, thirdp_offsets, paste("Third best pattern, Acer Glabrum"))
thirdp_plot
#
missclassified=c(11,23,25)
missclassified_plot=plotseries(datTEST, class, missclassified, paste("Missclassified series"))
#
#
print(arrangeGrob(bestp_plot, secondp_plot, thirdp_plot, missclassified_plot, ncol=2, widths=c(1,1)))
Cairo(width = 800, height = 600, file="OSULeaf/AcerGlabrum.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(bestp_plot, secondp_plot, thirdp_plot, missclassified_plot, ncol=2, widths=c(1,1)))
dev.off()

Cairo(width = 1200, height = 1000, 
      file="OSULeaf/AcerGlabrum.pdf", 
      type="pdf", pointsize=18, 
      bg = "transparent", canvas = "white", units = "px", dpi = 82)
print(arrangeGrob(bestp_plot, secondp_plot, thirdp_plot, missclassified_plot, ncol=2, widths=c(1,1)))
dev.off()

#
#
# Acer Quercus Kelloggii
#
# best pattern series
class=4
title="Quercus Kelloggii"
frame=50
bestp_pattern="oqqolhebb"; bestp_weight=0.0233
bestp_series = c(7,10,17,18,31)
bestp_offsets = c(355,352,185,224,217)
bestp_plot=plotwords(datTRAIN, class, frame, bestp_series, bestp_offsets, paste("Best patterns,", title))
bestp_plot
#
# second best
second_series = c(17,18,23,24,32)
second_offsets = c(118,160,114,62,269)
secondp_plot=plotwords(datTRAIN, class, frame, second_series, second_offsets, paste("Second best patterns,", title))
secondp_plot
#
thirdp_series = c(3,8,12,28,35)
thirdp_offsets = c(116,374,33,319,87)
thirdp_plot=plotwords(datTRAIN, class, frame, thirdp_series, thirdp_offsets, paste("Third best patterns,", title))
thirdp_plot
#
missclassified=c(11)
missclassified_plot=plotseries(datTEST, class, missclassified, paste("Missclassified series"))
#
#
print(arrangeGrob(bestp_plot, secondp_plot, thirdp_plot, missclassified_plot, ncol=2, widths=c(1,1)))
Cairo(width = 800, height = 600, file="OSULeaf/QuercusKelloggii.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(bestp_plot, secondp_plot, thirdp_plot, missclassified_plot, ncol=2, widths=c(1,1)))
dev.off()
#
#
# Acer Macrophyllum
#
# best pattern series
class=5
title="Acer Macrophyllum"
frame=50
bestp_pattern="oqqolhebb"; bestp_weight=0.0233
bestp_series = c(1,7,17,18,28)
bestp_offsets = c(25,360,235,258,323)
bestp_plot=plotwords(datTRAIN, class, frame, bestp_series, bestp_offsets, paste("Best patterns,", title))
bestp_plot
#
# second best
second_series = c(23,26,28,29)
second_offsets = c(5,25,7,24)
secondp_plot=plotwords(datTRAIN, class, frame, second_series, second_offsets, paste("Second best patterns,", title))
secondp_plot
#
thirdp_series = c(12,13,17,26)
thirdp_offsets = c(292,170,107,316)
thirdp_plot=plotwords(datTRAIN, class, frame, thirdp_series, thirdp_offsets, paste("Third best patterns,", title))
thirdp_plot
#
missclassified=c(8,12,14)
missclassified_plot=plotseries(datTEST, class, missclassified, paste("Missclassified series"))
#
#
print(arrangeGrob(bestp_plot, secondp_plot, thirdp_plot, missclassified_plot, ncol=2, widths=c(1,1)))
Cairo(width = 800, height = 600, file="OSULeaf/AcerMacrophyllum.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(bestp_plot, secondp_plot, thirdp_plot, missclassified_plot, ncol=2, widths=c(1,1)))
dev.off()
#
#
# Acer Negundo
#
# best pattern series
class=6
title="Acer Negundo"
frame=50
bestp_pattern="oqqolhebb"; bestp_weight=0.0233
bestp_series = c(3,11,13)
bestp_offsets = c(8,135,263)
bestp_plot=plotwords(datTRAIN, class, frame, bestp_series, bestp_offsets, paste("Best patterns,", title))
bestp_plot
#
# second best
second_series = c(10,11,14)
second_offsets = c(184,256,196)
secondp_plot=plotwords(datTRAIN, class, frame, second_series, second_offsets, paste("Second best patterns,", title))
secondp_plot
#
thirdp_series = c(5,8,9)
thirdp_offsets = c(40,97,206)
thirdp_plot=plotwords(datTRAIN, class, frame, thirdp_series, thirdp_offsets, paste("Third best patterns,", title))
thirdp_plot
#
missclassified=c(3,5,15,16,20)
missclassified_plot=plotseries(datTEST, class, missclassified, paste("Missclassified series"))
#
#
print(arrangeGrob(bestp_plot, secondp_plot, thirdp_plot, missclassified_plot, ncol=2, widths=c(1,1)))
Cairo(width = 800, height = 600, file="OSULeaf/AcerNegundo.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(bestp_plot, secondp_plot, thirdp_plot, missclassified_plot, ncol=2, widths=c(1,1)))
dev.off()
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
datTRAIN = read.table("../data/ElectricDevices/ElectricDevices_TRAIN",sep=',',header=F)
datTEST = read.table("../data/ElectricDevices/ElectricDevices_TEST",sep=',',header=F)
#
# immersionHeater analysis
#
# best pattern series
class=3
frame=17
bestp_series = c(283,303,305,317,322)
bestp_offsets = c(41,31,51,30,30)
(datTRAIN[datTRAIN[,1]==class,])[bestp_series[2],]
bestp_plot=plotwords(datTRAIN, class, frame, bestp_series, bestp_offsets, paste("Best patterns, immersionHeater"))
bestp_plot
#
# second best
second_series = c(305,317,322,332,350)
second_offsets = c(46,25,25,25,25)
secondp_plot=plotwords(datTRAIN, class, frame, second_series, second_offsets, paste("Second best pattern, immersionHeater"))
secondp_plot
#
thirdp_series = c(284,290,309,318,331)
thirdp_offsets =c(31,69,73,29,29)
thirdp_plot=plotwords(datTRAIN, class, frame, thirdp_series, thirdp_offsets, paste("Third best pattern, immersionHeater"))
thirdp_plot
#
missclassified=c(1,273,416,475,557)
missclassified_plot=plotseries(datTEST, class, missclassified, paste("Misclassified series"))
missclassified_plot
#
#
#print(arrangeGrob(bestp_plot, secondp_plot, thirdp_plot, missclassified_plot, ncol=2, widths=c(1,1)))
Cairo(width = 900, height = 600, file="electricalDevices/immersionHeater.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(bestp_plot, secondp_plot, thirdp_plot, missclassified_plot, ncol=2))
dev.off()
#
#
# coldGroup analysis
#
# best pattern series
class=2
frame=17
bestp_series = c(332,334,335,336,346)
bestp_offsets = c(60,20,20,68,66)
(datTRAIN[datTRAIN[,1]==class,])[bestp_series[1],]
bestp_plot=plotwords(datTRAIN, class, frame, bestp_series, bestp_offsets, paste("Best patterns, coldGroup"))
bestp_plot
#
# second best
second_series = c(329,330,331,332,333)
second_offsets = c(24,2,14,7,23)
secondp_plot=plotwords(datTRAIN, class, frame, second_series, second_offsets, paste("Second best pattern, coldGroup"))
secondp_plot
#
thirdp_series = c(330,334,335,336,339)
thirdp_offsets = c(44,78,8,65,3)
thirdp_plot=plotwords(datTRAIN, class, frame, thirdp_series, thirdp_offsets, paste("Third best pattern, coldGroup"))
thirdp_plot
#
missclassified=c(37,1442,1382,1495,323)
missclassified_plot=plotseries(datTEST, class, missclassified, paste("Misclassified series"))
missclassified_plot
#print(arrangeGrob(bestp_plot, secondp_plot, thirdp_plot, missclassified_plot, ncol=2, widths=c(1,1)))
Cairo(width = 900, height = 600, file="electricalDevices/coldGroup.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(bestp_plot, secondp_plot, thirdp_plot, missclassified_plot, ncol=2))
dev.off()
#
# dishwasher analysis
#
# best pattern series
class=1
frame=17
bestp_series = c(365,368,370,371,373)
bestp_offsets = c(45,28,65,47,27)
(datTRAIN[datTRAIN[,1]==class,])[bestp_series[2],]
bestp_plot=plotwords(datTRAIN, class, frame, bestp_series, bestp_offsets, paste("Best patterns, dishwasher"))
bestp_plot
#
# second best
second_series = c(365,370,371,373,395)
second_offsets = c(57,77,59,52,49)
secondp_plot=plotwords(datTRAIN, class, frame, second_series, second_offsets, paste("Second best pattern, dishwasher"))
secondp_plot
#
thirdp_series = c(368,375,383,386,390)
thirdp_offsets = c(31,73,62,37,27)
thirdp_plot=plotwords(datTRAIN, class, frame, thirdp_series, thirdp_offsets, paste("Third best pattern, dishwasher"))
thirdp_plot
#
missclassified=c(111,590,657,4,5,6)
missclassified_plot=plotseries(datTEST, class, missclassified, paste("Misclassified series"))
missclassified_plot
#
#
#print(arrangeGrob(bestp_plot, secondp_plot, thirdp_plot, missclassified_plot, ncol=2, widths=c(1,1)))
Cairo(width = 900, height = 600, file="electricalDevices/dishwasher.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(bestp_plot, secondp_plot, thirdp_plot, missclassified_plot, ncol=2))
dev.off()
#
# tvGroup analysis
#
# best pattern series
class=0
frame=17
bestp_series = c(409,410,412,413,414)
bestp_offsets = c(2,1,2,24,19)
(datTRAIN[datTRAIN[,1]==class,])[bestp_series[2],]
bestp_plot=plotwords(datTRAIN, class, frame, bestp_series, bestp_offsets, paste("Best patterns, tvGroup"))
bestp_plot
#
# second best
second_series = c(409,410,411,412,413)
second_offsets = c(4,3,78,4,22)
secondp_plot=plotwords(datTRAIN, class, frame, second_series, second_offsets, paste("Second best pattern, tvGroup"))
secondp_plot
#
thirdp_series = c(412,413,631,633,634)
thirdp_offsets = c(16,6,43,35,46)
thirdp_plot=plotwords(datTRAIN, class, frame, thirdp_series, thirdp_offsets, paste("Third best pattern, tvGroup"))
thirdp_plot
#
missclassified=c(180,182,674,675,1043,1045)
missclassified_plot=plotseries(datTEST, class, missclassified, paste("Misclassified series"))
missclassified_plot
#
#
#print(arrangeGrob(bestp_plot, secondp_plot, thirdp_plot, missclassified_plot, ncol=2, widths=c(1,1)))
Cairo(width = 900, height = 600, file="electricalDevices/tvGroup.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(bestp_plot, secondp_plot, thirdp_plot, missclassified_plot, ncol=2))
dev.off()
#
# washingMachine analysis
#
# best pattern series
class=6
frame=17
bestp_series = c(7,8,18,21,26)
bestp_offsets = c(70,66,70,48,35)
(datTRAIN[datTRAIN[,1]==class,])[bestp_series[2],]
bestp_plot=plotwords(datTRAIN, class, frame, bestp_series, bestp_offsets, paste("Best patterns, washingMachine"))
bestp_plot
#
# second best
second_series = c(4,8,9,18,21)
second_offsets = c(76,62,33,66,44)
secondp_plot=plotwords(datTRAIN, class, frame, second_series, second_offsets, paste("Second best pattern, washingMachine"))
secondp_plot
#
thirdp_series = c(5,9,10,13,16)
thirdp_offsets = c(37,75,36,76,43)
thirdp_plot=plotwords(datTRAIN, class, frame, thirdp_series, thirdp_offsets, paste("Third best pattern, washingMachine"))
thirdp_plot
#
missclassified=c(2,17,20,540,626,744)
missclassified_plot=plotseries(datTEST, class, missclassified, paste("Misclassified series"))
missclassified_plot
#
#
#print(arrangeGrob(bestp_plot, secondp_plot, thirdp_plot, missclassified_plot, ncol=2, widths=c(1,1)))
Cairo(width = 900, height = 600, file="electricalDevices/washingMachine.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(bestp_plot, secondp_plot, thirdp_plot, missclassified_plot, ncol=2))
dev.off()
#
# ovenCooker analysis
#
# best pattern series
class=5
frame=17
bestp_series = c(201,321,331,333,352)
bestp_offsets = c(71,56,43,60,29)
(datTRAIN[datTRAIN[,1]==class,])[bestp_series[2],]
bestp_plot=plotwords(datTRAIN, class, frame, bestp_series, bestp_offsets, paste("Best patterns, ovenCooker"))
bestp_plot
#
# second best
second_series = c(352,382,471,508,735)
second_offsets = c(68,47,72,69,73)
secondp_plot=plotwords(datTRAIN, class, frame, second_series, second_offsets, paste("Second best pattern, ovenCooker"))
secondp_plot
#
thirdp_series = c(57,291,321,330,331)
thirdp_offsets = c(70,55,57,62,44)
thirdp_plot=plotwords(datTRAIN, class, frame, thirdp_series, thirdp_offsets, paste("Third best pattern, ovenCooker"))
thirdp_plot
#
missclassified=c(1,7,72,118,184,1155)
missclassified_plot=plotseries(datTEST, class, missclassified, paste("Misclassified series"))
missclassified_plot
#
#
#print(arrangeGrob(bestp_plot, secondp_plot, thirdp_plot, missclassified_plot, ncol=2, widths=c(1,1)))
Cairo(width = 900, height = 600, file="electricalDevices/ovenCooker.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(bestp_plot, secondp_plot, thirdp_plot, missclassified_plot, ncol=2))
dev.off()
#
# kettle analysis
#
# best pattern series
class=4
frame=17
bestp_series = c(32,52,76,81,105)
bestp_offsets = c(37,26,37,37,62)
(datTRAIN[datTRAIN[,1]==class,])[bestp_series[1],]
bestp_plot=plotwords(datTRAIN, class, frame, bestp_series, bestp_offsets, paste("Best patterns, Kettle"))
bestp_plot
#
# second best
second_series = c(19,68,129,153,165)
second_offsets = c(44,44,26,44,44)
secondp_plot=plotwords(datTRAIN, class, frame, second_series, second_offsets, paste("Second best pattern, Kettle"))
secondp_plot
#
thirdp_series = c(19,68,106,129,153)
thirdp_offsets = c(42,42,29,24,42)
thirdp_plot=plotwords(datTRAIN, class, frame, thirdp_series, thirdp_offsets, paste("Third best pattern, Kettle"))
thirdp_plot
#
missclassified=c(7,99,102,564,695,721)
missclassified_plot=plotseries(datTEST, class, missclassified, paste("Misclassified series"))
missclassified_plot
#
#
#print(arrangeGrob(bestp_plot, secondp_plot, thirdp_plot, missclassified_plot, ncol=2, widths=c(1,1)))
Cairo(width = 900, height = 600, file="electricalDevices/Kettle.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(bestp_plot, secondp_plot, thirdp_plot, missclassified_plot, ncol=2))
dev.off()
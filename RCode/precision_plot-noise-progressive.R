require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require("lattice")

#
# 7 vs 8
#
#
dd=read.csv("../docs/noise6077_nored.csv",header=F,skip=1)
dd=rbind(dd, read.csv("../docs/noise6077_exact.csv",header=F,skip=1))
dd=rbind(dd, read.csv("../docs/noise6077_classic.csv",header=F,skip=1))
dd=rbind(dd, read.csv("../docs/noise6078_nored.csv",header=F,skip=1))
dd=rbind(dd, read.csv("../docs/noise6078_exact.csv",header=F,skip=1))
dd=rbind(dd, read.csv("../docs/noise6078_classic.csv",header=F,skip=1))
dd=rbind(dd, read.csv("../docs/noise6087_nored.csv",header=F,skip=1))
dd=rbind(dd, read.csv("../docs/noise6087_exact.csv",header=F,skip=1))
dd=rbind(dd, read.csv("../docs/noise6087_classic.csv",header=F,skip=1))
names(dd)=c("train","jmotif_error","euclidean_error","jmotif_time","euclidean_time")

plot = function(filename, dd, title){
  dat=read.csv(filename,header=F,skip=1)
  names(dat)=c("train","jmotif_error","euclidean_error","jmotif_time","euclidean_time")
  index=sort(unique(dat$train))
  jmotif_error=rep(-1,length(index))
  for(i in 1:(length(index))){
    jmotif_error[i]=mean(dat[dat$train==index[i],2])
  }
  euclidean_error=rep(-1,length(index))
  for(i in 1:(length(index))){
    euclidean_error[i]=mean(dd[dd$train==index[i],3])
  }
  
  d=data.frame(index,euclidean_error,jmotif_error)
  dm=melt(d,id.var="index")
  p <- ggplot(dm, aes(index, value, color=variable)) + geom_line(lwd=1) +
    geom_point() + theme_bw() +
    scale_x_continuous("TRAIN dataset size") + 
    scale_y_log10("Classification error",limits=c(0.0007,0.30)) +
    ggtitle(paste(title)) +
    theme(plot.title=element_text(size=18),axis.text.x=element_text(size=10), 
          axis.text.y=element_text(size=10),axis.title.x=element_text(size=14), 
          axis.title.y=element_text(size=14))
  p
}

p1=plot("../docs/noise6077_nored.csv", dd, "60, 7, 7, NORED");
p2=plot("../docs/noise6077_exact.csv", dd, "60, 7, 7, EXACT");
p3=plot("../docs/noise6077_classic.csv", dd, "60, 7, 7, CLASSIC");
p4=plot("../docs/noise6078_nored.csv", dd, "60, 7, 8, NORED");
p5=plot("../docs/noise6078_exact.csv", dd, "60, 7, 8, EXACT");
p6=plot("../docs/noise6078_classic.csv", dd, "60, 7, 8, CLASSIC");
p7=plot("../docs/noise6087_nored.csv", dd, "60, 8, 7, NORED");
p8=plot("../docs/noise6087_exact.csv", dd, "60, 8, 7, EXACT");
p9=plot("../docs/noise6087_classic.csv", dd, "60, 8, 7, CLASSIC");

Cairo(width = 1200, height = 650, file="precision_noise_sergey_vs_pavel.png", type="png", pointsize=10, 
      bg = "white", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(p1, p2, p3, p4, p5, p6, p7, p8, p9, ncol=3))
dev.off()
#
#
#



#
# NOREDUCTION SECTION
#
dd=read.csv("../docs/noise1_nored.csv",header=F)
dd=rbind(dd, read.csv("../docs/noise2_nored.csv",header=F))
dd=rbind(dd, read.csv("../docs/noise3_nored.csv",header=F))
dd=rbind(dd, read.csv("../docs/noise4_nored.csv",header=F))
names(dd)=c("train","jmotif_error","euclidean_error","jmotif_time","euclidean_time")

plot = function(filename, dd, title){
 dat=read.csv(filename,header=F)
 names(dat)=c("train","jmotif_error","euclidean_error","jmotif_time","euclidean_time")
 index=sort(unique(dat$train))
 jmotif_error=rep(-1,length(index))
 for(i in 1:(length(index))){
   jmotif_error[i]=mean(dat[dat$train==index[i],2])
 }
 euclidean_error=rep(-1,length(index))
 for(i in 1:(length(index))){
   euclidean_error[i]=mean(dd[dd$train==index[i],3])
 }
 
 d=data.frame(index,euclidean_error,jmotif_error)
 dm=melt(d,id.var="index")
 p <- ggplot(dm, aes(index, value, color=variable)) + geom_line(lwd=1) +
  geom_point() + theme_bw() +
  scale_x_continuous("TRAIN dataset size") + 
   scale_y_log10("Classification error",limits=c(0.001,0.30)) +
  ggtitle(paste(title)) +
  theme(plot.title=element_text(size=18),axis.text.x=element_text(size=10), 
        axis.text.y=element_text(size=10),axis.title.x=element_text(size=14), 
        axis.title.y=element_text(size=14))
 p
}

p1=plot("../docs/noise1_nored.csv", dd, "60, 6, 6, NOREDUCTION");
p2=plot("../docs/noise2_nored.csv", dd, "60, 6, 7, NOREDUCTION");
p3=plot("../docs/noise3_nored.csv", dd, "60, 7, 6, NOREDUCTION");
p4=plot("../docs/noise4_nored.csv", dd, "60, 7, 7, NOREDUCTION");

print(arrangeGrob(p1, p2, p3, p4, ncol=2))

Cairo(width = 1200, height = 650, file="precision_noise_nored.png", type="png", pointsize=12, 
      bg = "white", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(p1, p2, p3, p4, ncol=2))
dev.off()
#
# EXACT SECTION
#
dd=read.csv("../docs/noise1.csv",header=F)
dd=rbind(dd, read.csv("../docs/noise2.csv",header=F))
dd=rbind(dd, read.csv("../docs/noise3.csv",header=F))
dd=rbind(dd, read.csv("../docs/noise4.csv",header=F))
names(dd)=c("train","jmotif_error","euclidean_error","jmotif_time","euclidean_time")

plot = function(filename, dd, title){
  dat=read.csv(filename,header=F)
  names(dat)=c("train","jmotif_error","euclidean_error","jmotif_time","euclidean_time")
  index=sort(unique(dat$train))
  jmotif_error=rep(-1,length(index))
  for(i in 1:(length(index))){
    jmotif_error[i]=mean(dat[dat$train==index[i],2])
  }
  euclidean_error=rep(-1,length(index))
  for(i in 1:(length(index))){
    euclidean_error[i]=mean(dd[dd$train==index[i],3])
  }
  
  d=data.frame(index,euclidean_error,jmotif_error)
  dm=melt(d,id.var="index")
  p <- ggplot(dm, aes(index, value, color=variable)) + geom_line(lwd=1) +
    geom_point() + theme_bw() +
    scale_x_continuous("TRAIN dataset size") + 
    scale_y_log10("Classification error",limits=c(0.001,0.30)) +
    ggtitle(paste(title)) +
    theme(plot.title=element_text(size=18),axis.text.x=element_text(size=10), 
          axis.text.y=element_text(size=10),axis.title.x=element_text(size=14), 
          axis.title.y=element_text(size=14))
  p
}

p1=plot("../docs/noise1.csv", dd, "60, 6, 6, EXACT");
p2=plot("../docs/noise2.csv", dd, "60, 6, 7, EXACT");
p3=plot("../docs/noise3.csv", dd, "60, 7, 6, EXACT");
p4=plot("../docs/noise4.csv", dd, "60, 7, 7, EXACT");

Cairo(width = 1200, height = 650, file="precision_noise_exact.png", type="png", pointsize=12, 
      bg = "white", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(p1, p2, p3, p4, ncol=2))
dev.off()
#
# 
#
dd=read.csv("../docs/noise6078_nored.csv",header=F,skip=1)
dd=rbind(dd, read.csv("../docs/noise6078_exact.csv",header=F,skip=1))
dd=rbind(dd, read.csv("../docs/classic6078_nored.csv",header=F,skip=1))
dd=rbind(dd, read.csv("../docs/noise6088_nored.csv",header=F,skip=1))
dd=rbind(dd, read.csv("../docs/noise6088_exact.csv",header=F,skip=1))
dd=rbind(dd, read.csv("../docs/classic6088_nored.csv",header=F,skip=1))
names(dd)=c("train","jmotif_error","euclidean_error","jmotif_time","euclidean_time")

plot = function(filename, dd, title){
  dat=read.csv(filename,header=F,skip=1)
  names(dat)=c("train","jmotif_error","euclidean_error","jmotif_time","euclidean_time")
  index=sort(unique(dat$train))
  jmotif_error=rep(-1,length(index))
  for(i in 1:(length(index))){
    jmotif_error[i]=mean(dat[dat$train==index[i],2])
  }
  euclidean_error=rep(-1,length(index))
  for(i in 1:(length(index))){
    euclidean_error[i]=mean(dd[dd$train==index[i],3])
  }
  
  d=data.frame(index,euclidean_error,jmotif_error)
  dm=melt(d,id.var="index")
  p <- ggplot(dm, aes(index, value, color=variable)) + geom_line(lwd=1) +
    geom_point() + theme_bw() +
    scale_x_continuous("TRAIN dataset size") + 
    scale_y_log10("Classification error",limits=c(0.001,0.30)) +
    ggtitle(paste(title)) +
    theme(plot.title=element_text(size=18),axis.text.x=element_text(size=10), 
          axis.text.y=element_text(size=10),axis.title.x=element_text(size=14), 
          axis.title.y=element_text(size=14))
  p
}

p1=plot("../docs/noise6078_nored.csv", dd, "60, 7, 8, NORED");
p2=plot("../docs/noise6078_exact.csv", dd, "60, 7, 8, EXACT");
p3=plot("../docs/classic6078_nored.csv", dd, "60, 7, 8, CLASSIC");
p4=plot("../docs/noise6088_nored.csv", dd, "60, 8, 8, NORED");
p5=plot("../docs/noise6088_exact.csv", dd, "60, 8, 8, EXACT");
p6=plot("../docs/classic6088_nored.csv", dd, "60, 8, 8, CLASSIC");

Cairo(width = 1200, height = 650, file="precision_noise_strategies.png", type="png", pointsize=10, 
      bg = "white", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(p1, p2, p3, p4, p5, p6, ncol=3))
dev.off()
#
# SERGEY vs PAVEL
#
#
dd=read.csv("../docs/noise35412_nored.csv",header=F,skip=1)
dd=rbind(dd, read.csv("../docs/noise35412_exact.csv",header=F,skip=1))
dd=rbind(dd, read.csv("../docs/noise35412_classic.csv",header=F,skip=1))
dd=rbind(dd, read.csv("../docs/noise6077_nored.csv",header=F,skip=1))
dd=rbind(dd, read.csv("../docs/noise6077_exact.csv",header=F,skip=1))
dd=rbind(dd, read.csv("../docs/noise6077_classic.csv",header=F,skip=1))
names(dd)=c("train","jmotif_error","euclidean_error","jmotif_time","euclidean_time")

plot = function(filename, dd, title){
  dat=read.csv(filename,header=F,skip=1)
  names(dat)=c("train","jmotif_error","euclidean_error","jmotif_time","euclidean_time")
  index=sort(unique(dat$train))
  jmotif_error=rep(-1,length(index))
  for(i in 1:(length(index))){
    jmotif_error[i]=mean(dat[dat$train==index[i],2])
  }
  euclidean_error=rep(-1,length(index))
  for(i in 1:(length(index))){
    euclidean_error[i]=mean(dd[dd$train==index[i],3])
  }
  
  d=data.frame(index,euclidean_error,jmotif_error)
  dm=melt(d,id.var="index")
  p <- ggplot(dm, aes(index, value, color=variable)) + geom_line(lwd=1) +
    geom_point() + theme_bw() +
    scale_x_continuous("TRAIN dataset size") + 
    scale_y_log10("Classification error",limits=c(0.0005,0.30)) +
    ggtitle(paste(title)) +
    theme(plot.title=element_text(size=18),axis.text.x=element_text(size=10), 
          axis.text.y=element_text(size=10),axis.title.x=element_text(size=14), 
          axis.title.y=element_text(size=14))
  p
}

p1=plot("../docs/noise35412_nored.csv", dd, "35, 4, 12, NORED");
p2=plot("../docs/noise35412_exact.csv", dd, "35, 4, 12, EXACT");
p3=plot("../docs/noise35412_classic.csv", dd, "35, 4, 12, CLASSIC");
p4=plot("../docs/noise6077_nored.csv", dd, "60, 7, 7, NORED");
p5=plot("../docs/noise6077_exact.csv", dd, "60, 7, 7, EXACT");
p6=plot("../docs/noise6077_classic.csv", dd, "60, 7, 7, CLASSIC");

Cairo(width = 1200, height = 650, file="precision_noise_sergey_vs_pavel.png", type="png", pointsize=10, 
      bg = "white", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(p1, p2, p3, p4, p5, p6, ncol=3))
dev.off()
require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require("lattice")

dat = read.table("../data/CBF/CBF_TRAIN",header=F)

dat=t(dat)

ones=(dat[,dat[1,]==2])[-1,1]

window1=ones-2
window1[36:128]=NA

window2=ones-3
window2[1:1]=NA
window2[37:128]=NA

window3=ones-4
window3[1:2]=NA
window3[38:128]=NA

window4=ones-5
window4[1:3]=NA
window4[39:128]=NA

window5=ones-6
window5[1:4]=NA
window5[40:128]=NA

dm <- melt(cbind(ones,window1,window2,window3,window4,window5))
# add an index variable:
dm$index <- rep(1:128, 6)
dm$class <- c(rep("Cylinder",(128*1)), rep("window1",(128*1)), rep("window2",(128*1)),
              rep("window3",(128*1)), rep("window4",(128*1)), rep("window5",(128*1)))
dm$color <- c(rep("blue",(128*1)), rep("red",(128*5)))

p1 = ggplot(dm, aes(x = index, y = value, group = X2, color=X2)) + theme_bw() +
  geom_line(color=dm$color, lwd=1) +
  geom_segment(x=1,y=-10,xend=1,yend=window1[1],lty=2,lwd=0.2,color="brown")+
  geom_segment(x=2,y=-10,xend=2,yend=window2[2],lty=2,lwd=0.2,color="brown")+
  geom_segment(x=3,y=-10,xend=3,yend=window3[3],lty=2,lwd=0.2,color="brown")+
  geom_segment(x=4,y=-10,xend=4,yend=window4[4],lty=2,lwd=0.2,color="brown")+
  geom_segment(x=5,y=-10,xend=5,yend=window5[5],lty=2,lwd=0.2,color="brown")+
  geom_segment(x=35,y=ones[35],xend=35,yend=window1[35],lty=2,lwd=0.2,color="brown")+
  geom_segment(x=36,y=ones[36],xend=36,yend=window2[36],lty=2,lwd=0.2,color="brown")+
  geom_segment(x=37,y=ones[37],xend=37,yend=window3[37],lty=2,lwd=0.2,color="brown")+
  geom_segment(x=38,y=ones[38],xend=38,yend=window4[38],lty=2,lwd=0.2,color="brown")+
  geom_segment(x=39,y=ones[39],xend=39,yend=window5[39],lty=2,lwd=0.2,color="brown")+
  ggtitle("Class \"Bell\", sliding window=35") +
  scale_x_continuous("time ticks", limits=c(0,60), breaks=sort(c(c(1:5),seq(10,120,10),c(35:40)))) + 
  scale_y_continuous("Value",limits=c(-10,3),breaks=seq(-10,3,1))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p1
#
#
#
source("SAX/PAA_SAX.R")
#
#
#
#
#
#
subseries=dm[dm$class=="window1",]
subseries=subseries[complete.cases(subseries),]

p2<-ggplot(subseries, aes(x = index, y = value, group = X2, color=X2)) + theme_bw() +
  geom_line(color=subseries$color, lwd=1) +
  ggtitle("Window=35") +
  scale_x_continuous("time ticks") + 
  scale_y_continuous("Value")+
  theme(plot.title=element_text(size = 18, vjust = 2))
p2

subseries_znorm=znorm(t(subseries$value))
dz=data.frame(y=c(unlist(subseries_znorm)),x=seq(1:35))
p3<-ggplot(dz, aes(x=x,y=y))+
  theme_bw() + geom_line(color="brown") + geom_hline(yintercept=0,lty=2) +
  ggtitle("ZNormalized subseries") +
  scale_x_continuous("time ticks") + 
  scale_y_continuous("Value",limits=c(-3,3))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p3

subseries_paa = paa(subseries_znorm, 4)
dp=data.frame(y=c(unlist(subseries_paa)),yend=c(unlist(subseries_paa)),x=seq(1,35,35/4),
              xend=seq(1,35,35/4)+35/4)
p4<-ggplot()+geom_segment(data=dp,mapping=aes(x=x,y=y,xend=xend,yend=yend),lwd=2,col="brown")+
  geom_segment(data=dp,mapping=aes(x=x[2],y=y[1],xend=x[2],yend=yend[2]),lty=2,col="brown")+
  geom_segment(data=dp,mapping=aes(x=x[3],y=y[2],xend=x[3],yend=yend[3]),lty=2,col="brown")+
  geom_segment(data=dp,mapping=aes(x=x[4],y=y[3],xend=x[4],yend=yend[4]),lty=2,col="brown")+
  theme_bw() +  ggtitle("PAA to 4 points") +
  scale_x_continuous("time ticks") + 
  scale_y_continuous("Value",limits=c(-1,1))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p4

print(arrangeGrob(p2, p3, p4, ncol=3))

cuts = c(-1.43, -1.02, -0.74, -0.50, -0.29, -0.10,  0.10,  0.29,  0.50, 0.74, 1.02, 1.43)
p5<-ggplot() + theme_bw() +
  geom_segment(data=dp,mapping=aes(x=x,y=y,xend=xend,yend=yend),lwd=2,col="red")+
  geom_segment(data=dp,mapping=aes(x=x[2],y=y[1],xend=x[2],yend=yend[2]),lty=2,col="red")+
  geom_segment(data=dp,mapping=aes(x=x[3],y=y[2],xend=x[3],yend=yend[3]),lty=2,col="red")+
  geom_segment(data=dp,mapping=aes(x=x[4],y=y[3],xend=x[4],yend=yend[4]),lty=2,col="red")+
  geom_abline(mapping=aes(intercept=cuts, slope=rep(0,12)), lty=2, alpha=0.5) +
  geom_rect(mapping=aes(xmin=rep(0,11),xmax=rep(36,11),ymin=cuts[1:11],ymax=cuts[2:12]),
     fill=c(rep(c("yellow","orange"),5),"yellow"), alpha=0.3) +
  geom_text(mapping=aes(label=c("a","b","c","d","e","f","g","h","i","j","k"),x=rep(0.5,11),
                        y=cuts[1:11]+0.07))+
  theme_bw() +  ggtitle("PAA to String \"efdi\"") +
  scale_x_continuous("time ticks") + 
  scale_y_continuous("Value",limits=c(-2,2))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p5

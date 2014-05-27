require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)

data = read.csv("classification/cbf.dat", head=F)
names(data)=c("x","cylinder","bell","funnel")
data = melt(data,id.vars=c("x"))
p <- ggplot(data, aes(x,y=value,color=variable,lty=variable)) + geom_line(alpha=0.8, lwd=0.8) +theme_bw() + 
  ggtitle("The artificial cylinder-bell-funnel dataset, 128 points") +
  scale_x_continuous("time ticks", limits=c(0,128), breaks=seq(5,125,5))+ scale_y_continuous("Value")+
  theme(plot.title=element_text(size = 18, vjust = 2))
p
#
#
#
#
data = read.csv("classification/cbf.dat", head=F)
names(data)=c("x","cylinder","bell","funnel")
bell_data = data.frame(read.csv("classification/bell.dat", head=F)[,-1])
names(bell_data)=c("str","x0","y0","x1","y1","x2","y2","x3","y3")
source("SAX/PAA_SAX.R")
data$bell=t(znorm(t(data$bell)))
p <- ggplot(data, aes(x,y=bell)) + geom_line(alpha=0.3, lwd=0.8,col="green") +
  ggtitle("The artificial bell dataset, 128 points") +
  scale_x_continuous("time ticks", limits=c(0,128), breaks=c(seq(0,120,20),128)) + 
  scale_y_continuous("Value",limits=c(-3,3),breaks=seq(-3,3,1))
p

bell_dat = melt(bell_data,measure.vars=c("x0","y0","x1","y1","x2","y2","x3","y3"))
p + geom_segment(data=bell_data,mapping=aes(x=x0,xend=x1,y=y0,yend=y0,col=str)) +
  geom_segment(data=bell_data,mapping=aes(x=x1,xend=x1,y=y0,yend=y1,col=str)) +
  geom_segment(data=bell_data,mapping=aes(x=x1,xend=x2,y=y1,yend=y1,col=str)) +
  geom_segment(data=bell_data,mapping=aes(x=x2,xend=x2,y=y1,yend=y2,col=str)) +
  geom_segment(data=bell_data,mapping=aes(x=x2,xend=x3,y=y2,yend=y2,col=str)) +
  geom_segment(data=bell_data,mapping=aes(x=x3,xend=x3,y=y2,yend=y3,col=str)) +
  geom_segment(data=bell_data,mapping=aes(x=x3,xend=x3+48/4,y=y3,yend=y3,col=str))



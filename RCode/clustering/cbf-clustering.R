require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)


set.seed(15)

eks <- function(t,a,b){
  if(a<=t && t<=b){
    1
  }else{
    0
  }
}

cylinder <- function(t,a,b){
  res=rep(0,length(t))
  for(i in 1:(length(t))){
    res[i] = (6 + rnorm(1)) * eks(t[i],a,b) + rnorm(1)
  }
  res
}

bell <- function(t,a,b){
  res=rep(0,length(t))
  for(i in 1:(length(t))){
    res[i] = (6 + rnorm(1)) * eks(t[i],a,b) * (t[i]-a)/(b-a) + rnorm(1)
  }
  res
}

funnel <- function(t,a,b){
  res=rep(0,length(t))
  for(i in 1:(length(t))){
    res[i] = (6 + rnorm(1)) * eks(t[i],a,b) * (b-t[i])/(b-a) + rnorm(1)
  }
  res
}


a=runif(1)*16+32
b=a+runif(1)*64+32
x=seq(0,128,1)
cyl=cylinder(x,a,b)
bel=bell(x,a,b)
fun=funnel(x,a,b)
data = data.frame(cbind(x,cyl,bel,fun))
names(data)=c("x","cylinder","bell","funnel")
data = melt(data,id.vars=c("x"))
p <- ggplot(data, aes(x,y=value,color=variable,lty=variable)) + geom_line(alpha=0.8, lwd=0.8) +
  ggtitle("The artificial cylinder-bell-funnel dataset, 128 points") +scale_x_continuous("time ticks", limits=c(0,128),
  breaks=c(seq(0,120,20),128)) + scale_y_continuous("Value",limits=c(-4,10),breaks=seq(-4,10,2))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p

source("SAX/PAA_SAX.R")
data = read.csv("clustering/cbf.dat", head=F)
names(data)=c("x","cylinder","bell","funnel")
data = melt(data,id.vars=c("x"))
p <- ggplot(data, aes(x,y=value,color=variable,lty=variable)) + geom_line(alpha=0.8, lwd=0.8) +theme_bw() + 
  ggtitle("The artificial cylinder-bell-funnel dataset, 128 points") +
  scale_x_continuous("time ticks", limits=c(0,128), breaks=seq(5,125,5))+ scale_y_continuous("Value")+
  theme(plot.title=element_text(size = 18, vjust = 2))
p
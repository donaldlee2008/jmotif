require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)

# set seed for random generator
set.seed(15)

eks <- function(t,a,b){
  if(a<=t && t<=b){
    1
  }else{
    0
  }
}

cylinder <- function(t){
  a=runif(1)*16+16
  b=a+runif(1)*96
  res=rep(0,length(t))
  for(i in 1:(length(t))){
    res[i] = (6 + rnorm(1)) * eks(t[i],a,b) + rnorm(1)
  }
  res
}

bell <- function(t){
  a=runif(1)*16+16
  b=a+runif(1)*96
  res=rep(0,length(t))
  for(i in 1:(length(t))){
    res[i] = (6 + rnorm(1)) * eks(t[i],a,b) * (t[i]-a)/(b-a) + rnorm(1)
  }
  res
}

funnel <- function(t){
  a=runif(1)*16+16
  b=a+runif(1)*96
  res=rep(0,length(t))
  for(i in 1:(length(t))){
    res[i] = (6 + rnorm(1)) * eks(t[i],a,b) * (b-t[i])/(b-a) + rnorm(1)
  }
  res
}


x=seq(0,128,1)
cyl=cylinder(x)
bel=bell(x)
fun=funnel(x)
data = data.frame(cbind(x,cyl,bel,fun))
names(data)=c("x","cylinder","bell","funnel")
data = melt(data,id.vars=c("x"))
p <- ggplot(data, aes(x,y=value,color=variable,lty=variable)) + geom_line(alpha=0.8, lwd=0.8) +
  ggtitle("The artificial cylinder-bell-funnel dataset, 128 points") +scale_x_continuous("time ticks", limits=c(0,128),
  breaks=c(seq(0,120,20),128)) + scale_y_continuous("Value",limits=c(-4,10),breaks=seq(-4,10,2))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p


x=seq(0,128,1)
cyl1=cylinder(x)
bel1=bell(x)
fun1=funnel(x)

data = data.frame(cbind(x,cyl1))
names(data)=c("x","cylinder")
data = melt(data,id.vars=c("x"))
p1 <- ggplot(data, aes(x,y=value,lty=variable)) + theme_bw() + 
  geom_line(color="black") +  geom_hline(yintercept=0,lty=2) +
  ggtitle("The Cylinder dataset") +scale_x_continuous("time ticks", limits=c(0,128),
  breaks=c(seq(0,120,20),128)) + scale_y_continuous("Value",limits=c(-4,10),breaks=seq(-4,10,2))+
  theme(plot.title=element_text(size = 12, vjust = 2), legend.position = "none") 
p1

data = data.frame(cbind(x,bel1))
names(data)=c("x","bell")
data = melt(data,id.vars=c("x"))
p2 <- ggplot(data, aes(x,y=value,lty=variable)) + theme_bw() + 
  geom_line(color="black") +  geom_hline(yintercept=0,lty=2) +
  ggtitle("The Bell dataset") +scale_x_continuous("time ticks", limits=c(0,128),
  breaks=c(seq(0,120,20),128)) + scale_y_continuous("Value",limits=c(-4,10),breaks=seq(-4,10,2))+
  theme(plot.title=element_text(size = 12, vjust = 2), legend.position = "none") 
p2

data = data.frame(cbind(x,fun1))
names(data)=c("x","funnel")
data = melt(data,id.vars=c("x"))
p3 <- ggplot(data, aes(x,y=value,lty=variable)) + theme_bw() + 
  geom_line(color="black") +  geom_hline(yintercept=0,lty=2) +
  ggtitle("The Funnel dataset") +scale_x_continuous("time ticks", limits=c(0,128),
  breaks=c(seq(0,120,20))) + scale_y_continuous("Value",limits=c(-4,10))+
  theme(plot.title=element_text(size = 12, vjust = 2), legend.position = "none") 
p3

print(arrangeGrob(p1, p2, p3, ncol=1))
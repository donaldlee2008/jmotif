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
  a=runif(min=0,max=16,n=1)+16
  b=a+runif(min=32,max=96,n=1)
  res=rep(0,length(t))
  for(i in 1:(length(t))){
    res[i] = (6 + rnorm(1)) * eks(t[i],a,b) + rnorm(1)
  }
  res
}

bell <- function(t){
  a=runif(min=0,max=16,n=1)+16
  b=a+runif(min=32,max=96,n=1)
  res=rep(0,length(t))
  for(i in 1:(length(t))){
    res[i] = (6 + rnorm(1)) * eks(t[i],a,b) * (t[i]-a)/(b-a) + rnorm(1)
  }
  res
}

funnel <- function(t){
  a=runif(min=0,max=16,n=1)+16
  b=a+runif(min=32,max=96,n=1)
  res=rep(0,length(t))
  for(i in 1:(length(t))){
    res[i] = (6 + rnorm(1)) * eks(t[i],a,b) * (b-t[i])/(b-a) + rnorm(1)
  }
  res
}

x=seq(0,128,1)
cyl=cylinder(x)
dm = data.frame(index=x,value=cyl)

p = ggplot(dm, aes(x = index, y = value, color="black")) +
  theme_bw() + geom_line(colour="black") +
  ggtitle("Cylinder curve") +
  scale_x_continuous("time ticks", limits=c(0,128), breaks=seq(0,128,20)) + 
  scale_y_continuous("Value",limits=range(dm$value),breaks=seq(-2,8,2))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p
Cairo(width = 650, height = 250, file="cbf/cylinder_bw.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(p)
dev.off()

x=seq(0,128,1)
bell=bell(x)
dm = data.frame(index=x,value=bell)

p = ggplot(dm, aes(x = index, y = value, color="black")) +
  theme_bw() + geom_line(colour="black") +
  ggtitle("Bell curve") +
  scale_x_continuous("time ticks", limits=c(0,128), breaks=seq(0,128,20)) + 
  scale_y_continuous("Value",limits=range(dm$value),breaks=seq(-2,8,2))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p
Cairo(width = 650, height = 250, file="cbf/bell_bw.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(p)
dev.off()

x=seq(0,128,1)
funnel=funnel(x)
dm = data.frame(index=x,value=funnel)

p = ggplot(dm, aes(x = index, y = value, color="black")) +
  theme_bw() + geom_line(colour="black") +
  ggtitle("Funnel curve") +
  scale_x_continuous("time ticks", limits=c(0,128), breaks=seq(0,128,20)) + 
  scale_y_continuous("Value",limits=range(dm$value),breaks=seq(-2,8,2))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p
Cairo(width = 650, height = 250, file="cbf/funnel_bw.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(p)
dev.off()


cyl1=cylinder(x)
cyl2=cylinder(x)
data = data.frame(cbind(x,cyl,cyl1,cyl2))
#data=read.csv("test/cylinder.csv", header=T)
names(data)=c("x","cylinder 1","cylinder 2","cylinder 3")
data = melt(data,id.vars=c("x"))
p <- ggplot(data, aes(x,y=value,color=variable,lty=variable)) +theme_bw() + geom_line(alpha=0.8, lwd=0.8) + 
  ggtitle("The artificial Cylinder dataset example, |t|=128 points") +
  scale_x_continuous("time ticks", limits=c(0,128), breaks=seq(0,120,20)) + 
  scale_y_continuous("Value",limits=c(-4,10),breaks=seq(-4,10,2))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p
Cairo(width = 800, height = 300, file="classification/cylinder.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(p)
dev.off()


bel=bell(x)
bel1=bell(x)
bel2=bell(x)
data = data.frame(cbind(x,bel,bel1,bel2))
#data=read.csv("test/bell.csv", header=T)
names(data)=c("x","bell 1","bell 2","bell 3")
data = melt(data,id.vars=c("x"))
p <- ggplot(data, aes(x,y=value,color=variable,lty=variable)) +theme_bw() + geom_line(alpha=0.8, lwd=0.8) + 
  ggtitle("The artificial Bell dataset example, |t|=128 points") +
  scale_x_continuous("time ticks", limits=c(0,128), breaks=seq(0,120,20)) + 
  scale_y_continuous("Value",limits=c(-4,10),breaks=seq(-4,10,2))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p
Cairo(width = 800, height = 300, file="classification/bell.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(p)
dev.off()

fun=funnel(x)
fun1=funnel(x)
fun2=funnel(x)
data = data.frame(cbind(x,fun,fun1,fun2))
#data=read.csv("test/funnel.csv", header=T)
names(data)=c("x","funnel 1","funnel 2","funnel 3")
data = melt(data,id.vars=c("x"))
p <- ggplot(data, aes(x,y=value,color=variable,lty=variable)) +theme_bw() + geom_line(alpha=0.8, lwd=0.8) + 
  ggtitle("The artificial Funnel dataset example, |t|=128 points") +
  scale_x_continuous("time ticks", limits=c(0,128), breaks=seq(0,120,20)) + 
  scale_y_continuous("Value",limits=c(-4,10),breaks=seq(-4,10,2))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p
Cairo(width = 800, height = 300, file="classification/fun.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(p)
dev.off()


data = data.frame(cbind(x,fun,bel,cyl))
names(data)=c("x","funnel","bell","cylinder")
data = melt(data,id.vars=c("x"))
p <- ggplot(data, aes(x,y=value,color=variable,lty=variable)) +theme_bw() + geom_line(alpha=0.8, lwd=0.8) + 
  ggtitle("The artificial Cylinder-Bell-Funnel dataset example, |t|=128 points") +
  scale_x_continuous("time ticks", limits=c(0,128), breaks=seq(0,120,20)) + 
  scale_y_continuous("Value",limits=c(-4,10),breaks=seq(-4,10,2))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p
Cairo(width = 800, height = 300, file="classification/bfc.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(p)
dev.off()

#
#
#
error_data = data.frame(read.csv("classification/error_dist_3_3_60.csv",header=T))
dat=melt(1-error_data)
p3360<-ggplot(dat,aes(x=value,fill=variable))+geom_density(pos="dodge",binwidth=0.01,alpha=0.5)+theme_bw()+
  scale_x_continuous(limits=c(0.0,0.5), breaks=seq(0.0,0.5,0.1))+ggtitle("PAA=3, Alphabet=3, Window=60")+
  theme(axis.title=element_blank(),axis.text.y=element_blank(),legend.position = "none")
p3360

error_data = data.frame(read.csv("classification/error_dist_3_4_60.csv",header=T))
dat=melt(1-error_data)
p3460<-ggplot(dat,aes(x=value,fill=variable))+geom_density(pos="dodge",binwidth=0.01,alpha=0.5)+theme_bw()+
  scale_x_continuous(limits=c(0.0,1.0), breaks=seq(0.0,0.5,0.1))+ggtitle("PAA=3, Alphabet=4, Window=60")+
  theme(axis.title=element_blank(),axis.text.y=element_blank(),legend.position = "none")
p3460

error_data = data.frame(read.csv("classification/error_dist_3_5_60.csv",header=T))
dat=melt(1-error_data)
p3560<-ggplot(dat,aes(x=value,fill=variable))+geom_density(pos="dodge",binwidth=0.01,alpha=0.5)+theme_bw()+
  scale_x_continuous(limits=c(0.0,0.5), breaks=seq(0.0,0.5,0.1))+ggtitle("PAA=3, Alphabet=5, Window=60")+
  theme(axis.title=element_blank(),axis.text.y=element_blank(),legend.position = "none")
#  theme(axis.title=element_blank(),axis.text.y=element_blank(),legend.position = c(0.3, 0.5),legend.position = "none")
#        legend.background = element_rect(fill = "white", colour = NA))
p3560

#
error_data = data.frame(read.csv("classification/error_dist_4_3_60.csv",header=T))
dat=melt(1-error_data)
p4360<-ggplot(dat,aes(x=value,fill=variable))+geom_density(pos="dodge",binwidth=0.01,alpha=0.5)+theme_bw()+
  scale_x_continuous(limits=c(0.0,0.5), breaks=seq(0.0,0.5,0.1))+ggtitle("PAA=4, Alphabet=3, Window=60")+
  theme(axis.title=element_blank(),axis.text.y=element_blank(),legend.position = "none")
p4360

error_data = data.frame(read.csv("classification/error_dist_4_4_60.csv",header=T))
dat=melt(1-error_data)
p4460<-ggplot(dat,aes(x=value,fill=variable))+geom_density(pos="dodge",binwidth=0.01,alpha=0.5)+theme_bw()+
  scale_x_continuous(limits=c(0.0,0.5), breaks=seq(0.0,0.5,0.1))+ggtitle("PAA=4, Alphabet=4, Window=60")+
  theme(axis.title=element_blank(),axis.text.y=element_blank(),legend.position = "none")
p4460

error_data = data.frame(read.csv("classification/error_dist_4_5_60.csv",header=T))
dat=melt(1-error_data)
p4560<-ggplot(dat,aes(x=value,fill=variable))+geom_density(pos="dodge",binwidth=0.01,alpha=0.5)+theme_bw()+
  scale_x_continuous(limits=c(0.0,0.5), breaks=seq(0.0,0.5,0.1))+ggtitle("PAA=4, Alphabet=5, Window=60")+
  theme(axis.title=element_blank(),axis.text.y=element_blank(),legend.position = "none")
p4560

#
error_data = data.frame(read.csv("classification/error_dist_5_3_60.csv",header=T))
dat=melt(1-error_data)
p5360<-ggplot(dat,aes(x=value,fill=variable))+geom_density(pos="dodge",binwidth=0.01,alpha=0.5)+theme_bw()+
  scale_x_continuous(limits=c(0.0,0.5), breaks=seq(0.0,0.5,0.1))+ggtitle("PAA=5, Alphabet=3, Window=60")+
  theme(axis.title=element_blank(),axis.text.y=element_blank(),legend.position = "none")
p5360

error_data = data.frame(read.csv("classification/error_dist_5_4_60.csv",header=T))
dat=melt(1-error_data)
p5460<-ggplot(dat,aes(x=value,fill=variable))+geom_density(pos="dodge",binwidth=0.01,alpha=0.5)+theme_bw()+
  scale_x_continuous(limits=c(0.0,0.5), breaks=seq(0.0,0.5,0.1))+ggtitle("PAA=5, Alphabet=4, Window=60")+
  theme(axis.title=element_blank(),axis.text.y=element_blank(),legend.position = "none")
p5460

error_data = data.frame(read.csv("classification/error_dist_5_5_60.csv",header=T))
dat=melt(1-error_data)
p5560<-ggplot(dat,aes(x=value,fill=variable))+geom_density(pos="dodge",binwidth=0.01,alpha=0.5)+theme_bw()+
  scale_x_continuous(limits=c(0.0,0.5), breaks=seq(0.0,0.5,0.1))+ggtitle("PAA=5, Alphabet=5, Window=60")+
  theme(axis.title=element_blank(),axis.text.y=element_blank(),legend.position = "none")
p5560

#
error_data = data.frame(read.csv("classification/error_dist_6_3_60.csv",header=T))
dat=melt(1-error_data)
p6360<-ggplot(dat,aes(x=value,fill=variable))+geom_density(pos="dodge",binwidth=0.01,alpha=0.5)+theme_bw()+
  scale_x_continuous(limits=c(0.0,0.5), breaks=seq(0.0,0.5,0.1))+ggtitle("PAA=6, Alphabet=3, Window=60")+
  theme(axis.title=element_blank(),axis.text.y=element_blank(),legend.position = "none")
p6360

error_data = data.frame(read.csv("classification/error_dist_6_4_60.csv",header=T))
dat=melt(1-error_data)
p6460<-ggplot(dat,aes(x=value,fill=variable))+geom_density(pos="dodge",binwidth=0.01,alpha=0.5)+theme_bw()+
  scale_x_continuous(limits=c(0.0,0.5), breaks=seq(0.0,0.5,0.1))+ggtitle("PAA=6, Alphabet=4, Window=60")+
  theme(axis.title=element_blank(),axis.text.y=element_blank(),legend.position = "none")
p6460

error_data = data.frame(read.csv("classification/error_dist_6_5_60.csv",header=T))
dat=melt(1-error_data)
p6560<-ggplot(dat,aes(x=value,fill=variable))+geom_density(pos="dodge",binwidth=0.01,alpha=0.5)+theme_bw()+
  scale_x_continuous(limits=c(0.0,0.5), breaks=seq(0.0,0.5,0.1))+ggtitle("PAA=6, Alphabet=5, Window=60")+
  theme(axis.title=element_blank(),axis.text.y=element_blank(),legend.position = "none")
p6560

print(arrangeGrob(p3360, p3460, p3560, 
                  p4360, p4460, p4560, 
                  p5360, p5460, p5560, 
                  p6360, p6460, p6560, 
                  ncol=3))

Cairo(width = 800, height = 800, file="classification/error.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = 96)
print(arrangeGrob(p3360, p3460, p3560, 
                  p4360, p4460, p4560, 
                  p5360, p5460, p5560, 
                  p6360, p6460, p6560, 
                  ncol=3))
dev.off()

error_data = data.frame(read.csv("classification/error_dist_6_6_90.csv",header=T))
dat=melt(error_data)
p6560<-ggplot(dat,aes(x=value,fill=variable))+geom_density(pos="dodge",binwidth=0.01,alpha=0.5)+theme_bw()+
  scale_x_continuous(limits=c(0.6,1.0), breaks=seq(0.6,1.0,0.1))+ggtitle("PAA=6, Alphabet=6, Window=90")+
  theme(axis.title=element_blank(),axis.text.y=element_blank(),legend.position = "none")
p6560

1-mean(c(mean(error_data$cylinder),mean(error_data$bell),mean(error_data$funnel)))
sd(c(mean(error_data$cylinder),mean(error_data$bell),mean(error_data$funnel)))

cyl=cylinder(x)
cyl1=cylinder(x)
cyl2=cylinder(x)
fun=funnel(x)
fun1=funnel(x)
fun2=funnel(x)
bel=bell(x)
bel1=bell(x)
bel2=bell(x)


cbf = cbind(fun,fun1,fun2,bel,bel1,bel2,cyl,cyl1,cyl2)
colnames(cbf)=c("fun","fun1","fun2","bel","bel1","bel2","cyl","cyl1","cyl2")
cbs <- as.zoo(cbf)
d  <-  MOdist(cbs)
cl  <-  hclust( d )
groups  <-  cutree(cl, k=3)
plot(cbs, col=groups, main="Various Asian and American Currencies
     1995-Current")
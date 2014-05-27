require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require(lattice)
require(rgl)
library(akima)

mycolors.trans = rgb(c(255,0,0), 
                     c(0,255,0), 
                     c(0,0,255),alpha = 70,maxColorValue = 255) 

mycolors = rgb(c(255,0,0), 
               c(0,255,0), 
               c(0,0,255),maxColorValue = 255) 


data=read.csv("~/workspace-seninp/jmotif/beef_loocv_threaded1_noreduction_3.csv",
              sep=",",dec=".",head=F)
names(data)=c("strategy","window","paa","alphabet","acc","error")
str(data)
ddply(data, c("window"), summarize, mean=mean(error))

nored20=data[data$window==19,]
nored21=data[data$window==18,]


dd = data.frame(x=nored20$paa, y=nored20$alphabet, z=nored20$error*100)
im <- with(dd,interp(x,y,z,duplicate="strip"))

persp3d(x=im$x, y=im$y, z=im$z,
        xlim=c(13,16), ylim=c(6,10), zlim=c(50, 80),
        col=mycolors.trans[1], xlab="paa", ylab="alphabet",zlab="error")
dd2 = data.frame(x=nored21$paa, y=nored21$alphabet, z=nored21$error*100)
im2 <- with(dd2,interp(x,y,z,duplicate="strip"))
persp3d(x=im2$x, y=im2$y, z=im2$z,
        xlim=c(13,16), ylim=c(6,10), zlim=c(0.3, 0.8),
        col=mycolors.trans[2], add=T)

data=read.csv("~/workspace-seninp/jmotif/beef1_threaded_run.csv",
              sep=",",dec=".",head=F)
names(data)=c("strategy","window","paa","alphabet","acc","error")
str(data)

nored20=data[data$strategy == "NOREDUCTION" & data$window==20,]
nored21=data[data$strategy == "NOREDUCTION" & data$window==21,]
mean(nored21$error)
mean(nored20$error)

dd = data.frame(x=nored20$paa, y=nored20$alphabet, z=nored20$error*100)
im <- with(dd,interp(x,y,z,duplicate="strip"))

persp3d(x=im$x, y=im$y, z=im$z,
        xlim=c(12,18), ylim=c(6,10), zlim=c(10, 30),
        col=mycolors.trans[1], xlab="paa", ylab="alphabet",zlab="error")
dd2 = data.frame(x=nored21$paa, y=nored21$alphabet, z=nored21$error*100)
im2 <- with(dd2,interp(x,y,z,duplicate="strip"))
persp3d(x=im2$x, y=im2$y, z=im2$z,
        xlim=c(12,18), ylim=c(6,10), zlim=c(10, 30),
        col=mycolors.trans[2], add=T)

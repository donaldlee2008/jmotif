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

data=read.csv("~/tmp//08_Beef_nored.csv",sep=";",dec=",",head=F)
names(data)=c("strategy","window","paa","alphabet","acc","error")

nored20=nored[nored$window==20,]
nored21=nored[nored$window==21,]

nored20$strategy="W_20"
nored21$strategy="W_21"

dat=rbind(nored20,nored21)

mycolors.trans = rgb(c(255,0,0), 
                     c(0,255,0), 
                     c(0,0,255),alpha = 70,maxColorValue = 255) 

mycolors = rgb(c(255,0,0), 
               c(0,255,0), 
               c(0,0,255),maxColorValue = 255) 


p=wireframe(error ~ paa * alphabet, data = dat, group = strategy,
            scales = list(arrows = FALSE),
            #drape = TRUE, colorkey = TRUE, pretty=TRUE, 
            pretty=TRUE, 
            screen = list(z = 160, x = -60, y = 00),
            aspect = c(87/97, 0.6),
            #xlim=range(dat$paa), ylim=range(dat$alphabet), zlim=c(0, 1.0),
            xlim=c(12,18), ylim=c(6,10), zlim=c(0.3, 0.8),
            main=paste("CBF Classifier error rate"),
            #auto.key=TRUE,
            col.groups=mycolors.trans,
            key=list(text=list(c("W20","W21"),col=mycolors[1:2]),
                     lines=list(lty=c(1,1),col=mycolors[1:2])),
            par.settings = list(axis.line = list(col = "transparent")))
p

dd = data.frame(x=nored20$paa, y=nored20$alphabet, z=nored20$error*100)
im <- with(dd,interp(x,y,z,duplicate="strip"))

persp3d(x=im$x, y=im$y, z=im$z,
        xlim=c(12,18), ylim=c(6,10), zlim=c(0.3, 0.8),
        col=mycolors.trans[1])
dd2 = data.frame(x=nored21$paa, y=nored21$alphabet, z=nored21$error*100)
im2 <- with(dd2,interp(x,y,z,duplicate="strip"))
persp3d(x=im2$x, y=im2$y, z=im2$z,
        xlim=c(12,18), ylim=c(6,10), zlim=c(0.3, 0.8),
        col=mycolors.trans[2], add=T)

min(data$error)
data[data$error==min(data$error),]


data=read.csv("~/tmp//08_Beef_explorer.csv",sep=";",dec=",",head=F)
names(data)=c("strategy","window","paa","alphabet","acc","error")
nored20=data[data$strategy=="NOREDUCTION" & data$window==20,]
nored21=data[data$strategy=="NOREDUCTION" & data$window==21,]

nored20$strategy="W_20"
nored21$strategy="W_21"
dat=rbind(nored20,nored21)
str(dat)
p=wireframe(error ~ paa * alphabet, data = dat, group = strategy,
            scales = list(arrows = FALSE),
            #drape = TRUE, colorkey = TRUE, pretty=TRUE, 
            pretty=TRUE, 
            screen = list(z = 160, x = -60, y = 00),
            aspect = c(87/97, 0.6),
            #xlim=range(dat$paa), ylim=range(dat$alphabet), zlim=c(0, 1.0),
            xlim=c(14,20), ylim=c(3,10), zlim=c(0.0, 1.0),
            main=paste("CBF Classifier error rate"),
            #auto.key=TRUE,
            col.groups=mycolors.trans,
            key=list(text=list(c("W20","W21"),col=mycolors),
                     lines=list(lty=c(1,1),col=mycolors)),
            par.settings = list(axis.line = list(col = "transparent")))
p

#
#
#
data=read.csv("~/workspace-seninp/jmotif//beef_loocv_threaded1_noreduction_3.csv",
              sep=",",dec=".",head=F)
names(data)=c("strategy","window","paa","alphabet","acc","error")
str(data)
nored20=data[data$window==20,]
nored21=data[data$window==21,]

nored20$strategy="W_20"
nored21$strategy="W_21"

dat=rbind(nored20,nored21)

mycolors.trans = rgb(c(255,0,0), 
                     c(0,255,0), 
                     c(0,0,255),alpha = 70,maxColorValue = 255) 

mycolors = rgb(c(255,0,0), 
               c(0,255,0), 
               c(0,0,255),maxColorValue = 255) 


p=wireframe(error ~ paa * alphabet, data = dat, group = strategy,
            scales = list(arrows = FALSE),
            #drape = TRUE, colorkey = TRUE, pretty=TRUE, 
            pretty=TRUE, 
            screen = list(z = 160, x = -60, y = 00),
            aspect = c(87/97, 0.6),
            #xlim=range(dat$paa), ylim=range(dat$alphabet), zlim=c(0, 1.0),
            xlim=c(11,17), ylim=c(4,10), zlim=c(0.3, 0.8),
            main=paste("CBF Classifier error rate"),
            #auto.key=TRUE,
            col.groups=mycolors.trans,
            key=list(text=list(c("W20","W21"),col=mycolors[1:2]),
                     lines=list(lty=c(1,1),col=mycolors[1:2])),
            par.settings = list(axis.line = list(col = "transparent")))
p

dd = data.frame(x=nored20$paa, y=nored20$alphabet, z=nored20$error*100)
im <- with(dd,interp(x,y,z,duplicate="strip"))

persp3d(x=im$x, y=im$y, z=im$z,
        xlim=c(12,18), ylim=c(6,10), zlim=c(40, 90),
        col=mycolors.trans[1])
dd2 = data.frame(x=nored21$paa, y=nored21$alphabet, z=nored21$error*100)
im2 <- with(dd2,interp(x,y,z,duplicate="strip"))
persp3d(x=im2$x, y=im2$y, z=im2$z,
        xlim=c(12,18), ylim=c(6,10), zlim=c(40, 90),
        col=mycolors.trans[2], add=T)

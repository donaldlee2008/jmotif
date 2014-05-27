require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require(lattice)
require(colorRamps)
#
trellis.par.set(
  list(layout.heights =
         list(top.padding = 0,
              main.key.padding = 0,key.axis.padding = 0,
              axis.xlab.padding = 0,xlab.key.padding = 0,
              key.sub.padding = 0,bottom.padding = 0),
       layout.widths =
         list(left.padding = 0,key.ylab.padding = 0,
              ylab.axis.padding = 0,axis.key.padding = 0,right.padding = 0)))
#
dat = read.table(file="pkdd/synthetic_direct_full.csv",sep=",")
names(dat)=c("Startegy","Window","PAA","Alphabet","Error")
dat[rev(order(dat[,5])),]
t=45
cols=c(green2red(t), rep("red",(1001-t)))

min(dat$Window)
max(dat$Window)

min(dat$PAA)
max(dat$PAA)

min(dat$Alphabet)
max(dat$Alphabet)

(14*22*45)/131

par.set <-
  list(axis.line = list(col = "transparent"),
       clip = list(panel = "off"))
p0=cloud(PAA ~ Alphabet * Window, data = dat, col=cols[floor(dat$Error*1001+1)],
      cex = .8,
      screen = list(z = 60, x = -72, y = 3),
      par.settings = par.set,panel.aspect = 1.2,
      scales = list(arrows = FALSE),
      drape = TRUE, colorkey = FALSE,pretty=TRUE)
p0

Cairo(width = 800, height = 800, 
      file="pkdd/sc_all3D.ps", 
      type="ps", pointsize=18, 
      bg = "transparent", canvas = "white", units = "px", dpi = 82)
print(
  cloud(PAA ~ Alphabet * Window, data = dat, col=cols[floor(dat$Error*1001+1)],
        cex = .8, main = "Noreduction",
        screen = list(z = 60, x = -72, y = 3),
        par.settings = par.set,panel.aspect = 1.2,
        scales = list(arrows = FALSE),
        drape = TRUE, colorkey = FALSE,pretty=TRUE)
)
dev.off()
#
# Heatmap with window
#
dat = read.table(file="pkdd/synthetic_loocv18_exact_18.csv",sep=",")
names(dat)=c("Strategy","Window","PAA","Alphabet","Accuracy","Error")
dd = read.table(file="pkdd/direct_exact.csv",sep=",")
names(dd)=c("Iteration","Strategy","Window","PAA","Alphabet","Error")
dd$PAA<-round(dd$PAA)
dd$Window<-round(dd$Window)
dd$Alphabet<-round(dd$Alphabet)
dd[rev(order(dd[,6])),]

p1 <- ggplot(dat, aes(PAA,Alphabet)) + geom_tile(aes(fill=Error), colour="grey") + theme_minimal() +
  scale_fill_gradientn(colours = terrain.colors(100), limits=c(0.0, 1.0))+
  scale_x_continuous(expand=c(0,1)) + scale_y_continuous(expand=c(0,1)) +
  theme(legend.position = "none",
        axis.text.x=element_text(size=16), axis.text.y=element_text(size=16),
        axis.title.x=element_text(size=18),axis.title.y=element_text(size=18)
  )
p1

Cairo(width = 600, height = 600, 
      file="pkdd/sc_heat.ps", 
      type="ps", pointsize=18, 
      bg = "transparent", canvas = "white", units = "px", dpi = 82)
print(p1)
dev.off()

#
# Rectangles
#
colours = terrain.colors(100)
d=data.frame( x1=c(3), x2=c(30), y1=c(2), y2=c(18),col=c(0.83))
pt=ggplot() + theme_minimal() +
  geom_rect(data=d, mapping=aes(xmin=x1, xmax=x2, ymin=y1, ymax=y2),
            fill=paste(colours[round(d$col*100)]), color="black") +
  scale_x_continuous(name="PAA") + 
  scale_y_continuous(name="Alphabet")+
  theme(legend.position = "none",
        axis.text.x=element_text(size=16), axis.text.y=element_text(size=16),
        axis.title.x=element_text(size=18),axis.title.y=element_text(size=18)
  )
pt
# 
# [42.0, 16.5, 10.0], 0.8333333333333334
#
d=data.frame(x1=c(3,21), x2=c(12,30), y1=c(2,2), y2=c(18,18), col=c(0.34,0.83))
pt=pt + geom_rect(data=d, mapping=aes(xmin=x1, xmax=x2, ymin=y1, ymax=y2),
            fill=paste(colours[round(d$col*100)]), color="black")
pt
#
# [42.0, 25.499999999999996, 10.0], 0.8333333333333334
# [42.0, 7.500000000000001, 10.0], 0.34
#
d=data.frame(x1=c(12,12), x2=c(21,21), y1=c(2,12.7), y2=c(7.3,18), col=c(0.77,0.83))
pt=pt +
  geom_rect(data=d, mapping=aes(xmin=x1, xmax=x2, ymin=y1, ymax=y2), 
            fill=paste(colours[round(d$col*100)]), color="black")
pt
#
# [42.0, 16.5, 15.333333333333332], 0.8333333333333334
# [42.0, 16.5, 4.666666666666667], 0.77
#
d=data.frame(x1=c(12,12), x2=c(21,21), y1=c(2,12.7), y2=c(7.3,18), col=c(0.77,0.83))
pt=pt +
  geom_rect(data=d, mapping=aes(xmin=x1, xmax=x2, ymin=y1, ymax=y2), 
            fill=paste(colours[round(d$col*100)]), color="black")
pt
#
# [42.0, 7.500000000000001, 15.333333333333332], 0.6433333333333333
# [42.0, 7.500000000000001, 4.666666666666667], 0.043333333333333335
#
d=data.frame(x1=c(3,3), x2=c(12,12), y1=c(2,12.7), y2=c(7.3,18), col=c(0.04,0.64))
pt=pt +
  geom_rect(data=d, mapping=aes(xmin=x1, xmax=x2, ymin=y1, ymax=y2), 
            fill=paste(colours[round(d$col*100)]), color="black")
pt
#
# [42.0, 25.499999999999996, 10.0], 0.8333333333333334
# [42.0, 25.499999999999996, 15.333333333333332], 0.8333333333333334
# [42.0, 25.499999999999996, 4.666666666666667], 0.8333333333333334
#
d=data.frame(x1=c(21,21,21), x2=c(30,30,30), y1=c(2,7.3,12.7), y2=c(7.3,12.7,18), col=c(0.83,0.83,0.83))
pt=pt +
  geom_rect(data=d, mapping=aes(xmin=x1, xmax=x2, ymin=y1, ymax=y2), 
            fill=paste(colours[round(d$col*100)]), color="black")
pt
#
# [42.0, 10.5, 4.666666666666667], 0.29333333333333333
# [42.0, 4.500000000000001, 4.666666666666667], 0.11
#
d=data.frame(x1=c(3,9), x2=c(6,12), y1=c(2,2), y2=c(7.3,7.3), col=c(0.11,0.29))
pt=pt +
  geom_rect(data=d, mapping=aes(xmin=x1, xmax=x2, ymin=y1, ymax=y2), 
            fill=paste(colours[round(d$col*100)]), color="black")
pt
#
# [42.0, 7.500000000000001, 2.8888888888888893], 0.04
# [42.0, 7.500000000000001, 4.666666666666667], 0.043333333333333335
# [42.0, 7.500000000000001, 6.444444444444445], 0.07666666666666666
#
d=data.frame(x1=c(6,6,6), x2=c(9,9,9), y1=c(2,3.8,5.5), y2=c(3.8,5.5,7.3), col=c(0.04,0.043,0.076))
pt=pt +
  geom_rect(data=d, mapping=aes(xmin=x1, xmax=x2, ymin=y1, ymax=y2), 
            fill=paste(colours[round(d$col*100)]), color="black")
pt
#
#d=data.frame(x1=c(21,24,24,24,27), x2=c(24,27,27,27,30),
#             y1=c(2,5.5,3.8,2,2), y2=c(7.3,7.3,5.5,3.8,7.3), col=c(0.83,0.83,0.83,0.53,0.83))
#pt=pt +
#  geom_rect(data=d, mapping=aes(xmin=x1, xmax=x2, ymin=y1, ymax=y2), 
#            fill=paste(colours[round(d$col*100)]), color="black")
#pt
#
dd[dd$PAA>12&dd$PAA<21,]
d=data.frame(x1=c(12,15,15,15,18), x2=c(15,18,18,18,21),
             y1=c(2,5.5,3.8,2,2), y2=c(7.3,7.3,5.5,3.8,7.3), col=c(0.59,0.80,0.77,0.22,0.82))
pt=pt +
  geom_rect(data=d, mapping=aes(xmin=x1, xmax=x2, ymin=y1, ymax=y2), 
            fill=paste(colours[round(d$col*100)]), color="black")
pt
#
dd[dd$Alphabet>12.7,]
d=data.frame(x1=c(3,3,3,6,6,6,9), x2=c(6,6,6,9,9,9,12),
             y1=c(16.2,14.5,12.7,16.2,14.5,12.7,12.7), y2=c(18,16.2,14.5,18,16.2,14.5,18),
             col=c(0.14,0.10,0.11, 0.71,0.64,0.59, 0.82))
pt=pt +
  geom_rect(data=d, mapping=aes(xmin=x1, xmax=x2, ymin=y1, ymax=y2), 
            fill=paste(colours[round(d$col*100)]), color="black")
pt
#
dd[dd$Alphabet<12.7 & dd$Alphabet>7,]
d=data.frame(x1=c(3,3,3,6,6,6,9), x2=c(6,6,6,9,9,9,12),
             y1=c(10.9,9.1,7.3,10.9,9.1,7.3,7.3), y2=c(12.7,10.9,9.1,12.7,10.9,9.1,12.7),
             col=c(0.11,0.10,0.10, 0.44,0.34,0.19, 0.74))
pt=pt +
  geom_rect(data=d, mapping=aes(xmin=x1, xmax=x2, ymin=y1, ymax=y2), 
            fill=paste(colours[round(d$col*100)]), color="black")
pt
#
dd[(dd$PAA>3 & dd$PAA<6)&(dd$Alphabet<5 & dd$Alphabet>2),]
d=data.frame(x1=c(3,3,3,9,9,9), x2=c(6,6,6,12,12,12),
             y1=c(2,3.8,5.5,2,3.8,5.5), y2=c(3.8,5.5,7.3,3.8,5.5,7.3),
             col=c(0.32,0.26,0.10, 0.44,0.34,0.19))
pt=pt +
  geom_rect(data=d, mapping=aes(xmin=x1, xmax=x2, ymin=y1, ymax=y2), 
            fill=paste(colours[round(d$col*100)]), color="black")
pt
#
#
dd[(dd$PAA>6 & dd$PAA<9)&(dd$Alphabet<6 & dd$Alphabet>3),]
d=data.frame(x1=c(6,6,6,7,7,7,8), x2=c(7,7,7,8,8,8,9),
             y1=c(4.9,4.4,3.8,4.9,4.4,3.8,3.8), y2=c(5.5,4.9,4.4,5.5,4.9,4.4,5.5),
             col=c(0.013,0.033,0.03, 0.043,0.020,0.04, 0.13))
pt=pt +
  geom_rect(data=d, mapping=aes(xmin=x1, xmax=x2, ymin=y1, ymax=y2), 
            fill=paste(colours[round(d$col*100)]), color="black")
pt
#
#
dd[(dd$PAA>6 & dd$PAA<9)&(dd$Alphabet<3.8 & dd$Alphabet>2),]
d=data.frame(x1=c(6,7,7,7,8), x2=c(7,8,8,8,9),
             y1=c(2,3.2,2.6,2,2), y2=c(3.8,3.8,3.2,2.6,3.8),
             col=c(0.05, 0.04,0.04,0.22, 0.05))
pt=pt +
  geom_rect(data=d, mapping=aes(xmin=x1, xmax=x2, ymin=y1, ymax=y2), 
            fill=paste(colours[round(d$col*100)]), color="black")
pt

dd = read.table(file="pkdd/synthetic_direct_42.csv",sep=",")
names(dd)=c("Strategy","Window","PAA","Alphabet","Error")
pt=pt + geom_point(data=dd,aes(x=PAA,y=Alphabet),size=1)

Cairo(width = 600, height = 600, 
      file="pkdd/sc_direct.ps", 
      type="ps", pointsize=18, 
      bg = "transparent", canvas = "white", units = "px", dpi = 82)
print(pt)
dev.off()

print(p0,
      split = c(1,1,3,1), more = TRUE)
print(p1,
      split = c(2,1,3,1), more = TRUE)
print(pt,
      split = c(3,1,3,1))
print(arrangeGrob(p0, p1, pt, ncol=3))

Cairo(width = 1500, height = 500, 
      file="pkdd/plots.ps", 
      type="ps", pointsize=18, 
      bg = "transparent", canvas = "white", units = "px", dpi = 82)
print(arrangeGrob(p0, p1, pt, ncol=3))
dev.off()
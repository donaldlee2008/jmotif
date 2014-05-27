require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require(lattice)

dat = read.table("../data/CBF/CBF_TRAIN",header=F)

dat=t(dat)

ones=(dat[,dat[1,]==1])[-1,1]
twos=(dat[,dat[1,]==2])[-1,1]
threes=(dat[,dat[1,]==3])[-1,1]

# Take the twelve series and melt (or equivalently, stack) them:
dm <- melt(cbind(ones,twos,threes))
# add an index variable:
dm$index <- rep(1:128, 3)
dm$class <- c(rep("Cylinder",(128*1)), rep("Bell",(128*1)), rep("Funnel",(128*1)))

# dm$variable is a factor with a level for each series; use it
# as a grouping variable. dm$value holds the values of each series.

# This produces a 'spaghetti plot' (familiar to mixed modelers):
p = ggplot(dm, aes(x = index, y = value, group = X2, color=class)) +
  theme_bw() + geom_line() + geom_hline(yintercept=0,lty=2) +
  ggtitle("Sample of three CBF classes") +
  scale_x_continuous("time ticks", limits=c(0,128), breaks=seq(0,128,25)) + 
  scale_y_continuous("Value",limits=c(-2,3),breaks=seq(-2,3,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p

Cairo(width = 750, height = 250, file="cbf/all_classes.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(p)
dev.off()
#
#
#
p1 = ggplot(dm[dm$X2=="ones",], aes(x = index, y = value, group = X2, color="black")) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 1, Cylinder") +
  scale_x_continuous("time ticks", limits=c(0,128), breaks=seq(0,128,25)) + 
  scale_y_continuous("Value",limits=c(-2,3),breaks=seq(-2,3,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p1
#
#
#
p2 = ggplot(dm[dm$X2=="twos",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 2, Bell") +
  scale_x_continuous("time ticks", limits=c(0,128), breaks=seq(0,128,25)) + 
  scale_y_continuous("Value",limits=c(-2,3),breaks=seq(-2,3,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p2
#
#
#
p3 = ggplot(dm[dm$X2=="threes",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 3, Funnel") +
  scale_x_continuous("time ticks", limits=c(0,128), breaks=seq(0,128,25)) + 
  scale_y_continuous("Value",limits=c(-2,3),breaks=seq(-2,3,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p3

print(arrangeGrob(p1, p2, p3, ncol=3))

Cairo(width = 750, height = 350, file="cbf/classes.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(p1, p2, p3, ncol=2))
dev.off()


# all the 3D stuff here
#
#

wireframe(volcano, shade = TRUE,
          aspect = c(61/87, 0.4),
          light.source = c(10,0,10))
str(volcano)

g <- expand.grid(x = 1:10, y = 5:15, gr = 1:2)
g$z <- log((g$x^g$g + g$y^2) * g$gr)
wireframe(z ~ x * y, data = g, groups = gr,
          scales = list(arrows = FALSE),
          drape = TRUE, colorkey = TRUE,
          screen = list(z = 30, x = -60))

#
# cherry-picker
#
data=read.csv("cbf/test_exact/output_28.csv",head=F)
names(data)=c("paa","Alphabet","WINDOW","acc","Error")
unique(data$WINDOW)
data[data$Error==min(data$Error),]
i=44
d=data[data[3]==i,]
p=wireframe(Error ~ paa * Alphabet, data = d, scales = list(arrows = FALSE),
            drape = TRUE, colorkey = TRUE, pretty=TRUE, screen = list(z = 10, x = -60, y = 00),
            aspect = c(87/97, 0.6),
            xlim=range(data$paa), ylim=range(data$Alphabet), zlim=c(0, 0.7),
            main=paste("CBF Classifier error rate, SLIDING_WINDOW=", i),
            col.regions = terrain.colors(100, alpha = 1) )
p
Cairo(width = 700, height = 550, file="cbf/parameters.png", type="png", pointsize=12, 
      bg = "white", canvas = "white", units = "px", dpi = "auto")
print(p)
dev.off()
#
#
p1 <- ggplot(d, aes(paa,Alphabet)) + geom_tile(aes(fill=Error), colour="white") +
  scale_fill_gradientn(colours = terrain.colors(100), limits=c(0.0, 1.0)) +
 ggtitle(paste("CBF Classifier error rate, SLIDING_WINDOW=", i))
p1
fname=paste("cbf/map",i,".png",sep="")
Cairo(width = 700, height = 350, file="cbf/parameters2.png", type="png", pointsize=12, 
      bg = "white", canvas = "white", units = "px", dpi = "auto")
print(p1)
dev.off()

#
# movie loop
#


data=read.csv("cbf/test_exact/output_28.csv",head=F)
names(data)=c("paa","Alphabet","WINDOW","acc","Error")
data=data.frame(data)
for(i in c(unique(unlist(data[3])))){
  print(i)
 d=data[data[3]==i,]
  p=wireframe(Error ~ paa * Alphabet, data = d, scales = list(arrows = FALSE),
              drape = TRUE, colorkey = TRUE, pretty=TRUE, screen = list(z = 10, x = -60, y = 00),
              aspect = c(87/97, 0.6),
              xlim=range(data$paa), ylim=range(data$Alphabet), zlim=c(0, 0.7),
              main=paste("CBF Classifier error rate, SLIDING_WINDOW=", i),
              col.regions = terrain.colors(100, alpha = 1) )
 fname=paste("cbf/surface",i,".png",sep="")
 print(fname)
 #Cairo(width = 700, height = 550, file=fname, type="png", pointsize=12, 
#       bg = "white", canvas = "white", units = "px", dpi = "auto")
# print(p)
# dev.off()

  p1 <- ggplot(d, aes(paa,Alphabet)) + geom_tile(aes(fill=Error), colour="white") +
    scale_fill_gradientn(colours = terrain.colors(100), limits=c(0.0, 1.0)) +
    ggtitle(paste("CBF Classifier error rate, SLIDING_WINDOW=", i))
  fname=paste("cbf/map",i,".png",sep="")
  Cairo(width = 700, height = 350, file=fname, type="png", pointsize=12, 
        bg = "white", canvas = "white", units = "px", dpi = "auto")
  print(p1)
  dev.off()
}
#
# convert -delay 100 -loop 0 surface*.png par_surface.gif
#


d[d$paa==11,]

p1 <- ggplot(d, aes(Alphabet, paa)) + geom_tile(aes(fill=Error), colour="white") +
  scale_fill_gradient(low = "green", high = "red") + ggtitle("data 1")
p1

min(data$Error)
unique(data[3])


##------ Some palettes ------------
demo.pal <-
  function(n, border = if (n<32) "light gray" else NA,
           main = paste("color palettes;  n=",n),
           ch.col = c("rainbow(n, start=.7, end=.1)", "heat.colors(n)",
                      "terrain.colors(n)", "topo.colors(n)",
                      "cm.colors(n)"))
  {
    nt <- length(ch.col)
    i <- 1:n; j <- n / nt; d <- j/6; dy <- 2*d
    plot(i,i+d, type="n", yaxt="n", ylab="", main=main)
    for (k in 1:nt) {
      rect(i-.5, (k-1)*j+ dy, i+.4, k*j,
           col = eval(parse(text=ch.col[k])), border = border)
      text(2*j,  k * j +dy/4, ch.col[k])
    }
  }
n <- if(.Device == "postscript") 64 else 16
# Since for screen, larger n may give color allocation problem
demo.pal(500)
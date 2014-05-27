require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require("lattice")


#
# cherry-picker
#
data=read.csv("../CBFProgressivePrecisionExperiment.log",head=F)
dat=cbind(data[,5],data[,7:9])

names(dat)=c("loss","train_size",1, 2)
d=melt(dat,id=c("loss","train_size"))
gr<-c(rep(1,180),rep(2,180))
d=cbind(d,gr)
d[d$train==100 & d$loss==0,]

p=wireframe(value ~ loss * train_size, data = d, groups=gr,
            drape = TRUE, colorkey = TRUE, scales = list(arrows = FALSE),
            screen = list(z = 20, x = -80, y = 00),
            aspect = c(87/97, 0.6))
p

d[,3]
g$gr

g <- expand.grid(x = 1:10, y = 5:15, gr = 1:2)
g$z <- log((g$x^g$g + g$y^2) * g$gr)
wireframe(z ~ x * y, data = g, groups = gr,
          scales = list(arrows = FALSE),
          drape = TRUE, colorkey = TRUE,
          screen = list(z = 30, x = -60))




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
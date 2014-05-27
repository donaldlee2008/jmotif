#
# all the libs
require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
require(gridExtra)
require(lattice)


#
# plotting classes
dat = read.table("../data/50words/50words_TRAIN",header=F)

dat=t(dat)

unique(dat[1,])
d=as.vector((dat[,dat[1,]==41]))

par(mfrow=c(10,5),mai=c(0.1,0.1,0.1,0.1))
for(i in (1:50)){
  if(i==41){
    d=as.numeric((dat[,dat[1,]==i]))    
  }else{
    d=as.numeric((dat[,dat[1,]==i])[,1])
  }
  print(paste(i,d[2]))
  plot(d,xaxt='n',yaxt='n',ann=FALSE,type='l',bty='n')
}

require("lattice")

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

data=read.csv("yoga/res/single_pass/yoga_out_exact_80.csv",head=F)
data2=read.csv("yoga/res/double_pass/yoga_out_exact_double_pass330.csv",head=F)
names(data)=c("paa","Alphabet","WINDOW","acc","Error")
names(data2)=c("paa","Alphabet","WINDOW","acc","Error")

dat=data.frame(data, gr=rep("single pass",length(data[,1])))
dat2=data.frame(data2, gr=rep("double pass",length(data2[,1])))

d=dat2

p=wireframe(Error ~ paa * Alphabet, data = d, group=gr, scales = list(arrows = FALSE),
          drape = TRUE, colorkey = TRUE, screen = list(z = 10, x = -66, y=20),
            aspect = c(97/77, 0.8),
            xlim=range(d$paa), ylim=range(d$Alphabet), zlim=c(0.05, 0.25),
            main=paste("Gun/No Gun Classifier error rate, SLIDING_WINDOW=40"),
            col.regions = terrain.colors(100, alpha = 1) )
p


Cairo(width = 700, height = 750, file="gun/parameters.png", type="png", pointsize=12, 
      bg = "white", canvas = "white", units = "px", dpi = "auto")
print(p)
dev.off()


###
set.seed(3)
dat <- data.frame(Dates = rep(seq(Sys.Date(), Sys.Date() + 9, by = 1), 
                              each = 24),
                  Times = rep(0:23, times = 10),
                  Value = rep(c(0:12,11:1), times = 10) + rnorm(240))

new.dates <- with(dat, sort(unique(Dates)))
new.times <- with(dat, sort(unique(Times)))
new.values <- with(dat, matrix(Value, nrow = 10, ncol = 24, byrow = TRUE))

persp(new.dates, new.times, new.values, ticktype = "detailed", r = 10, 
      theta = 35, scale = FALSE)

require(lattice)
wireframe(Value ~ as.numeric(Dates) + Times, data = dat, drape = TRUE)

require(rgl)
open3d()
x <- sort(rnorm(1000))
y <- rnorm(1000)
z <- rnorm(1000) + atan2(x,y)
plot3d(data$paa, data$Alphabet, data$Error, type="l")
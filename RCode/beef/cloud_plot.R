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
              main.key.padding = 0,
              key.axis.padding = 0,
              axis.xlab.padding = 0,
              xlab.key.padding = 0,
              key.sub.padding = 0,
              bottom.padding = 0),
       layout.widths =
         list(left.padding = 0,
              key.ylab.padding = 0,
              ylab.axis.padding = 0,
              axis.key.padding = 0,
              right.padding = 0)))
#
#
threshold_iterations=16
threshold_error=0.05
#
data1=read.csv("../beef_direct.csv",head=F)
#
names(data1)=c("strategy","Window","PAA","Alphabet","Error")
#
# order by error ASC
#
dat1=data1[data1[,1]=="NOREDUCTION",]
dat1=dat1[order(dat1[,5]),]
#
# color all red except first 100 points
#
t=length(dat1[dat1$Error<threshold_error,]$strategy)
dat1$Color = c(green2red(t),rep("red",(length(dat1$strategy)-t)))

par.set <-
  list(axis.line = list(col = "transparent"), clip = list(panel = "off"))

p0=cloud(PAA ~ Alphabet * Window, data=dat1, col=dat1$Color, alpha=0.9,
         cex = .7, screen = list(z = 20, x = -70, y = 3),
         par.settings = par.set,panel.aspect = 1.1,
         scales = list(arrows = FALSE), main = "Noreduction",
         drape = TRUE, colorkey = FALSE,pretty=TRUE)
p0

data2=read.csv("../results/beef/exact.csv",head=F)
#
names(data2)=c("iteration","strategy","Window","PAA","Alphabet","Error")
#
# cut the num of iterations
#
dat2=data2[data2[,1] < threshold_iterations,]
#
# order by error ASC
#
dat2=dat2[order(dat2[,6]),]
#
# color all red except first 100 points
#
t=length(dat2[dat2$Error<threshold_error,]$strategy)
dat2$Color = c(green2red(t),rep("red",(length(dat2$strategy)-t)))

par.set <-
  list(axis.line = list(col = "transparent"), clip = list(panel = "off"))

p1=cloud(PAA ~ Alphabet * Window, data=dat2, col=dat2$Color, alpha=0.8,
         cex = .7, screen = list(z = 20, x = -70, y = 3),
         par.settings = par.set,panel.aspect = 1.1,
         scales = list(arrows = FALSE), main = "Exact",
         drape = TRUE, colorkey = FALSE,pretty=TRUE)
p1

data3=read.csv("../results/beef/classic.csv",head=F)
#
names(data3)=c("iteration","strategy","Window","PAA","Alphabet","Error")
#
# cut the num of iterations
#
dat3=data3[data3[,1] < threshold_iterations,]
#
# order by error ASC
#
dat3=dat3[order(dat3[,6]),]
#
# color all red except first 100 points
#
t=length(dat3[dat3$Error<threshold_error,]$strategy)
dat3$Color = c(green2red(t),rep("red",(length(dat3$strategy)-t)))

par.set <-
  list(axis.line = list(col = "transparent"), clip = list(panel = "off"))

p2=cloud(PAA ~ Alphabet * Window, data=dat3, col=dat3$Color, alpha=0.8,
         cex = .7, screen = list(z = 20, x = -70, y = 3),
         par.settings = par.set,panel.aspect = 1.1,
         scales = list(arrows = FALSE), main = "Classic",
         drape = TRUE, colorkey = FALSE,pretty=TRUE)
p2

grid.arrange(p0, p1, p2, ncol=3)

Cairo(width = 1200, height = 600, file="beef/beef_thesis_direct_plot.ps", 
      type="ps", pointsize=8, bg = "white", canvas = "white", 
      units = "px", dpi = 86)
print(arrangeGrob(p0, p1, p2, ncol=3))
dev.off()
1-195/243

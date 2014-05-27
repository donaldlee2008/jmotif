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
iterations=111
#
data1=read.csv("../tmp.csv",head=F)
#
names(data1)=c("strategy","Window","PAA","Alphabet","Error")
#
# order by error ASC
#
dat1=data1[order(data1[,5]),]
#
# color all red except first 100 points
#
t=70
dat1$Color = c(green2red(t),rep("red",(length(dat1$strategy)-t)))

par.set <-
  list(axis.line = list(col = "transparent"), clip = list(panel = "off"))

p0=cloud(PAA ~ Alphabet * Window, data=dat1, col=dat1$Color, alpha=0.2,
         cex = .8, screen = list(z = 60, x = -72, y = 3),
         par.settings = par.set,panel.aspect = 1.2,
         scales = list(arrows = FALSE),
         drape = TRUE, colorkey = FALSE,pretty=TRUE)
p0

data2=read.csv("../results/synthetic/exact.csv",head=F)
#
names(data2)=c("iteration","strategy","Window","PAA","Alphabet","Error")
#
# cut the num of iterations
#
dat2=data2[data2[,1] < iterations,]
#
# order by error ASC
#
dat2=dat2[order(dat2[,6]),]
#
# color all red except first 100 points
#
t=70
dat2$Color = c(green2red(t),rep("red",(length(dat2$strategy)-t)))

par.set <-
  list(axis.line = list(col = "transparent"), clip = list(panel = "off"))

p1=cloud(PAA ~ Alphabet * Window, data=dat2, col=dat2$Color, alpha=0.8,
         cex = .8, screen = list(z = 60, x = -72, y = 3),
         par.settings = par.set,panel.aspect = 1.2,
         scales = list(arrows = FALSE),
         drape = TRUE, colorkey = FALSE,pretty=TRUE)
p1

data3=read.csv("../results/synthetic/classic.csv",head=F)
#
names(data3)=c("iteration","strategy","Window","PAA","Alphabet","Error")
#
# cut the num of iterations
#
dat3=data3[data3[,1] < iterations,]
#
# order by error ASC
#
dat3=dat3[order(dat3[,6]),]
#
# color all red except first 100 points
#
t=100
dat3$Color = c(green2red(t),rep("red",(length(dat3$strategy)-t)))

par.set <-
  list(axis.line = list(col = "transparent"), clip = list(panel = "off"))

p2=cloud(PAA ~ Alphabet * Window, data=dat3, col=dat3$Color, alpha=0.8,
         cex = .8, screen = list(z = 60, x = -72, y = 3),
         par.settings = par.set,panel.aspect = 1.2,
         scales = list(arrows = FALSE),
         drape = TRUE, colorkey = FALSE,pretty=TRUE)
p2

grid.arrange(p0, p1, p2, ncol=3)

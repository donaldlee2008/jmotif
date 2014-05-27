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
dat = read.table(file="../direct/coffee_direct.csv",sep=",")
names(dat)=c("Startegy","Window","PAA","Alphabet","Error")
cbf.d.classic=dat[dat[,1]=="CLASSIC",]
cbf.d.exact=dat[dat[,1]=="EXACT",]
cbf.d.nored=dat[dat[,1]=="NOREDUCTION",]
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

t=3
cols=c(green2red(t), rep("red",(1001-t)))

par.set <-
  list(axis.line = list(col = "transparent"),
       clip = list(panel = "off"))
print(cloud(PAA ~ Alphabet * Window, data = cbf.d.nored, col=cols[floor(cbf.d.nored$Error*1000+1)],
            cex = .8, main = "Noreduction",
            screen = list(z = -50, x = -70, y = 3),
            par.settings = par.set,panel.aspect = 1.2,
            scales = list(arrows = FALSE),
            drape = TRUE, colorkey = FALSE,pretty=TRUE),
      split = c(1,1,3,1), more = TRUE)
print(cloud(PAA ~ Alphabet * Window, data = cbf.d.exact, col=cols[floor(cbf.d.exact$Error*1000+1)],
            cex = .8, main = "Exact",
            screen = list(z = -50, x = -70, y = 3),
            par.settings = par.set,panel.aspect = 1.2,
            scales = list(arrows = FALSE),
            drape = TRUE, colorkey = FALSE,pretty=TRUE),
      split = c(2,1,3,1), more = TRUE)
print(cloud(PAA ~ Alphabet * Window, data = cbf.d.classic, col=cols[floor(cbf.d.classic$Error*1000+1)],
            cex = .8, main = "Classic",
            screen = list(z = -50, x = -70, y = 3),
            par.settings = par.set,panel.aspect = 1.2,
            scales = list(arrows = FALSE),
            drape = TRUE, colorkey = FALSE,pretty=TRUE),
      split = c(3,1,3,1))



Cairo(width = 900, height = 350, file="jcool/coffee-direct.png", type="png", pointsize=12, 
      bg = "white", canvas = "white", units = "px", dpi = "auto")
print(cloud(PAA ~ Alphabet * Window, data = cbf.d.nored, col=cols[floor(cbf.d.nored$Error*1000+1)],
            cex = .8, main = "Noreduction",
            screen = list(z = -50, x = -70, y = 3),
            par.settings = par.set,panel.aspect = 1.2,
            scales = list(arrows = FALSE),
            drape = TRUE, colorkey = FALSE,pretty=TRUE),
      split = c(1,1,3,1), more = TRUE)
print(cloud(PAA ~ Alphabet * Window, data = cbf.d.exact, col=cols[floor(cbf.d.exact$Error*1000+1)],
            cex = .8, main = "Exact",
            screen = list(z = -50, x = -70, y = 3),
            par.settings = par.set,panel.aspect = 1.2,
            scales = list(arrows = FALSE),
            drape = TRUE, colorkey = FALSE,pretty=TRUE),
      split = c(2,1,3,1), more = TRUE)
print(cloud(PAA ~ Alphabet * Window, data = cbf.d.classic, col=cols[floor(cbf.d.classic$Error*1000+1)],
            cex = .8, main = "Classic",
            screen = list(z = -50, x = -70, y = 3),
            par.settings = par.set,panel.aspect = 1.2,
            scales = list(arrows = FALSE),
            drape = TRUE, colorkey = FALSE,pretty=TRUE),
      split = c(3,1,3,1))
dev.off()

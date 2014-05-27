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
dat = read.table(file="../cbf_direct_zoom_hold3.csv",sep=",")
names(dat)=c("Startegy","Window","PAA","Alphabet","Error")

w_min=50
w_max=100
p_min=2
p_max=12
a_min=10
a_max=18

cbf.d.classic=dat[((dat[,1]=="CLASSIC")&(dat[,2]>w_min&dat[,2]<w_max)&(dat[,3]>p_min&dat[,3]<p_max)&(dat[,4]>a_min&dat[,4]<a_max)),]
cbf.d.exact=dat[((dat[,1]=="EXACT")&(dat[,2]>w_min&dat[,2]<w_max)&(dat[,3]>p_min&dat[,3]<p_max)&(dat[,4]>a_min&dat[,4]<a_max)),]
cbf.d.nored=dat[((dat[,1]=="NOREDUCTION")&(dat[,2]>w_min&dat[,2]<w_max)&(dat[,3]>p_min&dat[,3]<p_max)&(dat[,4]>a_min&dat[,4]<a_max)),]

t=10
cols=c(green2red(t), rep("red",(1001-t)))

print(cloud(PAA ~ Alphabet * Window, data = cbf.d.nored, col=cols[floor(cbf.d.nored$Error*1000+1)],
            cex = .8, main = "Noreduction",
            screen = list(z = 20, x = -70, y = 3),
            par.settings = par.set,panel.aspect = 1,
            scales = list(arrows = FALSE),
            drape = TRUE, colorkey = FALSE,pretty=TRUE),
      split = c(1,1,3,1), more = TRUE)
print(cloud(PAA ~ Alphabet * Window, data = cbf.d.exact, col=cols[floor(cbf.d.exact$Error*1000+1)],
            cex = .8, main = "Exact",
            screen = list(z = 20, x = -70, y = 3),
            par.settings = par.set,panel.aspect = 1,
            scales = list(arrows = FALSE),
            drape = TRUE, colorkey = FALSE,pretty=TRUE),
      split = c(2,1,3,1), more = TRUE)
print(cloud(PAA ~ Alphabet * Window, data = cbf.d.classic, col=cols[floor(cbf.d.classic$Error*1000+1)],
            cex = .8, main = "Classic",
            screen = list(z = 20, x = -70, y = 3),
            par.settings = par.set,panel.aspect = 1,
            scales = list(arrows = FALSE),
            drape = TRUE, colorkey = FALSE,pretty=TRUE),
      split = c(3,1,3,1))

Cairo(width = 900, height = 350, file="jcool/cbf-direct-zoom.png", type="png", pointsize=12, 
      bg = "white", canvas = "white", units = "px", dpi = "auto")

par.set <-
  list(axis.line = list(col = "transparent"),
       clip = list(panel = "off"))
print(cloud(PAA ~ Alphabet * Window, data = cbf.d.nored, col=cols[floor(cbf.d.nored$Error*100+1)],
            cex = .8, main = "Noreduction",
            screen = list(z = 20, x = -70, y = 3),
            par.settings = par.set,panel.aspect = 1,
            scales = list(arrows = FALSE),
            drape = TRUE, colorkey = FALSE,pretty=TRUE),
      split = c(1,1,3,1), more = TRUE)
print(cloud(PAA ~ Alphabet * Window, data = cbf.d.exact, col=cols[floor(cbf.d.exact$Error*100+1)],
            cex = .8, main = "Exact",
            screen = list(z = 20, x = -70, y = 3),
            par.settings = par.set,panel.aspect = 1,
            scales = list(arrows = FALSE),
            drape = TRUE, colorkey = FALSE,pretty=TRUE),
      split = c(2,1,3,1), more = TRUE)
print(cloud(PAA ~ Alphabet * Window, data = cbf.d.classic, col=cols[floor(cbf.d.classic$Error*100+1)],
            cex = .8, main = "Classic",
            screen = list(z = 20, x = -70, y = 3),
            par.settings = par.set,panel.aspect = 1,
            scales = list(arrows = FALSE),
            drape = TRUE, colorkey = FALSE,pretty=TRUE),
      split = c(3,1,3,1))

dev.off()

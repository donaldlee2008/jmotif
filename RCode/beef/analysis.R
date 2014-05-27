require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require("lattice")

dat = read.csv("../beef_loocv_threaded_classic_1.csv",header=F)
names(dat)=c("Strategy","paa","Alphabet","WINDOW","acc","Error")
min(dat$Error)
dat[dat$Error==min(dat$Error),]


#
#
#
data=read.csv("synthetic/out.single.exact.csv",head=F)
names(data)=c("paa","Alphabet","WINDOW","acc","Error")
min(data$Error)
data=data.frame(data)
d=data[data[3]==40,]
p=wireframe(Error ~ paa * Alphabet, data = d, scales = list(arrows = FALSE),
            drape = TRUE, colorkey = TRUE, pretty=TRUE, screen = list(z = 10, x = -60, y = 00),
            aspect = c(87/97, 0.6),
            xlim=range(data$paa), ylim=range(data$Alphabet), zlim=c(0, 0.9),
            main=paste("Synthetic Control classifier error rate, SLIDING_WINDOW=40"),
            col.regions = terrain.colors(100, alpha = 1) )
p

Cairo(width = 750, height = 600, file="synthetic/parameters.png", type="png", pointsize=12, 
      bg = "white", canvas = "white", units = "px", dpi = "auto")
print(p)
dev.off()
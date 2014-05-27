require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require(lattice)
#
#
data=read.csv("synthetic/synthetic_loocv_threaded_noreduction_1.csv",head=F)
data=read.csv("../synthetic_angles_classic.csv",head=F)
#
names(data)=c("strategy","window","paa","alphabet","min","mean","max")
max(data$max)
data[data$max==min(data$max),]
data[data$mean==min(data$mean),]
data[data$min==max(data$min),]

data[data$paa==8,]

data=data.frame(data)
d=data[data[3]==8,]
p=wireframe(mean ~ alphabet * window, data = d, scales = list(arrows = FALSE),
            drape = TRUE, colorkey = TRUE, pretty=TRUE, screen = list(z = 10, x = -60, y = 00),
            aspect = c(87/97, 0.6),
            main=paste("Synthetic Control classifier error rate, SLIDING_WINDOW=45"),
            col.regions = terrain.colors(100, alpha = 1) )
p

Cairo(width = 750, height = 600, file="synthetic/parameters.png", type="png", pointsize=12, 
      bg = "white", canvas = "white", units = "px", dpi = "auto")
print(p)
dev.off()
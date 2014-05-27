require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require(lattice)

read_data=function(name){
  res = read.csv(file=name,head=F)
  names(res)=c("window", "paa","alphabet","accuracy","Error")
  res
}
res = read_data("plane.txt")

d=data.frame(res)

p0=wireframe(Error ~ window * alphabet, data = d, scales = list(arrows = FALSE),
            drape = TRUE, colorkey = TRUE, screen = list(z = 0, x = -66, y=20),
            aspect = c(97/77, 0.8),
            xlim=range(res$window), ylim=range(res$alphabet), zlim=c(0, 1.0),
            main=paste("Window/Alphabet"),
            col.regions = terrain.colors(100, alpha = 1) )
p1=wireframe(Error ~ window * paa, data = d, scales = list(arrows = FALSE),
            drape = TRUE, colorkey = TRUE, screen = list(z = 0, x = -66, y=20),
            aspect = c(97/77, 0.8),
            xlim=range(res$window), ylim=range(res$paa), zlim=c(0, 1.0),
            main=paste("Window/PAA"),
            col.regions = terrain.colors(100, alpha = 1) )

print(arrangeGrob(p0, p1, ncol=2))
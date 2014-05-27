require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require("lattice")

exact = read.csv("log-w/gun_loocv_exact_1.csv", header=F)[,-1]
names(exact) = c("window","paa","alphabet","accuracy","error")
unique(exact$alphabet)
d=exact[exact$paa==12,]
pp=wireframe(error ~ window * alphabet, data = d, scales = list(arrows = FALSE),
            drape = TRUE, colorkey = TRUE, screen = list(z = 180, x = -70, y=10),
            aspect = c(97/77, 0.5),
            xlim=range(d$window), ylim=range(d$alphabet), zlim=range(d$error),
            main=paste("Gun dataset, Error rate with fixed PAA=14"),
            col.regions = terrain.colors(100, alpha = 1) )
pp

d=exact[exact$window==32,]
pw=wireframe(error ~ paa * alphabet, data = d, scales = list(arrows = FALSE),
             drape = TRUE, colorkey = TRUE, screen = list(z = 180, x = -70, y=10),
             aspect = c(97/77, 0.5),
             xlim=range(d$paa), ylim=range(d$alphabet), zlim=range(d$error),
             main=paste("Gun dataset, Error rate with fixed WINDOW=32"),
             col.regions = terrain.colors(100, alpha = 1) )
pw


d=exact[exact$alphabet==5,]
pa=wireframe(error ~ paa * window, data = d, scales = list(arrows = FALSE),
             drape = TRUE, colorkey = TRUE, screen = list(z = -90, x = -60, y=20),
             aspect = c(97/77, 0.5),
             xlim=range(d$paa), ylim=range(d$window), zlim=range(d$error),
             main=paste("Gun dataset, Error rate with fixed ALPHABET=5"),
             col.regions = terrain.colors(100, alpha = 1) )
pa

print(arrangeGrob(pp, pw, pa, ncol=1))

Cairo(width = 750, height = 200, file="yoga/classes.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(p1, p2, ncol=2))
dev.off()

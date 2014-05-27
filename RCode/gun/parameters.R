require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require("lattice")

dat = read.table("../data/Gun_Point/Gun_Point_TRAIN",header=F)
unique(dat[,1])

dat=t(dat)
ones=(dat[,dat[1,]==1])[-1,1]
twos=(dat[,dat[1,]==2])[-1,1]
# Take the twelve series and melt (or equivalently, stack) them:
dm <- melt(cbind(ones,twos))
# add an index variable:
dm$index <- rep(1:150, 2)
dm$class <- c(rep("Gun",(150*1)), rep("No Gun",(150*1)))

# dm$variable is a factor with a level for each series; use it
# as a grouping variable. dm$value holds the values of each series.

# This produces a 'spaghetti plot' (familiar to mixed modelers):
p = ggplot(dm, aes(x = index, y = value, group = X2, color=class)) +
  theme_bw() + geom_line() + geom_hline(yintercept=0,lty=2) +
  ggtitle("Sample of two classes from Gun Point dataset") +
  scale_x_continuous("time ticks", limits=c(0,150), breaks=seq(0,150,50)) + 
  scale_y_continuous("Value",limits=c(-1,2),breaks=seq(-1,2,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p
Cairo(width = 750, height = 250, file="gun/all_classes.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(p)
dev.off()
#
#
#
p1 = ggplot(dm[dm$X2=="ones",], aes(x = index, y = value, group = X2, color="black")) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class Gun") +
  scale_x_continuous("time ticks", limits=c(0,150), breaks=seq(0,150,50)) + 
  scale_y_continuous("Value",limits=c(-1,2),breaks=seq(-1,2,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p1
#
#
#
p2 = ggplot(dm[dm$X2=="twos",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class No Gun") +
  scale_x_continuous("time ticks", limits=c(0,150), breaks=seq(0,150,50)) + 
  scale_y_continuous("Value",limits=c(-1,2),breaks=seq(-1,2,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p2
#
#
#
print(arrangeGrob(p1, p2, ncol=2))

Cairo(width = 750, height = 200, file="gun/classes.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(p1, p2, ncol=2))
dev.off()


#
# explore the data
#
read_data=function(name){
  res = read.csv(file=name,head=F)
  names(res)=c("window", "paa","alphabet","acc","Error")
  res
}
res_classic = read_data("gun/res/gun_point_classic.csv")
res_noreduction = read_data("gun/res/gun_point_noreduction.csv")
res_exact = read_data("gun/res/gun_point_exact.csv")

(res_classic[with(res_classic, order(res_classic$Error)),])[1:20,]
(res_exact[with(res_exact, order(res_exact$Error)),])[1:20,]
(res_noreduction[with(res_noreduction, order(res_noreduction$Error)),])[1:20,]
require("lattice")

d=data.frame(res_exact[res_exact$window==40,])
min(d$paa)
max(d$alphabet)

p=wireframe(Error ~ paa * alphabet, data = d, scales = list(arrows = FALSE),
            drape = TRUE, colorkey = TRUE, screen = list(z = 210, x = -66, y=20),
            aspect = c(97/77, 0.8),
            xlim=range(data$paa), ylim=range(data$alphabet), zlim=c(0, 1.0),
            main=paste("Gun/No Gun Classifier error rate, SLIDING_WINDOW=40"),
            col.regions = terrain.colors(100, alpha = 1) )
p

#
# old code
#

require("lattice")

data=read.csv("gun/parameters.csv",head=F)
names(data)=c("paa","Alphabet","WINDOW","acc","Error")
data=data.frame(data)

d=data[data[3]==40,]

p=wireframe(Error ~ paa * Alphabet, data = d, scales = list(arrows = FALSE),
          drape = TRUE, colorkey = TRUE, screen = list(z = 210, x = -66, y=20),
            aspect = c(97/77, 0.8),
            xlim=range(data$paa), ylim=range(data$Alphabet), zlim=c(0, 1.0),
            main=paste("Gun/No Gun Classifier error rate, SLIDING_WINDOW=40"),
            col.regions = terrain.colors(100, alpha = 1) )
p


Cairo(width = 700, height = 750, file="gun/parameters.png", type="png", pointsize=12, 
      bg = "white", canvas = "white", units = "px", dpi = "auto")
print(p)
dev.off()
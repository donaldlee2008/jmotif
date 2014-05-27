require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require("lattice")

dat = read.table("../data/Yoga/yoga_TRAIN",header=F)
unique(dat[,1])

dat=t(dat)
ones=(dat[,dat[1,]==1])[-1,1]
twos=(dat[,dat[1,]==2])[-1,1]
# Take the twelve series and melt (or equivalently, stack) them:
dm <- melt(cbind(ones,twos))
# add an index variable:
dm$index <- rep(1:426, 2)
dm$class <- c(rep("Class 1",(426*1)), rep("Class 2",(426*1)))

# dm$variable is a factor with a level for each series; use it
# as a grouping variable. dm$value holds the values of each series.

# This produces a 'spaghetti plot' (familiar to mixed modelers):
p = ggplot(dm, aes(x = index, y = value, group = X2, color=class)) +
  theme_bw() + geom_line() + geom_hline(yintercept=0,lty=2) +
  ggtitle("Sample of two classes from Yoga dataset") +
  scale_x_continuous("time ticks", limits=c(0,426), breaks=seq(0,426,50)) + 
  scale_y_continuous("Value",limits=c(-2.5,2),breaks=seq(-2.5,2,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p
Cairo(width = 750, height = 250, file="yoga/all_classes.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(p)
dev.off()
#
#
#
p1 = ggplot(dm[dm$X2=="ones",], aes(x = index, y = value, group = X2, color="black")) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Yoga dataset, Class 1") +
  scale_x_continuous("time ticks", limits=c(0,426), breaks=seq(0,426,50)) + 
  scale_y_continuous("Value",limits=c(-2.5,2),breaks=seq(-2.5,2,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p1
#
#
#
p2 = ggplot(dm[dm$X2=="twos",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Yoga dataset, Class 2") +
  scale_x_continuous("time ticks", limits=c(0,426), breaks=seq(0,426,50)) + 
  scale_y_continuous("Value",limits=c(-2.5,2),breaks=seq(-2.5,2,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p2
#
#
#
print(arrangeGrob(p1, p2, ncol=2))

Cairo(width = 750, height = 200, file="yoga/classes.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(p1, p2, ncol=2))
dev.off()

##
##
##
##

data=read.csv("yoga/res/single_pass/yoga_out_exact_80.csv",head=F)
data2=read.csv("yoga/res/double_pass/yoga_out_exact_double_pass330.csv",head=F)
names(data)=c("paa","Alphabet","WINDOW","acc","Error")
names(data2)=c("paa","Alphabet","WINDOW","acc","Error")

min(data2[,5])

dat=data.frame(data, gr=rep("single pass",length(data[,1])))
dat2=data.frame(data2, gr=rep("double pass",length(data2[,1])))

d=dat2

p=wireframe(Error ~ paa * Alphabet, data = d, group=gr, scales = list(arrows = FALSE),
          drape = TRUE, colorkey = TRUE, screen = list(z = 40, x = -56, y=10),
            aspect = c(97/77, 0.8),
            xlim=range(d$paa), ylim=range(d$Alphabet), zlim=c(0.05, 0.2),
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
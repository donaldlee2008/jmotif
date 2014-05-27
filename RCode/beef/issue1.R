require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require("lattice")

dat = read.table("../data/Beef/Beef_TRAIN",header=F)

plot_series=function(dd, title){
  dd = as.data.frame(t(dd[,-1]))
  row.names(dd) <- NULL
  names(dd) = paste("series_",seq(1:length(dd[1,])),sep="")
  len = length(dd[,1]); count = length(dd[1,])
  dm=melt(dd,id.vars=NULL)
  names(dm)=c("series","value")
  dm$x = rep(seq(1:len),count)
  (ggplot(dm, aes(x = x, y = value, group = series))  +
    theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
    ggtitle(title))
}

p1=plot_series(dat[dat[,1]==1,], "Class 1")
p2=plot_series(dat[dat[,1]==2,], "Class 2")
p3=plot_series(dat[dat[,1]==3,], "Class 3")
p4=plot_series(dat[dat[,1]==4,], "Class 4")
p5=plot_series(dat[dat[,1]==5,], "Class 5")

print(arrangeGrob(p2, p3, p4, p5, ncol=2))

dd = as.matrix(dat[,-1])
znorm <- function(ts){
  ts.mean <- mean(ts)
  ts.dev <- sd(ts)
  as.vector((ts - ts.mean)/ts.dev)
}
dd = as.data.frame(apply(dd,1,znorm))
row.names(dd) <- NULL
len = length(dd[,1]); count = length(dd[1,])
names(dd) = c(paste("series_",rep(1,6),seq(1,6),sep=""),
              paste("series_",rep(2,6),seq(1,6),sep=""),
              paste("series_",rep(3,6),seq(1,6),sep=""),
              paste("series_",rep(4,6),seq(1,6),sep=""),
              paste("series_",rep(5,6),seq(1,6),sep=""))
dm=melt(dd,id.vars=NULL)
names(dm)=c("series","value")
dm$x = rep(seq(1:len),count)

add.alpha <- function(col, alpha){
  as.vector(apply(sapply(c, col2rgb)/255, 2, function(x) rgb(x[1], x[2], x[3], alpha=alpha)))
}
dm$color = rep(add.alpha(brewer.pal(6, 'Set1'),alpha=0.8),each=len*5)
dm$group = gsub("series_","class_",substr(dm$series,1,8))
p = ggplot(dm, aes(x = x, y = value, color=group, group=series))  +
  theme_bw() + geom_line() + geom_hline(yintercept=0,lty=2)
p

znorm <- function(ts){
  ts.mean <- mean(ts)
  ts.dev <- sd(ts)
  as.vector((ts - ts.mean)/ts.dev)
}

### -1
dat = read.table("../data/Beef/Beef_TRAIN",header=F)
dd = dat[dat[,1]!=1,]
dd = as.matrix(dd[,-1])

dd = as.data.frame(apply(dd,1,znorm))
row.names(dd) <- NULL
len = length(dd[,1]); count = length(dd[1,])
names(dd) = c(paste("series_",rep(2,6),seq(1,6),sep=""),
              paste("series_",rep(3,6),seq(1,6),sep=""),
              paste("series_",rep(4,6),seq(1,6),sep=""),
              paste("series_",rep(5,6),seq(1,6),sep=""))
dm=melt(dd,id.vars=NULL)
names(dm)=c("series","value")
dm$x = rep(seq(1:len),count)
add.alpha <- function(col, alpha){
  as.vector(apply(sapply(c, col2rgb)/255, 2, function(x) rgb(x[1], x[2], x[3], alpha=alpha)))
}
dm$color = rep(add.alpha(brewer.pal(6, 'Set1'),alpha=0.8),each=len*4)
dm$group = gsub("series_","class_",substr(dm$series,1,8))
p = ggplot(dm, aes(x = x, y = value, color=group, group=series))  +
  theme_bw() + geom_line() + geom_hline(yintercept=0,lty=2)
p

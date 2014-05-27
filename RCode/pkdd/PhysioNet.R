require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require("lattice")

dat=read.csv(file="../physio/PHYSIO_CLUSTER.csv",header=F,skip=0)
#
# number of classes
keys=as.character(unique(dat[,1]))
for(s in keys){
  print(paste("class", s, dim(dat[dat[,1]==s,])))
}
#
# printout
dat=t(dat)
dat[,1]
par(mfrow=c(3,2))
par(mfrow=c(3,2),mar = c(4,4,4,4))
plot((dat[,dat[1,]=="II"])[-1,314],type="l",xlim=c(1,700),
     frame.plot=F, col="blue", main="II")    
plot((dat[,dat[1,]=="AVR"])[-1,611],type="l",xlim=c(1,700),
     frame.plot=F, col="blue", main="AVR")    
plot((dat[,dat[1,]=="RESP"])[-1,223],type="l",xlim=c(1,700),
     frame.plot=F, col="blue", main="RESP")    
plot((dat[,dat[1,]=="PLETH"])[-1,1090],type="l",xlim=c(1,700),
     frame.plot=F, col="blue", main="PLETH")    
plot((dat[,dat[1,]=="CO2"])[-1,715],type="l",xlim=c(1,700),
     frame.plot=F, col="blue", main="CO2")    
#
p=function(index){
  par(mfrow=c(length(index)/2,3),mar = c(0,0,1,0))
  for(str in index){
    split=unlist(strsplit(str, "_"))
    plot((dat[,dat[1,]==split[1]])[-1,as.numeric(split[2])],type="l", xaxt='n', 
         yaxt='n', frame.plot=F, col="blue", main=paste(str))    
  }
}
#
# classes
keyCO2 = c( 467, 77, 161, 312, 408, 239, 1, 383, 264, 143, 423,
            443,58, 428, 183, 276, 416,  11, 334, 365 );
c=paste("CO2_",keyCO2,sep="")
p(c)
c=paste("CO2_",sample(1:500,20),sep="")
p(c)

key2 = c( 1449, 235, 1058, 668, 1310, 230, 501, 865, 551, 700, 1077,
          1242, 528, 1107, 881, 314, 483, 234, 1475, 725 );
c=paste("II_",key2,sep="")
p(c)
c=paste("II_",sample(1:1500,20),sep="")
p(c)


keyAVR = c(744, 681, 1038, 865, 855, 927, 1187, 814, 938, 88, 1012,
           716, 370, 1162, 923, 1361, 1368, 169, 1242, 1147 );
c=paste("AVR_",keyAVR,sep="")
p(c)
c=paste("AVR_",sample(1:1500,20),sep="")
p(c)

keyRESP = c( 793, 1440, 1111, 774, 1148, 1091, 1167, 764, 593, 1396, 1069,
             1011, 165, 920, 565, 1048, 200, 653, 1376, 1072 );
c=paste("RESP_",keyRESP,sep="")
p(c)
c=paste("RESP_",sample(1:1500,20),sep="")
p(c)

keyPLETH = c( 189, 82, 926, 13, 1005, 1220, 539, 1328, 990, 337, 226,
              640, 827, 931, 549, 870, 171, 567, 1231, 1398 );
c=paste("PLETH_",keyPLETH,sep="")
p(c)
c=paste("PLETH_",sample(1:1500,20),sep="")
p(c)

#
# build a dataset
#
add=function(c,index){
  for(str in index){
    split=unlist(strsplit(str, "_"))
    ser=as.numeric((dat[,dat[1,]==split[1]])[-1,as.numeric(split[2])])
    c=cbind(c,ser)
  }
  c
}
dd=rep(0,2049)

dd=add(dd,paste("II_",key2,sep=""))
dd=as.data.frame(dd[,-1])
dd=add(dd,paste("AVR_",keyAVR,sep=""))
dd=add(dd,paste("PLETH_",keyPLETH,sep=""))
dd=add(dd,paste("RESP_",keyRESP,sep=""))
dd=add(dd,paste("CO2_",keyCO2,sep=""))

names(dd)=c(paste("II_",key2,sep=""), paste("AVR_",keyAVR,sep=""),
            paste("PLETH_",keyPLETH,sep=""), paste("RESP_",keyRESP,sep=""),
            paste("CO2_",keyCO2,sep=""))

# a 2-dimensional example
x <- rbind(matrix(rnorm(10, sd = 0.3), ncol = 2),
           matrix(rnorm(10, mean = 1, sd = 0.3), ncol = 2))
colnames(x) <- c("x", "y")
(cl <- kmeans(dist(x), 3))
plot(x, col = cl$cluster)
points(cl$centers, col = 1:2, pch = 8, cex = 2)

(cl <- kmeans(dist(t(dd)), 5))
sum(cl$withinss)
(cbind( t(t(cl$cluster[1:20])), t(t(cl$cluster[21:40])),
        t(t(cl$cluster[41:60])), t(t(cl$cluster[61:80])),
        t(t(cl$cluster[81:100]))))







as.data.frame(t(t(cl$cluster[81:100])))
ddply(as.data.frame(t(t(cl$cluster[81:100]))), .(V1), summarize, NumSubs = length(unique(subjectid)))


str="AVR_98"
c=paste("II_",seq(1:20),sep="")


d=unlist(strsplit("V_782", "_"))
as.numeric(length(d))
p=3

as.numeric(d[2])
par()
plot((dat[,dat[1,]=="PLETH"])[-1,1948],type="l", xaxt='n', yaxt='n', ann=FALSE, frame.plot=F, col="blue")

par(mfrow=c(2,2))
plot((dat[,dat[1,]=="II"])[-1,314],type="l",xlim=c(1,700))
plot((dat[,dat[1,]=="RESP"])[-1,611],type="l",xlim=c(1,700))
plot((dat[,dat[1,]=="RESP"])[-1,223],type="l",xlim=c(1,700))
plot((dat[,dat[1,]=="RESP"])[-1,1090],type="l",xlim=c(1,700))

plot((dat[,dat[1,]=="PLETH"])[-1,412],type="l",xlim=c(1,300))
plot((dat[,dat[1,]=="RESP"])[-1,812],type="l",xlim=c(1,300))
plot((dat[,dat[1,]=="II"])[-1,212],type="l",xlim=c(1,300))
plot((dat[,dat[1,]=="AVR"])[-1,12],type="l",xlim=c(1,300))

plot((dat[,dat[1,]==keys[4]])[-1,1500],type="l")
plot((dat[,dat[1,]==keys[5]])[-1,2000],type="l")

check=keys[1]
plot((dat[,dat[1,]==check])[-1,1],type="l")
plot((dat[,dat[1,]==check])[-1,2],type="l")
plot((dat[,dat[1,]==check])[-1,3],type="l")
plot((dat[,dat[1,]==check])[-1,4],type="l")
plot((dat[,dat[1,]==check])[-1,5],type="l")

dat=read.csv(file="../physio/PHYSIO_TRAIN.csv",header=F,skip=0)
unique(dat[,1])
dat=t(dat)
ones=(dat[,dat[1,]==0])[-1,]
twos=(dat[,dat[1,]==1])[-1,100]
threes=(dat[,dat[1,]==2])[-1,100]
fours=(dat[,dat[1,]==3])[-1,100]
fives=(dat[,dat[1,]==4])[-1,100]
max(c(ones,twos,threes,fours,fives))
# Take the twelve series and melt (or equivalently, stack) them:
dm <- melt(cbind(ones,twos,threes,fours,fives))
# add an index variable:
dm$index <- rep(1:1000, 5)
dm$class <- c(rep("One",(1000*1)), rep("Two",(1000*1)), rep("Three",(1000*1)),
              rep("Four",(1000*1)), rep("Five",(1000*1)))

p1 = ggplot(dm[dm$X2=="ones",], aes(x = index, y = value, group = X2, color="black")) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 1") +
  theme(plot.title=element_text(size = 18, vjust = 2))
p1
#
#
#
p2 = ggplot(dm[dm$X2=="twos",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 2") +
  theme(plot.title=element_text(size = 18, vjust = 2))
p2
#
#
#
p3 = ggplot(dm[dm$X2=="threes",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 3") +
  theme(plot.title=element_text(size = 18, vjust = 2))
p3
#
#
#
p4 = ggplot(dm[dm$X2=="fours",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 4") +
  theme(plot.title=element_text(size = 18, vjust = 2))
p4
#
#
#
p5 = ggplot(dm[dm$X2=="fives",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 5") +
  theme(plot.title=element_text(size = 18, vjust = 2))
p5
#
#
print(arrangeGrob(p1, p2, p3, p4, p5, ncol=2))


#
theme_fullframe <- function (base_size = 12){
  structure(list(
    axis.line = element_blank(), 
    axis.text.x = element_blank(), 
    axis.text.y = element_blank(),
    axis.ticks = element_blank(), 
    axis.title.x = element_blank(), 
    axis.title.y = element_blank(), 
    axis.ticks.length = unit(0.01, "cm"), 
    axis.ticks.margin = unit(0.01, "cm"), 
    legend.position = "none", 
    panel.background = element_blank(), 
    panel.border = element_blank(), 
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank(), 
    panel.margin = unit(0, "lines"), 
    plot.background = element_blank(), 
    plot.margin = unit(0*c(-1.5, -1.5, -1.5, -1.5), "lines")
  ), class = "options")
}
#
gg_color_hue <- function(n) {
  hues = seq(15, 375, length=n+1)
  hcl(h=hues, l=65, c=100)[1:n]
}
col=gg_color_hue(5)
dev.new(width=4, height=4)
plot(1:6, pch=16, cex=2, col=gg_color_hue(6))

p=function(series, num, col){
  fname=paste(num,".ps",sep="")
  dm = data.frame(index=c(1:2048),value=series)
  p1 = ggplot(dm, aes(x = index, y = value)) +
    theme_bw() + geom_line(colour=col)+
    scale_x_continuous(expand=c(0,1)) + scale_y_continuous(expand=c(0,1)) +
    theme(
      axis.line = element_blank(), 
      axis.text.x = element_blank(), 
      axis.text.y = element_blank(),
      axis.ticks = element_blank(), 
      axis.title.x = element_blank(), 
      axis.title.y = element_blank(), 
      axis.ticks.length = unit(0.001, "cm"), 
      axis.ticks.margin = unit(0.001, "cm"), 
      legend.position = "none", 
      panel.background = element_blank(), 
      panel.border = element_blank(), 
      panel.grid.major = element_blank(), 
      panel.grid.minor = element_blank(), 
      panel.margin = unit(0, "lines"), 
      plot.background = element_blank(), 
      plot.margin = unit(0*c(-1.5, -1.5, -1.5, -1.5), "lines")
    )
  #Cairo(width = 250, height = 80, file=fname, type="png", pointsize=12, 
  #      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
  #print(p1)
  #dev.off()
  Cairo(width = 800, height = 150, 
        file=fname, 
        type="ps", pointsize=9, 
        bg = "transparent", canvas = "white", units = "px", dpi = 96)
  print(p1)
  dev.off()
}
#
#
#
dat=read.csv(file="../physio/PHYSIO_CLUSTER.csv",header=F,skip=0)
dat=t(dat)
par(mfrow=c(5,1))
plot((dat[,dat[1,]==0])[-1,2],type="l")
plot((dat[,dat[1,]==1])[-1,2],type="l")
plot((dat[,dat[1,]==2])[-1,2],type="l")
plot((dat[,dat[1,]==3])[-1,2],type="l")
plot((dat[,dat[1,]==4])[-1,5],type="l")

p((dat[,dat[1,]==0])[-1,2], 0, col[1])
p((dat[,dat[1,]==1])[-1,2], 1, col[2])
p((dat[,dat[1,]==2])[-1,2], 2, col[3])
p((dat[,dat[1,]==3])[-1,2], 3, col[4])
p((dat[,dat[1,]==4])[-1,2], 4, col[5])

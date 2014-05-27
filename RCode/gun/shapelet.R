require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require("lattice")
#
# define constants
#
series_len = 150
#
# get the data
#
raw = read.table("../data/Gun_Point/Gun_Point_TRAIN",header=F)
unique(raw[,1])
ones = raw[raw[,1]==1,-1]
twos = raw[raw[,1]==2,-1]

#====================== start business ======================

#Class key: 2
#"hhhgdbab", 0.2749090987917698
#0: [78]
#1: [73]
#4: [95]
#6: [75]
#8: [77]
pattern1_series_idx=c(0,1,4,6,8)+1
pattern1_series_pos=c(78,73,95,75,77)+1
patterns_num = length(pattern1_series_pos)
#
# extract series of interest
#
data=matrix(as.numeric(unlist(twos)),ncol=series_len,byrow=F)
series = data[pattern1_series_idx,]
#
# make a dataset
#
dm <- melt(cbind(t(series)))
dm$index <- rep(1:150, 5)
dm$class <- c(rep("0, 78",150), rep("1, 73",150), rep("4, 95",150), 
              rep("6, 75",150), rep("8, 77",150))
#
# make a spagetthi plot
#
p = ggplot(dm, aes(x = index, y = value, group = X2, color=class)) +
  theme_bw() + geom_line() + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 2, top weighted pattern:  \"hhhgdbab\", 0.275") +
  scale_x_continuous("time ticks", limits=c(0,150), breaks=seq(0,150,50)) + 
  scale_y_continuous("Value",limits=c(-2.2,2.2),breaks=seq(-2,2,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2)) + labs(colour = "Series, Start idx") 
p
#
# work on the patterns-subseries plot, extracting subseries
#
sub_series_y = as.numeric(series[1,pattern1_series_pos[1]:(pattern1_series_pos[1]+44)])
sub_series_x = seq(pattern1_series_pos[1],(pattern1_series_pos[1]+44),1)
for(i in 2:5){
  sub_series_y = rbind(sub_series_y,as.numeric(series[i,pattern1_series_pos[i]:(pattern1_series_pos[i]+44)]))
  sub_series_x = rbind(sub_series_x,seq(pattern1_series_pos[i],(pattern1_series_pos[i]+44),1))
}
#
# make a plotting dataset
#
dt <- data.frame(value=as.numeric(t(sub_series_y)), x=as.numeric(t(sub_series_x)))
dt$class <- c(rep("0, 78",45), rep("1, 73",45), rep("4, 95",45), 
              rep("6, 75",45), rep("8, 77",45))
dt$X2 <- c(rep(0,45), rep(1,45), rep(4,45), 
              rep(6,45), rep(8,45))
#
# plot it
#
p1=p+geom_point(data=dt,aes(x=x,y=value),lwd=2,shape=1)
p1  

#
# get a second class
#
#Class key: 1
#"iigdcbbb", 0.31838713947343245
#0: [82, 83, 84]
#1: [78, 79, 80]
#2: [92, 93, 94]
#3: [80, 81]
#4: [92, 93]
#series = c(0,0,0,1,1,1,2,2,2,3,3,4,4)
#offsets = c(82,83,84,78,79,80,92,93,94,80,81,92,93)
pattern1_series_idx=c(0,1,2,3,4)+1
pattern1_series_pos=c(82,78,92,80,92)+1
patterns_num = length(pattern1_series_pos)
#
# extract series of interest
#
data=matrix(as.numeric(unlist(ones)),ncol=series_len,byrow=F)
series = data[pattern1_series_idx,]
#
# make a dataset
#
dm <- melt(cbind(t(series)))
dm$index <- rep(1:150, 5)
dm$class <- c(rep("0, 82",150), rep("1, 78",150), rep("2, 92",150), 
              rep("3, 80",150), rep("4, 92",150))
#
# make a spagetthi plot
#
pp = ggplot(dm, aes(x = index, y = value, group = X2, color=class)) +
  theme_bw() + geom_line() + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 1, top weighted pattern: \"iigdcbbb\", 0.318") +
  scale_x_continuous("time ticks", limits=c(0,150), breaks=seq(0,150,50)) + 
  scale_y_continuous("Value",limits=c(-2.2,2.2),breaks=seq(-2,2,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2)) + labs(colour = "Series, Start idx") 
pp
#
# work on the patterns-subseries plot, extracting subseries
#
sub_series_y = as.numeric(series[1,pattern1_series_pos[1]:(pattern1_series_pos[1]+44)])
sub_series_x = seq(pattern1_series_pos[1],(pattern1_series_pos[1]+44),1)
for(i in 2:5){
  sub_series_y = rbind(sub_series_y,as.numeric(series[i,pattern1_series_pos[i]:(pattern1_series_pos[i]+44)]))
  sub_series_x = rbind(sub_series_x,seq(pattern1_series_pos[i],(pattern1_series_pos[i]+44),1))
}
#
# make a plotting dataset
#
dt <- data.frame(value=as.numeric(t(sub_series_y)), x=as.numeric(t(sub_series_x)))
dt$class <- c(rep("0, 82",45), rep("1, 78",45), rep("2, 92",45), 
              rep("3, 80",45), rep("4, 92",45))
dt$X2 <- c(rep(0,45), rep(1,45), rep(4,45), 
           rep(6,45), rep(8,45))
#
# plot it
#
p2=pp+geom_point(data=dt,aes(x=x,y=value),lwd=2,shape=2)
p2  

print(arrangeGrob(p2, p1, ncol=1))

#
# print into file
#
Cairo(width = 700, height = 700, file="gun/patterns.png", type="png", pointsize=12, 
      bg = "white", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(p2, p1, ncol=1))
dev.off()

#
# the patterns plot
# 
a = c(-1.22, -0.76, -0.43, -0.14,  0.14,  0.43,  0.76,  1.22)
sl = 44/8
#
letters=data.frame(
  id=c(rep("i",4),rep("h",4),rep("g",4),rep("f",4),rep("e",4),
       rep("d",4),rep("c",4),rep("b",4),rep("a",4)),
  x=c(rep(c(-2,-2,44,44),9)),
  y=c(c(a[8],2,2,a[8]), c(a[7],a[8],a[8],a[7]), c(a[6],a[7],a[7],a[6]), c(a[5],a[6],a[6],a[5]),
      c(a[4],a[5],a[5],a[4]),  c(a[3],a[4],a[4],a[3]), c(a[2],a[3],a[3],a[2]), 
      c(a[1],a[2],a[2],a[1]),c(-2,a[1],a[1],-2))
)
bg <- ggplot(letters, aes(x=x, y=y)) + theme_bw() + 
  geom_polygon(aes(fill=id, group=id),alpha=0.5) +
  ggtitle("Class1, pattern \"iigdcbbb\", in SAX terms") +
  scale_y_continuous("Alphabet cuts", limits=c(-2,2), breaks=a) + 
  scale_x_continuous("PAA cuts",limits=c(-2,44),breaks=seq(0,44,sl))+
  theme(plot.title=element_text(size = 18, vjust = 2)) +
#  opts(legend.position = "none") 
  labs(fill="Alphabet")+guides(fill=guide_legend(reverse = TRUE))
bg

#
# class 1
#
pos=data.frame(
lid=c(rep("i1",4),rep("i2",4),rep("g3",4),rep("d4",4),rep("c5",4),
     rep("b6",4),rep("b7",4),rep("b8",4)),
str=c(rep("i",4),rep("i",4),rep("g",4),rep("d",4),rep("c",4),
     rep("b",4),rep("b",4),rep("b",4)),
lx=c(c(1,1,sl,sl), c(1,1,2,2)*sl, c(2,2,3,3)*sl, c(3,3,4,4)*sl, c(4,4,5,5)*sl,
    c(5,5,6,6)*sl, c(6,6,7,7)*sl, c(7,7,8,8)*sl),
ly=c(c(a[8],2,2,a[8]), c(a[8],2,2,a[8]), c(a[6],a[7],a[7],a[6]), c(a[3],a[4],a[4],a[3]),
    c(a[2],a[3],a[3],a[2]),  c(a[2],a[1],a[1],a[2]), c(a[2],a[1],a[1],a[2]), 
    c(a[2],a[1],a[1],a[2]))
)
p3 = bg + geom_polygon(data=pos, aes(x=lx, y=ly, fill=str, group=lid))
p3
line=data.frame(
  lx=seq(sl/2,44-sl/2,sl),
  ly=c(a[8]+(2-a[8])/2, a[8]+(2-a[8])/2, a[6]+(a[7]-a[6])/2, a[3]+(a[4]-a[3])/2, 
       a[2]+(a[3]-a[2])/2, a[1]+(a[2]-a[1])/2, a[1]+(a[2]-a[1])/2, a[1]+(a[2]-a[1])/2))
p3=p3+geom_point(data=line,aes(x=lx,y=ly),lwd=3,shape=2)+
  geom_line(data=line,aes(x=lx,y=ly))
p3

#
# class 1
#
index2 = c(8,8,8,7,4,2,1,2)

bg2 <- ggplot(letters, aes(x=x, y=y)) + theme_bw() + 
  geom_polygon(aes(fill=id, group=id),alpha=0.5) +
  ggtitle("Class 2, pattern \"hhhgdbab\", in SAX terms") +
  scale_y_continuous("Alphabet cuts", limits=c(-2,2), breaks=a) + 
  scale_x_continuous("PAA cuts",limits=c(-2,44),breaks=seq(0,44,sl))+
  theme(plot.title=element_text(size = 18, vjust = 2)) +
  labs(fill="Alphabet")+guides(fill=guide_legend(reverse = TRUE))
bg2

pos=data.frame(
  lid=c(rep("h1",4),rep("h2",4),rep("h3",4),rep("g4",4),rep("d5",4),
       rep("b6",4),rep("a7",4),rep("b8",4)),
  str=c(rep("h",4),rep("h",4),rep("h",4),rep("g",4),rep("d",4),
            rep("b",4),rep("a",4),rep("b",4)),
  lx=c(c(0,0,sl,sl), c(1,1,2,2)*sl, c(2,2,3,3)*sl, c(3,3,4,4)*sl, c(4,4,5,5)*sl,
      c(5,5,6,6)*sl, c(6,6,7,7)*sl, c(7,7,8,8)*sl),
  ly=c(c(a[7],a[8],a[8],a[7]), c(a[7],a[8],a[8],a[7]), c(a[7],a[8],a[8],a[7]),
      c(a[6],a[7],a[7],a[6]), c(a[3],a[4],a[4],a[3]),
      c(a[2],a[1],a[1],a[2]), c(-2,a[1],a[1],-2), c(a[2],a[1],a[1],a[2]))
)

p4 = bg2 + geom_polygon(data=pos, aes(x=lx, y=ly, fill=str, group=lid))
p4

line=data.frame(
  lx=seq(sl/2,44-sl/2,sl),
  ly=c(a[7]+(a[8]-a[7])/2, a[7]+(a[8]-a[7])/2, a[7]+(a[8]-a[7])/2, a[6]+(a[6]-a[5])/2, 
       a[3]+(a[4]-a[3])/2, a[1]+(a[2]-a[1])/2, a[1]+(-2-a[1])/2, a[1]+(a[2]-a[1])/2))
p4=p4+geom_point(data=line,aes(x=lx,y=ly),lwd=3,shape=1)+
  geom_line(data=line,aes(x=lx,y=ly))
p4

#
# print into file
#
Cairo(width = 750, height = 400, file="gun/sax_patterns.png", type="png", pointsize=12, 
      bg = "white", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(p3, p4, ncol=2))
dev.off()
require(Cairo)
require(ggplot2)
require(gridExtra)

data_paa<-read.csv("../../sandbox/TEK17_paa120.csv",header=F,sep = ",",quote = "\"")
data_raw<-read.csv("../../data/ts_data/TEK17.txt",header=F,sep = ",",quote = "\"")

data = data.frame(x=seq(0,4999,1), y=data_raw[,1])
data2 = data.frame(x=seq(0,4999,41.66667), y=data_paa[,2])

p = ggplot() + theme_bw() +
  geom_line(data=data, aes(x=x, y=y), size=0.8, alpha=0.8, col="blue") +
  geom_point(mapping=aes(x=data2$x,y=data2$y), size=2, col="red") +
  geom_point(mapping=aes(x=data2$x[2:120],y=data2$y[1:119]), size=2, col="red") +
  geom_segment(mapping=aes(x=data2$x[1:119], y=data2$y[1:119], xend=data2$x[2:120], yend=data2$y[1:119]), size=0.8, col="red") +
  geom_segment(mapping=aes(x=data2$x[2:120], y=data2$y[1:119], xend=data2$x[2:120], yend=data2$y[2:120]), size=0.8, col="red")
p
require(Cairo)
require(ggplot2)
require(gridExtra)

data_raw<-read.csv("../../data/ts_data/TEK14.txt",header=F,sep = ",",quote = "\"")

data = data.frame(x=seq(0,4999,1), y=data_raw[,1])

discords <- rbind(c(1082,1452,314,55,1267,423),
c(13.776443663006795,11.79477850576262,7.675623753155176,3.1799371062962867,
  2.2119674500317568,1.8044389709823934))

p = ggplot() + theme_bw() +
  geom_line(data=data, aes(x=x, y=y), size=0.8, alpha=0.8, col="blue") +
  scale_x_continuous(name="time") +
  scale_y_continuous(name="values") +
  opts(title = "TEK14 dataset", 
       plot.title = theme_text(size=18, vjust = 2.2), 
       axis.text.x=theme_text(size=10, colour = "grey50"),
       axis.text.y=theme_text(size=10, colour = "grey50"), 
       axis.title.y=theme_text(size=14, angle=90, hjust = 0.5, vjust = 0.3),
       plot.margin = unit(c(0.5, 0.5, 0.5, 0.5), "cm"))
p

jet.colors <-
  colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan",
                     "#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))
colors <- heat.colors(6)

p = ggplot() + theme_bw() +
  geom_line(data=data, aes(x=x, y=y), size=0.8, alpha=0.8, col="blue") +
  scale_x_continuous(name="time") +
  scale_y_continuous(name="values") +
  opts(title = "TEK14 dataset and 6 top discords", 
       plot.title = theme_text(size=18, vjust = 2.2), 
       axis.text.x=theme_text(size=10, colour = "grey50"),
       axis.text.y=theme_text(size=10, colour = "grey50"), 
       axis.title.y=theme_text(size=14, angle=90, hjust = 0.5, vjust = 0.3),
       plot.margin = unit(c(0.5, 0.5, 0.5, 0.5), "cm"))
p

x = seq(discords[1,1],discords[1,1]+127,1)
d = data.frame(x = x, y = as.matrix(data)[x,][,2])
p = p + geom_line(mapping=aes(x=d$x,y=d$y), size=3, col=colors[1])
p

x1 = seq(discords[1,2],discords[1,2]+127,1)
d1 = data.frame(x = x1, y = as.matrix(data)[x1,][,2])
p = p + geom_line(mapping=aes(x=d1$x,y=d1$y), size=2, col=colors[2])
p

x2 = seq(discords[1,3],discords[1,3]+127,1)
d2 = data.frame(x = x2, y = as.matrix(data)[x2,][,2])
p = p + geom_line(mapping=aes(x=d2$x,y=d2$y), size=2, col=colors[3])
p

x3 = seq(discords[1,4],discords[1,4]+127,1)
d3 = data.frame(x = x3, y = as.matrix(data)[x3,][,2])
p = p + geom_line(mapping=aes(x=d3$x,y=d3$y), size=2, col=colors[4])
p

x4 = seq(discords[1,5],discords[1,5]+127,1)
d4 = data.frame(x = x4, y = as.matrix(data)[x4,][,2])
p = p + geom_line(mapping=aes(x=d4$x,y=d4$y), size=2, col=colors[5])
p

x5 = seq(discords[1,6],discords[1,6]+127,1)
d5 = data.frame(x = x5, y = as.matrix(data)[x5,][,2])
p = p + geom_line(mapping=aes(x=d5$x,y=d5$y), size=2, col=colors[5])
p

data_d <- data.frame(x = seq(1,6,1), y = discords[2,])
p = ggplot() + theme_bw() +
  geom_line(data=data_d, aes(x=x, y=y), size=0.8, alpha=0.8, col="blue") +
  scale_x_continuous(name="discord #") +
  scale_y_continuous(name="distance to NN") +
  opts(title = "TEK14 discords nearest neighbor distance breakdown", 
       plot.title = theme_text(size=18, vjust = 2.2), 
       axis.text.x=theme_text(size=10, colour = "grey50"),
       axis.text.y=theme_text(size=10, colour = "grey50"), 
       axis.title.y=theme_text(size=14, angle=90, hjust = 0.5, vjust = 0.3),
       plot.margin = unit(c(0.5, 0.5, 0.5, 0.5), "cm"))
p

p+ geom_points(data)
require(Cairo)
require(ggplot2)
require(gridExtra)
source("../SAX/PAA_SAX.R")

data<-read.table("../../data/ts_data/qtdbsele0606.txt");
y<-data[4779:7779,2]
x<-seq(0,length(y)-1,1)
d<-data.frame(x=x,y=y)

p <- ggplot() + theme_bw() +
  geom_line(data=d, aes(x, y), size=0.8, alpha=0.8)
(p)

znorm <- function(ts){
  ts.mean <- mean(ts[1,])
  ts.dev <- sd(ts[1,])
  (ts - ts.mean)/ts.dev
}

d$y <- t(znorm(t(d$y)))
p=2019
dt=150
d2<-data.frame(x=d$x[p:(p+dt)], y=d$y[p:(p+dt)])
p <- ggplot() + theme_bw() +
  geom_line(data=d, aes(x, y), size=0.8, alpha=0.8, col="gray2") +
  scale_x_continuous(name="Data points") +
  scale_y_continuous(name="Normalized values") +
  opts(title = "Normalized hearbeat series", 
       plot.title = theme_text(size=18, vjust = 2.2), 
       axis.title.x = theme_blank(),
       axis.text.y=theme_text(size=10, colour = "grey50"), 
       axis.title.y=theme_text(size=14, angle=90, hjust = 0.5, vjust = 0.3),
       plot.margin = unit(c(0.5, 0.5, 0.2, 0.5), "cm"))
(p)


p <- ggplot() + theme_bw() +
  geom_line(data=d, aes(x, y), size=0.8, alpha=0.8, col="gray2") +
  scale_x_continuous(name="Data points") +
  scale_y_continuous(name="Normalized values") +
  opts(title = "Normalized hearbeat series and first motif occurrences", 
       plot.title = theme_text(size=18, vjust = 2.2), 
       axis.title.x = theme_blank(),
       axis.text.y=theme_text(size=10, colour = "grey50"), 
       axis.title.y=theme_text(size=16, angle=90, hjust = 0.5, vjust = 0.3),
       plot.margin = unit(c(0.5, 0.5, 0.2, 0.5), "cm"))
(p)

mo<-c(106, 107, 108, 109, 110, 257, 258, 259, 260, 405, 406, 407, 408, 409, 410, 555, 556, 557, 558, 705, 706, 853, 854, 855, 856, 857, 1000, 1001, 1002, 1003, 1146, 1147, 1148, 1149, 1150, 1289, 1290, 1291, 1292, 1293, 1294, 1295, 1430, 1431, 1432, 1433, 1434, 1435, 1436, 1437, 1438, 2713, 2714, 2715, 2716)
for(i in 1:length(mo)){
  mp=mo[i]
  d3<-data.frame(x=d$x[mp:(mp+150)], y=d$y[mp:(mp+150)])
  p<- p + geom_line(data=d3, aes(x, y), size=0.9, alpha=0.8, col="cadetblue")
}
(p)


p <- p + geom_line(data=d2, aes(x, y), size=1.0, alpha=0.8, col="red")
p

p <- ggplot() + theme_bw() +
  geom_line(data=d, aes(x, y), size=0.8, alpha=0.8, col="gray2") +
  geom_line(data=d2, aes(x, y), size=1.0, alpha=0.8, col="red") +
  scale_x_continuous(name="Data points") +
  scale_y_continuous(name="Normalized values") +
  opts(title = "Normalized hearbeat series, first motif and discord", 
       plot.title = theme_text(size=18, vjust = 2.2), 
       axis.title.x = theme_blank(),
       axis.text.y=theme_text(size=10, colour = "grey50"), 
       axis.title.y=theme_text(size=16, angle=90, hjust = 0.5, vjust = 0.3),
       plot.margin = unit(c(0.5, 0.5, 0.2, 0.5), "cm"))
(p)

for(i in 1:length(mo)){
  mp=mo[i]
  d3<-data.frame(x=d$x[mp:(mp+150)], y=d$y[mp:(mp+150)])
  p<- p + geom_line(data=d3, aes(x, y), size=0.9, alpha=0.8, col="cadetblue")
}
(p)

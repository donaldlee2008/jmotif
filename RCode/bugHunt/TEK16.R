require(Cairo)
require(ggplot2)
require(gridExtra)

# constant, window size
ws=128
jet.colors <- colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan",
                                 "#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))


data_raw<-read.csv("../../data/ts_data/TEK16.txt",header=F,sep = ",",quote = "\"")

data_raw = data.frame(x=seq(0,4999,1), y=data_raw[,1])

p = ggplot() + theme_bw() +
  geom_line(data=data, aes(x=x, y=y), size=0.8, alpha=0.8, col="blue") +
  scale_x_continuous(name="time") +
  scale_y_continuous(name="values") +
  opts(title = "TEK16 dataset", 
       plot.title = theme_text(size=18, vjust = 2.2), 
       axis.text.x=theme_text(size=10, colour = "grey50"),
       axis.text.y=theme_text(size=10, colour = "grey50"), 
       axis.title.y=theme_text(size=14, angle=90, hjust = 0.5, vjust = 0.3),
       plot.margin = unit(c(0.5, 0.5, 0.5, 0.5), "cm"))
p

discords=t(rev(c(442,83,279,1244,4287)))
words=t(rev(c("cbbec","acbde","dddba","ebaeb","aceea")))
distances=t(rev(c(3.5652,4.2165,7.7306,14.0023,18.4439)))

discords_segments=data.frame(x=rep(0,(dim(discords)[2])*ws),y=rep(0,(dim(discords)[2])*ws),
                             col=rep(0,(dim(discords)[2])*ws))
colors <- jet.colors(dim(discords)[2])


labels=rep("",dim(discords)[2])
for(i in 1:(dim(discords)[2])){
  labels[i]=paste(words[i],",",distances[i])
}  

for(i in 1:(dim(discords)[2])){
  offset = discords[i]
  xi = (i-1)*ws
  for(j in 1:ws){
    discords_segments[xi+j,]=c(data_raw[offset+j,1],data_raw[offset+j,2],colors[i])
  }
}

p + geom_line(mapping=aes(as.numeric(discords_segments$x),as.numeric(discords_segments$y),
                          col=discords_segments$col), size=1.8, alpha=1.0) + 
                            scale_colour_hue('Top discords',labels=labels)

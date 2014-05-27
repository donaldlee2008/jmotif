#
# this generated series tinker example
# Author: Pavel Senin, seninp@gmail.com
#
require(Cairo)
require(ggplot2)
require(gridExtra)

# constant, window size
ws=128

# constant, alphabet size
as=5

# constant, raw series length in ticks
dsize=5000

data_raw<-read.csv("../../sandbox/generated_series_raw.csv",header=F,sep = ",",quote = "\"")
data = data.frame(x=data_raw[,1], y=data_raw[,2])

data_paa<-read.csv("../../sandbox/generated_series_paa.csv",header=F,sep = ",",quote = "\"")
#data2 = data.frame(x=seq(ws/as/2,dsize-ws/as/2,ws/as), y=data_paa[,2])
data2 = data.frame(x=data_paa[,1], y=data_paa[,2])

dm = dim(data2)[1]
inc=ws/as/2
p = ggplot() + theme_bw() +
  geom_line(data=data, aes(x=x, y=y), size=0.6, alpha=1.0, col="blue") +
  geom_point(mapping=aes(x=data2$x,y=data2$y), size=0.8, col="red", alpha=0.5) +
  geom_segment(mapping=aes(x=(data2$x-inc), y=data2$y, xend=(data2$x+inc),
                           yend=data2$y), size=0.8, col="red", alpha=0.5) +  
  geom_segment(mapping=aes(x=(data2$x[1:(dm-1)]+inc), y=data2$y[1:(dm-1)], xend=(data2$x[2:dm]-inc),
                           yend=data2$y[2:dm]), size=0.5, col="red", alpha=0.5) +                             
  scale_x_continuous(name="time") +
  scale_y_continuous(name="values") +
  opts(title = paste("Generated test dataset and its PAA approximation\nwindow_size=",ws,", alphabet_size=",as),
       plot.title = theme_text(size=18, vjust = 2.2), 
       axis.text.x=theme_text(size=10, colour = "grey50"),
       axis.text.y=theme_text(size=10, colour = "grey50"), 
       axis.title.y=theme_text(size=14, angle=90, hjust = 0.5, vjust = 0.3),
       plot.margin = unit(c(0.5, 0.5, 0.5, 0.5), "cm"))
p

discords_segments=data.frame(x=rep(0,(dim(discords)[2])*ws),y=rep(0,(dim(discords)[2])*ws),
                             col=rep(0,(dim(discords)[2])*ws))
jet.colors <- colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan",
                                 "#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))
#colors <- heat.colors(dim(discords)[2])
colors <- jet.colors(dim(discords)[2])

## discords section
#
#
discords=t(rev(c(3434,3291,1202,1472,2491)))
words=t(rev(c("aadc","ccda","cbad","dabd","baad")))
distances=t(rev(c(13.2382,19.1836,19.6632,20.0723,20.6817)))

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


p = ggplot() + theme_bw() +
  geom_line(data=data, aes(x=x, y=y), size=0.6, alpha=1.0, col="blue") +
                                                          scale_x_continuous(name="time") +
                                                        scale_y_continuous(name="values") +
                                                        opts(title = "Generated test dataset",
                                                             plot.title = theme_text(size=18, vjust = 2.2), 
                                                             axis.text.x=theme_text(size=10, colour = "grey50"),
                                                             axis.text.y=theme_text(size=10, colour = "grey50"), 
                                                             axis.title.y=theme_text(size=14, angle=90, hjust = 0.5, vjust = 0.3),
                                                             plot.margin = unit(c(0.5, 0.5, 0.5, 0.5), "cm"))
p
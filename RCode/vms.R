require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
require(gridExtra)
require(lubridate)


discords_index=c(277,720,671,196,341,90)
segment_length=20

dat = read.table("/media/DB/vms/vms_distance_PY-91090.txt", skip=1,header=F)
series=dat[,4]
df=data.frame(index=c(1:length(series)), value=series)

p <- ggplot(df, aes(x=index,y=series)) + geom_line() + ggtitle("RAW data") +
  theme(plot.title=element_text(size=18),
        axis.title.x=element_text(size=16), axis.text.x=element_text(size=12), 
        axis.title.y=element_text(size=18), axis.text.y=element_text(size=14),
        legend.position = "bottom")
p

discords=c(rep(NA,(discords_index[1]-1)),
           series[discords_index[1]:(discords_index[1]+segment_length)],
           rep(NA,length(series)-(discords_index[1]+segment_length)))

for(i in 2:(length(discords_index))){
  d=c(rep(NA,(discords_index[i]-1)),
      series[discords_index[i]:(discords_index[i]+segment_length)],
      rep(NA,length(series)-(discords_index[i]+segment_length)))
  discords=rbind(discords,d)
}

discords=as.data.frame(t(discords))
names(discords)<-c(paste(discords_index))
dm=melt(discords)
dm=cbind(dm,
         rep(c(1:length(series)),length(discords_index)))
names(dm)=c("discord","value","index")

p1 = ggplot(dm, aes(x = index, y = value, col=discord)) + theme_bw() +
  geom_line(lwd=1.3) + scale_colour_brewer(palette="Set1") +
  theme(plot.title=element_text(size=18),
        axis.title.x=element_text(size=16), axis.text.x=element_text(size=12), 
        axis.title.y=element_text(size=18), axis.text.y=element_text(size=14),
        legend.position = "bottom")
p1
print(arrangeGrob(p, p1, ncol=1, heights=c(1,1.3),clip=F))

#
#
#
#
#discords=rbind(series,discords)

#discords=as.data.frame(t(discords))
#names(discords)<-c("series",paste(discords_index))
#dm=melt(discords)
#dm=cbind(dm,
#rep(c(1:length(series)),length(discords_index)+1))
#names(dm)=c("discord","value","index")

#p1 = ggplot(dm, aes(x = index, y = value, col=discord)) + theme_bw() +
# geom_line(lwd=1.3) + scale_colour_brewer(palette="Set1") +
#theme(plot.title=element_text(size=18),
#       axis.title.x=element_text(size=16), axis.text.x=element_text(size=12), 
#axis.title.y=element_text(size=18), axis.text.y=element_text(size=14),
#legend.position = "bottom")
#p1

#print(arrangeGrob(p, p1, ncol=1, heights=c(1,1.3),clip=F))


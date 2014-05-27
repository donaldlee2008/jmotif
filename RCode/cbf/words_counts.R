require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require("lattice")

dat = read.csv("cbf/cbf_words-nored.csv",header=F,skip=1)
names(dat)=c("train_size","Total","Cylinder","Bell","Funnel")
index=sort(unique(dat$train_size))
total=rep(-1,length(index))
cylinder=rep(-1,length(index))
bell=rep(-1,length(index))
funnel=rep(-1,length(index))
for(i in 1:(length(index))){
  total[i]=mean(dat[dat$train_size==index[i],2])
  cylinder[i]=mean(dat[dat$train_size==index[i],3])
  bell[i]=mean(dat[dat$train_size==index[i],4])
  funnel[i]=mean(dat[dat$train_size==index[i],5])
}
#
#
#
d=data.frame(index,total,cylinder,bell,funnel)
dm=melt(d,id.var="index")
p1 <- ggplot(dm, aes(index, value, color=variable)) + geom_line(lwd=1) +
  geom_point() + theme_bw() +
  scale_x_continuous("TRAIN dataset size") + 
  scale_y_log10("terms",breaks=c(1000,5000,10000,15000),labels=c()) +
  ggtitle("Terms count in corpus and classes") +
  scale_colour_discrete(name = element_blank(), labels=c("All terms", "Cylinder", "Bell", "Funnel"),
    guide = guide_legend(title.theme=element_text(size=16, angle=0),
    keywidth = 2, keyheight = 1, label.theme=element_text(size=13, angle=0))) +
  theme(plot.title=element_text(size=18),
    axis.title.x=element_text(size=16), axis.text.x=element_text(size=12), 
    axis.title.y=element_text(size=18), axis.text.y=element_text(size=14),
    legend.position = "bottom")
p1
#
#
#
#
noreduction = t((cylinder+bell+funnel))
noreduction = apply(noreduction, 2, mean)

dat = read.csv("cbf/cbf_words-exact.csv",header=F,skip=1)
names(dat)=c("train_size","Total","Cylinder","Bell","Funnel")
index=sort(unique(dat$train_size))
total=rep(-1,length(index))
cylinder=rep(-1,length(index))
bell=rep(-1,length(index))
funnel=rep(-1,length(index))
for(i in 1:(length(index))){
  total[i]=mean(dat[dat$train_size==index[i],2])
  cylinder[i]=mean(dat[dat$train_size==index[i],3])
  bell[i]=mean(dat[dat$train_size==index[i],4])
  funnel[i]=mean(dat[dat$train_size==index[i],5])
}
exact = t((cylinder+bell+funnel))
exact = apply(exact, 2, mean)


dat = read.csv("cbf/cbf_words-classic.csv",header=F,skip=1)
names(dat)=c("train_size","Total","Cylinder","Bell","Funnel")
index=sort(unique(dat$train_size))
total=rep(-1,length(index))
cylinder=rep(-1,length(index))
bell=rep(-1,length(index))
funnel=rep(-1,length(index))
for(i in 1:(length(index))){
  total[i]=mean(dat[dat$train_size==index[i],2])
  cylinder[i]=mean(dat[dat$train_size==index[i],3])
  bell[i]=mean(dat[dat$train_size==index[i],4])
  funnel[i]=mean(dat[dat$train_size==index[i],5])
}
classic = t((cylinder+bell+funnel))
classic = apply(classic, 2, mean)

d=data.frame(index,noreduction,classic,exact)
dm=melt(d,id.var="index")
p1 <- ggplot(dm, aes(index, value, color=variable)) + geom_line(lwd=1) +
  geom_point() + theme_bw() +
  scale_x_continuous("TRAIN dataset size") + 
  scale_y_continuous("Distinct terms") +
  ggtitle("Average term counts in CBF classes by strategy") +
  scale_colour_discrete(name = element_blank(), labels=c("Noreduction", "Classic", "Exact"),
     guide = guide_legend(title.theme=element_text(size=16, angle=0),
     keywidth = 2, keyheight = 1, label.theme=element_text(size=13, angle=0))) +
  theme(plot.title=element_text(size=18),
        axis.title.x=element_text(size=16), axis.text.x=element_text(size=12), 
        axis.title.y=element_text(size=18), axis.text.y=element_text(size=14),
        legend.position = "bottom")

p1

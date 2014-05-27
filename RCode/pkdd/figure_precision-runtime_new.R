require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require("lattice")
#
# define custom colors
#
gg_color_hue <- function(n) {
  hues = seq(15, 375, length=n+1)
  hcl(h=hues, l=65, c=100)[1:n]
}
cols = gg_color_hue(5)
#
# read precision run data
#
dat = read.csv("pkdd/time-error/performance6077_nored.csv",header=F,skip=1)
names(dat)=c("train","jmotif_error","euclidean_error","jmotif_time","euclidean_time")
#
# data massaging
#
index=sort(unique(dat$train))
jmotif_error=rep(-1,length(index))
for(i in 1:(length(index))){
  jmotif_error[i]=mean(dat[dat$train==index[i],2])
}
jmotif_runtime=rep(-1,length(index))
for(i in 1:(length(index))){
  jmotif_runtime[i]=mean(dat[dat$train==index[i],4])
}
euclidean_error=rep(-1,length(index))
for(i in 1:(length(index))){
  euclidean_error[i]=mean(dat[dat$train==index[i],3])
}
euclidean_runtime=rep(-1,length(index))
for(i in 1:(length(index))){
  euclidean_runtime[i]=mean(dat[dat$train==index[i],5])
}
#
# plot of precision comparison
#
d=data.frame(index,euclidean_error,jmotif_error)
dm=melt(d,id.var="index")
dm=cbind(dm, col=c(rep("#00BA38",7),rep("#F8766D",7)))
p1 <- ggplot(dm, aes(index, value, colour=variable,shape=variable)) + geom_line(lwd=1.1) +
  geom_point(size=4)+ theme_bw() + 
  ggtitle("Classification error") +
  scale_x_continuous("TRAIN dataset size") + 
  scale_y_log10("Error, %",limits=c(0.0002,0.1),breaks=c(0.001, 0.010, 0.1),labels=c("0.1","1.0","10")) +
  scale_colour_discrete(name = element_blank(), label=c("1NN Euclidean","SAX-VSM"),
     guide = guide_legend(title.theme=element_text(size=16, angle=0),
     keywidth = 1, keyheight = 1, label.theme=element_text(size=16, angle=0))) +
  theme(plot.title=element_text(size=18),
        axis.title.x=element_text(size=14), axis.text.x=element_text(size=10), 
        axis.title.y=element_text(size=14), axis.text.y=element_text(size=10),
        legend.position = "bottom") 
p1

p1=p1 + scale_color_manual(values=c("#619CFF","indianred2"), name = element_blank(), 
                           label=c("1NN Euclidean","SAX-VSM"),
            guide = guide_legend(title.theme=element_text(size=0, angle=0),
                 keywidth = 1.5, keyheight = 1, label.theme=element_text(size=13, angle=0)))  +
  scale_shape(guide = 'none')
p1

#
# runtime plot
#
dat = read.csv("pkdd/time-error/cbf_noised_20Dperformance6077_nored.csv",header=F,skip=1)
names(dat)=c("train","jmotif_error","euclidean_error","jmotif_train","jmotif_classifier","euclidean_time")
index=sort(unique(dat$train))
jmotif_error=rep(-1,length(index))
for(i in 1:(length(index))){
  jmotif_error[i]=mean(dat[dat$train==index[i],2])
}
jmotif_train=rep(-1,length(index))
for(i in 1:(length(index))){
  jmotif_train[i]=mean(dat[dat$train==index[i],4])
}
jmotif_classifier=rep(-1,length(index))
for(i in 1:(length(index))){
  jmotif_classifier[i]=mean(dat[dat$train==index[i],5])
}
euclidean_error=rep(-1,length(index))
for(i in 1:(length(index))){
  euclidean_error[i]=mean(dat[dat$train==index[i],3])
}
euclidean_runtime=rep(-1,length(index))
for(i in 1:(length(index))){
  euclidean_runtime[i]=mean(dat[dat$train==index[i],6])
}

d=data.frame(index,euclidean_runtime,jmotif_classifier,jmotif_train)
dm=melt(d,id.var="index")
p2 <- ggplot(dm, aes(index, value, colour=variable, shape=variable)) + geom_line(lwd=1.1) +
  geom_point(size=4)+ theme_bw() +
  ggtitle("Classification runtime")+
  scale_x_continuous("TRAIN dataset size") + 
  scale_y_log10("Time, sec.", breaks=c(1000, 10000, 100000), labels=c("1","10","100"))+
  scale_colour_discrete(name = element_blank(), label=c("1NN Euclidian","SAX-VSM Classifier","SAX-VSM Train"),
      guide = guide_legend(title.theme=element_text(size=16, angle=0),
      keywidth = 0.8, keyheight = 1, label.theme=element_text(size=15, angle=0))) +
  theme(plot.title=element_text(size=18),
        axis.title.x=element_text(size=14), axis.text.x=element_text(size=10), 
        axis.title.y=element_text(size=14), axis.text.y=element_text(size=10),
        legend.position = "bottom",
        panel.margin = unit(0, "lines"))
p2
p2=p2 + scale_color_manual(values=c("#619CFF", "indianred2", "tomato4"), name = element_blank(), 
                           label=c("1NN Euclidian","SAX-VSM","SAX-VSM with Train"),
                     guide = guide_legend(title.theme=element_text(size=0, angle=0),
          keywidth = 1.5, keyheight = 1, label.theme=element_text(size=13, angle=0)))  +
  scale_shape(guide = 'none')

g <- ggplot_build(p2)
unique(g$data[[1]]["colour"])
#
# plot both together
#

#
# Noised plot
#
dat_noised = read.csv("pkdd/corrupted/noised.csv",header=F,skip=0)
dat_noised = data.frame(noise=dat_noised[,1], euclidean_err=dat_noised[,2], 
                        sax_vsm_opt=dat_noised[,4], SAX_vsm=dat_noised[,3])
dm=melt(dat_noised,id.var="noise")
p_noise <- ggplot(dm, aes(noise, value, colour=variable, shape=variable)) + geom_line(lwd=1.1) +
  geom_point(size=4)+ theme_bw() + 
  ggtitle("Classification error vs noise") +
  scale_x_continuous("Noise level, %", breaks=seq(0,1,0.1),labels=paste(seq(0,100,10))) + 
  scale_y_continuous("Error, %",limits=c(0.0,0.55), breaks=seq(0,0.5,0.10),labels=paste(seq(0,50,10))) + 
  scale_colour_discrete(name = element_blank(), labels=c("1NN Euclidean", "SAX-VSM Opt", "SAX-VSM"),
      guide = guide_legend(title.theme=element_text(size=16, angle=0),
      keywidth = 1.5, keyheight = 1, label.theme=element_text(size=13, angle=0))) +
  theme(plot.title=element_text(size=18),
        axis.title.x=element_text(size=16), axis.text.x=element_text(size=12), 
        axis.title.y=element_text(size=18), axis.text.y=element_text(size=14),
        legend.position = "bottom")
p_noise
p_noise=p_noise + 
  scale_color_manual(values=c("#619CFF", "indianred2", "tomato4"), name = element_blank(), 
                     labels=c("1NN Eucl.", "SAX-VSM Opt", "SAX-VSM"),
                     guide = guide_legend(title.theme=element_text(size=0, angle=0),
                                          keywidth = 1, keyheight = 1, label.theme=element_text(size=13, angle=0)))  +
  scale_shape(guide = 'none')
p_noise

grid.arrange(arrangeGrob(p1, p2, p_noise, ncol=3, widths=c(1,1,1)))
Cairo(width = 1200, height = 400, 
      file="../precision-runtime_new.pdf", 
      type="pdf", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = 82)
print(arrangeGrob(p1, p2, p_noise, ncol=3, clip=F))
dev.off()

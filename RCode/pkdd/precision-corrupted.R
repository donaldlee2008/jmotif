require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require("lattice")
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
            keywidth = 1, keyheight = 1, label.theme=element_text(size=13, angle=0))) +
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
#p_noise <- ggplot_build(p_noise)

#
# Corrupted plot
#
dat = read.csv("pkdd/corrupted/corrupted1.csv",header=F,skip=0)
names(dat)=c("loss","jmotif_error","euclidean_error")
d=data.frame(dat$loss,dat$euclidean_error,dat$jmotif_error)
names(d)=c("loss","euclidean_error","jmotif_error")
dm=melt(d,id.var="loss")
p_corrupted <- ggplot(dm, aes(loss, value, colour=variable, shape=variable)) + geom_line(lwd=1.1) +
  geom_point(size=4)+ theme_bw() + 
  ggtitle("Classification error vs data loss") +
  scale_x_continuous("Signal loss, %", breaks=seq(0,0.50,0.10),labels=paste(seq(0,50,10))) + 
  scale_y_continuous("Error, %",limits=c(0.0,0.55), breaks=seq(0,0.5,0.10),labels=paste(seq(0,50,10))) + 
  scale_colour_discrete(name = element_blank(), labels=c("1NN Eucl.","SAX-VSM Opt"),
     guide = guide_legend(title.theme=element_text(size=16, angle=0),
     keywidth = 1, keyheight = 1, label.theme=element_text(size=13, angle=0))) +
  theme(plot.title=element_text(size=18),
        axis.title.x=element_text(size=16), axis.text.x=element_text(size=12), 
        axis.title.y=element_text(size=18), axis.text.y=element_text(size=14),
        legend.position = "bottom")
p_corrupted=p_corrupted + 
      scale_color_manual(values=c("#619CFF", "#F8766D"), name = element_blank(), 
      label=c("1NN Euclidean","SAX-VSM Opt"),
      guide = guide_legend(title.theme=element_text(size=0, angle=0),
      keywidth = 1, keyheight = 1, label.theme=element_text(size=13, angle=0)))  +
  scale_shape(guide = 'none')
p_corrupted
#
# plot both together
#
grid.arrange(arrangeGrob(p_noise, p_corrupted, ncol=2))
#
# make an EPS figure for paper
#
Cairo(width = 1000, height = 400, 
      file="/media/Stock/csdl-techreports/techreports/2011/11-09/figures/corrupted", 
      #file="/home/psenin/thesis/csdl-techreports/pkdd/figures/corrupted", 
      type="pdf", pointsize=18, 
      bg = "transparent", canvas = "white", units = "px", dpi = 82)
print(arrangeGrob(p_noise, p_corrupted, ncol=2))
dev.off()

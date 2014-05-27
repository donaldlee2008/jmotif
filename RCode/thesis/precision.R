require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
require(gridExtra)
require(lattice)
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
dat_cbf <- read.csv("../results/performance-cbf.csv",header=T,skip=0)
names(dat_cbf) <- c("size","ed_error","ed_time","dtw_error","dtw_time","svsm_error","svsm_time")
dat_2pat <- read.csv("../results/performance-2pat.csv",header=T,skip=0)
names(dat_2pat) <- c("size","ed_error","ed_time","dtw_error","dtw_time","svsm_error","svsm_time")
#
# plot of precision comparison
#
dm_cbf=melt(data.frame(dat_cbf[1],dat_cbf[2],dat_cbf[4],dat_cbf[6]),id.vars=c("size"))
#dm=cbind(dm, col=c(rep("#00BA38",7),rep("#F8766D",7)))
p1 <- ggplot(dm_cbf, aes(x=size, y=value, colour=variable, shape=variable)) + geom_line(lwd=1.1) +
  geom_point(size=4)+ theme_bw() + 
  ggtitle("CBF classification error") +
  scale_x_continuous("TRAIN dataset size",breaks=c(50, 200,400,800,1600,3200,6400),
                     labels=paste(c(50, 200,400,800,1600,3200,6400))) + 
  scale_y_continuous("Error, %",limits=c(0,0.025)) +
  #,breaks=c(0.001, 0.010, 0.1),labels=c("0.1","1.0","10")) +
  scale_colour_discrete(name = element_blank(), label=c("1NN Euclidean","DTW","SAX-VSM"),
     guide = guide_legend(title.theme=element_text(size=16, angle=0),
     keywidth = 1, keyheight = 1, label.theme=element_text(size=16, angle=0))) +
  theme(plot.title=element_text(size=18),
        axis.title.x=element_text(size=14), axis.text.x=element_text(size=10), 
        axis.title.y=element_text(size=14), axis.text.y=element_text(size=10),
        legend.position = "bottom") 
p1

dm_2pat=melt(data.frame(dat_2pat[1],dat_2pat[2],dat_2pat[4],dat_2pat[6]),id.vars=c("size"))
#dm=cbind(dm, col=c(rep("#00BA38",7),rep("#F8766D",7)))
p2 <- ggplot(dm_2pat, aes(x=size, y=value, colour=variable, shape=variable)) + geom_line(lwd=1.1) +
  geom_point(size=4)+ theme_bw() + 
  ggtitle("Two patterns classification error") +
  scale_x_continuous("TRAIN dataset size",breaks=c(50, 200,400,800,1600,3200,6400),
                     labels=paste(c(50, 200,400,800,1600,3200,6400))) + 
  scale_y_continuous("Error, %",limits=c(0,0.3)) +
  #,breaks=c(0.001, 0.010, 0.1),labels=c("0.1","1.0","10")) +
  scale_colour_discrete(name = element_blank(), label=c("1NN Euclidean","DTW","SAX-VSM"),
      guide = guide_legend(title.theme=element_text(size=16, angle=0),
      keywidth = 1, keyheight = 1, label.theme=element_text(size=16, angle=0))) +
  theme(plot.title=element_text(size=18),
        axis.title.x=element_text(size=14), axis.text.x=element_text(size=10), 
        axis.title.y=element_text(size=14), axis.text.y=element_text(size=10),
        legend.position = "bottom") 
p2

grid.arrange(arrangeGrob(p1, p2, ncol=2, widths=c(1,1,1)))
Cairo(width = 1200, height = 400, 
      file="thesis/precision-synt.ps", 
      type="ps", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = 82)
grid.arrange(arrangeGrob(p1, p2, ncol=2, clip=F))
dev.off()

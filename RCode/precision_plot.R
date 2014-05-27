require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require("lattice")

euclidean=c(0.12,   0.148,  0.087,  0.369,  0.24,
            0.389,  0.170,  0.467,  0.25,   0.133,
            0.12,   0.0650, 0.286,  0.216,  0.217,
            0.213,  0.483,  0.246,  0.425,  0.005,  
            0.09,   0.3182, 0.4086, 0.35,   0.0511, 
            0.4375, 0.3045, 0.3664, 0.44,   0.32,
            0.1395, 0.0235, 0.2607, 0.3384, 0.3504, 
            0.0654, 0.3158, 0.3824, 0.2307, 0.1005, 
            0.0632, 0.0949, 0.9132, 0.171, 0.120)

dtw=      c(0.007,  0.003,  0.093,  0.310,  0.0,
            0.396,  0.164,  0.5,    0.179,   0.133,
            0.23,   0.232,  0.192,  0.170,  0.167,  
            0.210,  0.409,  0.131,  0.274,  0.020,  
            0.0,    0.267, 0.3812, 0.352,   0.0102, 
            0.125,  0.2745, 0.2824, 0.457,  0.32, 
            0.1395, 0.0312, 0.2725, 0.3659, 0.3417,
            0.0327, 0.2631, 0.3511, 0.0951, 0.0503,
            0.093,  0.0495, 0.9132, 0.209,  0.135)

jmotif=c(0.0133, 0.0011, 0.0066, 0.3582, 0.0,
         0.3785, 0.1496, 0.1999, 0.0, 0.0999,
         0.1400, 0.0100, 0.2065, 0.0, 0.171,
         0.2512, 0.0867, 0.1967, 0.3287, 0.0010,
         0.0040, 0.1272, 0.2567, 0.3341, 0.0102,
         0.2343, 0.2628, 0.2824, 0.1790, 0.3028,
         0.0772, 0.0274, 0.2635, 0.3534, 0.3400,
         0.0653, 0.4802, 0.4404, 0.0751, 0.1015,
         0.0807, 0.1166, 0.3227, 0.2340, 0.1450)

sum(euclidean)
sum(dtw)
sum(jmotif)

px=c(euclidean+0.015)
py=c(jmotif+0.015)
px[3]=px[3]-0.025
py[3]=py[3]-0.02
py[4]=py[4]-0.02
px[5]=px[5]-0.015
py[6]=py[6]-0.03
py[7]=py[7]-0.015
py[10]=py[10]-0.035
px[11]=px[11]-0.025
px[13]=px[13]-0.035
py[13]=py[13]-0.01
px[14]=px[14]-0.015
px[19]=px[19]+0.005
py[19]=py[19]-0.01
px[20]=px[20]-0.005
py[20]=py[20]+0.005
px[23]=px[23]-0.025
py[23]=py[23]-0.04

data=data.frame(x=euclidean,y=jmotif,px,py,labels=paste(c(1:length(jmotif))))

p <- ggplot(data, aes(x, y,label=labels)) + geom_point(size=4,col="coral3") + theme_bw() +
  geom_abline(intercept = 0, slope=1) + geom_text(aes(px,py,label=labels)) +
  geom_text(x = 0.17, y = 0.38, label = "Euclidean 1-NN wins",col="cornflowerblue",size = 8,face="bold") +
  geom_text(x = 0.4, y = 0.05, label = "SAX-VSM wins",col="cornflowerblue",size = 8) +
  scale_x_continuous("Euclidean error", limits=c(0,0.6), breaks=seq(0,1,0.1)) + 
  scale_y_continuous("SAX-VSM error", limits=c(0,0.6), breaks=seq(0,1,0.1)) + 
  ggtitle("Euclidean 1-NN and SAX-VSM accuracy comparison") +
  geom_abline(intercept = 0, slope=1) +
  theme(plot.title=element_text(size=18),axis.text.x=element_text(size=15), 
        axis.text.y=element_text(size=15),axis.title.x=element_text(size=18), 
        axis.title.y=element_text(size=18))
p

Cairo(width = 550, height = 550, file="comparison_euclidean.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = 96)
print(p)
dev.off()
#
#
#
px=c(dtw+0.015)
py=c(jmotif+0.015)
py[1]=py[1]-0.025
px[1]=px[1]-0.01
py[2]=py[2]+0.017
px[2]=px[2]-0.018
px[5]=px[5]-0.002
py[5]=py[5]+0.017
py[20]=py[20]+0.04
px[20]=px[20]-0.015
px[12]=px[12]-0.0025
py[7]=py[7]-0.02
py[10]=py[10]-0.02
px[13]=px[13]-0.005
py[13]=py[13]-0.012
px[14]=px[14]-0.03
py[14]=py[14]-0.015
py[22]=py[22]+0.02
px[22]=px[22]-0.02
py[24]=py[24]-0.025
px[24]=px[24]+0.005

data=data.frame(x=dtw,y=jmotif,px,py,labels=paste(c(1:length(jmotif))))

p1 <- ggplot(data, aes(x, y,label=labels)) + geom_point(size=4,col="coral3") + theme_bw() +
  geom_abline(intercept = 0, slope=1) + geom_text(aes(px,py,label=labels)) +
  geom_text(x = 0.17, y = 0.42, label = "DTW 1-NN wins",col="cornflowerblue",size = 8,face="bold") +
  geom_text(x = 0.4, y = 0.05, label = "SAX-VSM wins",col="cornflowerblue",size = 8) +
  scale_x_continuous("DTW error", limits=c(0,0.6), breaks=seq(0,1,0.1)) + 
  scale_y_continuous("SAX-VSM error", limits=c(0,0.6), breaks=seq(0,1,0.1)) + 
  ggtitle("DTW 1-NN and SAX-VSM accuracy comparison") +
  geom_abline(intercept = 0, slope=1) +
  theme(plot.title=element_text(size=18),axis.text.x=element_text(size=15), 
        axis.text.y=element_text(size=15),axis.title.x=element_text(size=18), 
        axis.title.y=element_text(size=18))
p1

Cairo(width = 550, height = 550, file="comparison_dtw.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = 96)
print(p1)
dev.off()

Cairo(width = 1100, height = 500, file="comparison.png", type="png", pointsize=7, 
      bg = "transparent", canvas = "white", units = "px", dpi = 96)
print(arrangeGrob(p, p1, ncol=2))
dev.off()


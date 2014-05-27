require(ggplot2)
require(Cairo)
require(plyr)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
require(gridExtra)

dat=read.table("../data/demo/winding_col2.dat",header=F,sep=" ")
dat=data.frame(x=c(1:(dim(dat)[1])), y=as.numeric(dat[,1]))
data_plot = ggplot(data=dat, aes(x=x,y=y)) + geom_line() +
  ggtitle("Winding dataset, the angular speed of reel 2 (S2)")
data_plot

CairoPNG(filename = "demo/winding_col2.png",
    width = 800, height = 300, units = "px", pointsize = 12)
print(data_plot)
dev.off()

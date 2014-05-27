require(ggplot2)
require(Cairo)
require(plyr)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
require(gridExtra)

dat=read.table("../data/demo/qtdb0606.dat",header=F,sep=",")
dat=data.frame(x=c(1:length(dat$V1)), y=dat$V1)
data_plot = ggplot(data=dat, aes(x=x,y=y)) + geom_line() +
  ggtitle("Excerpt from PHYSIONET qtdb record 0606")
data_plot

CairoPNG(filename = "demo/qtdb0606.png",
    width = 800, height = 300, units = "px", pointsize = 12)
print(data_plot)
dev.off()

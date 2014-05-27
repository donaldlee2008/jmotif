require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require(lattice)
#
# explore the data
#
read_data=function(name){
  res = read.csv(file=name,head=F)
  names(res)=c("strategy","window", "paa","alphabet","acc","Error")
  res
}
dat=read_data("electricalDevices/explorer/ed_explorer001.csv")
dat=rbind(dat, read_data("electricalDevices/explorer/ed_explorer002.csv"))
dat=rbind(dat, read_data("electricalDevices/explorer/ed_explorer003.csv"))
dat=rbind(dat, read_data("electricalDevices/explorer/ed_explorer004.csv"))

dat_nr=dat[dat[,1]=="NOREDUCTION",]
dat_nr17=dat[dat[,2]==17,]

p=wireframe(Error ~ paa * alphabet, data = dat_nr17, scales = list(arrows = FALSE),
            drape = TRUE, colorkey = TRUE, screen = list(z = 210, x = -66, y=20),
            aspect = c(97/77, 0.8),
            xlim=range(dat_nr17$paa), ylim=range(dat_nr17$alphabet), zlim=c(0, 1.0),
            main=paste("Electrical devices error rate, SLIDING_WINDOW=17"),
            col.regions = terrain.colors(100, alpha = 1) )
p

#
# old code
#

require("lattice")

data=read.csv("gun/parameters.csv",head=F)
names(data)=c("paa","Alphabet","WINDOW","acc","Error")
data=data.frame(data)

d=data[data[3]==40,]

p=wireframe(Error ~ paa * Alphabet, data = d, scales = list(arrows = FALSE),
          drape = TRUE, colorkey = TRUE, screen = list(z = 210, x = -66, y=20),
            aspect = c(97/77, 0.8),
            xlim=range(data$paa), ylim=range(data$Alphabet), zlim=c(0, 1.0),
            main=paste("Gun/No Gun Classifier error rate, SLIDING_WINDOW=40"),
            col.regions = terrain.colors(100, alpha = 1) )
p


Cairo(width = 700, height = 750, file="gun/parameters.png", type="png", pointsize=12, 
      bg = "white", canvas = "white", units = "px", dpi = "auto")
print(p)
dev.off()



dat = read.csv("../data/ElectricDevices/ElectricDevices_TRAIN",header=F,sep=",")
unique(dat[,1])

dat %in% dat[,dat[1,]==1]

zeros=(dat[,dat[1,]==0])[-1,2]
ones=(dat[,dat[1,]==1])[-1,1]
twos=(dat[,dat[1,]==2])[-1,1]
threes=(dat[,dat[1,]==3])[-1,1]
fours=(dat[,dat[1,]==4])[-1,1]
fives=(dat[,dat[1,]==5])[-1,1]
sixs=(dat[,dat[1,]==6])[-1,2]

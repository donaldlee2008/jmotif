require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require("lattice")

keep_class=function(dat,class){
  d1 = dat[dat[,1]==class,]
  d2 = dat[dat[,1]!=class,]
  d1[,1] = 1
  d2[,1] = 2
  rbind(d1,d2)
}

train = read.table("../data/Beef/Beef_TRAIN",header=F)
test = read.table("../data/Beef/Beef_TEST",header=F)

dd=keep_class(train,5)
dd2=keep_class(test,5)
write.table(dd,"../data/Beef/Beef_TRAIN5",col.names=F,row.names=F,sep=" ",dec=".")
write.table(dd2,"../data/Beef/Beef_TEST5",col.names=F,row.names=F,sep=" ",dec=".")

write.table(train[train[,1]!=1,],"../data/Beef/Beef_TRAIN-1",col.names=F,row.names=F,sep=" ",dec=".")
write.table(test[test[,1]!=1,],"../data/Beef/Beef_TEST-1",col.names=F,row.names=F,sep=" ",dec=".")

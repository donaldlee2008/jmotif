require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require(lattice)

dat = read.csv("../adiac_tfidf.csv",header=T)
dm=melt(dat,id.var="X")
ggplot(dm,aes(x = X)) + 
  facet_wrap(~variable,scales = "free_x") + 
  geom_histogram()

ggplot(dm,aes(x=X,y=value,group=variable))+geom_bar(stat='identity')



qplot(value, data=dm, group=variable, fill=variable, geom="histogram", binwidth=0.01)

t=hist(as.numeric(unlist(dat[,2])))
hist()
table(t)


dat2 <- within(dat, Groups <- cut(Values, breaks = c(1,3,6,12,30,50000)))

qplot(value, data=dm, group=variable, fill=variable, geom="histogram", binwidth=0.01)
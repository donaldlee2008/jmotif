require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require("lattice")


dat=data.frame(matrix(c(
10,369,130,121,123,118,121,125,
50,1390,516,468,443,445,429,479,
125,2734,1045,873,942,786,869,927,
250,4199,1686,1323,1430,1168,1284,1457,
500,6343,2617,1920,2267,1677,1927,2142,
750,8014,3388,2464,2900,2040,2355,2639,
1000,9120,3926,2710,3327,2231,2678,3022,
10000,23446,10384,6520,8890,4770,5940,6488,
25000,30779,13393,8341,11667,5812,7320,7581,
50000,37001,15635,9939,13816,6769,8249,8309,
75000,40515,16741,10856,14834,7264,8631,8606,
100000,43293,17547,11334,15819,7474,9257,8823,
150000,47135,18571,12208,17143,7965,9812,9017,
200000,50017,19240,12851,18040,8409,10257,9231,
500000,59712,21744,14923,20584,9478,11621,10102,
1000000,67508,23615,16534,22848,10392,12793,10602), nrow=16, byrow=T))
colnames(dat)<-c("sample","words_total","words_cylinder","words_bell","words_funnel",
                 "area_bell","area_funnel","area_cylinder")
dat=dat[,1:5]
dm=melt(dat,id.vars=c("sample"))
p=ggplot(dm,aes(x=sample,y=value,group=variable, col=variable)) + theme_bw() +
  geom_line(lwd=1.6) + geom_point(size=4) +
  scale_x_continuous("TRAIN dataset size") + 
  scale_y_continuous(expression(paste("terms, ", 10^3)),
                     breaks=c(1000,5000,10000,25000,50000,75000),labels=c("1","5","10","25","50","75")) +
  ggtitle("Terms count in corpus and classes")
p

+ geom_line(lwd=1.6) +
  geom_point(size=4) + theme_bw() +
  scale_x_continuous("TRAIN dataset size") + 
  scale_y_continuous(expression(paste("terms, ", 10^3)),
                     breaks=c(1000,5000,10000,15000),labels=c("1","5","10","15")) +
  ggtitle("Terms count in corpus and classes") +
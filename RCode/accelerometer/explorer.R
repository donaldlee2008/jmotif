library("zoo")
library("xts")
library("reshape")


ps = function(fname){
  tmp = read.csv(fname,header=F)
  par(mfrow=c(4,1))
  plot(tmp[,2],t="l")
  plot(tmp[,3],t="l")
  plot(tmp[,4],t="l")
  plot(tmp[-1,5],t="l")
  
}
fname="/media/DB/accelerometer/train_series/860_1338066902229_1338131613592.csv"
ps(fname)

tmp = read.csv(fname,header=F)
require(Cairo)
require(png)
require(ggplot2)
require(grid)
require(gridExtra)
require(reshape2)
require(raster)

plot_l=function(l){
  # trying to resize the digit
  im <- matrix(1 - unlist(as.matrix(l))/256,nrow=28,ncol=28,byrow=F)
  # find x
  xmax=0
  for(i in 1:28){
    for(j in 1:28){
      if(im[i,j]<1){
        xmax=i
        break
      }
    }
  }
  xmin=28
  for(i in 28:1){
    for(j in 1:28){
      if(im[i,j]<1){
        xmin=i;
        break
      }
    }
  }
  # find y
  ymax=0
  for(i in 1:28){
    for(j in 1:28){
      if(im[j,i]<1){
        ymax=i;
        break
      }
    }
  }
  ymin=28
  for(i in 28:1){
    for(j in 1:28){
      if(im[j,i]<1){
        ymin=i;
        break
      }
    }
  }
  print(paste(xmin,xmax,ymin,ymax))
  intermediate=im[xmin:xmax,ymin:ymax]
  rr <- raster(nrow=xmax-xmin,ncol=ymax-ymin)
  for(i in 1:(xmax-xmin)){
    for(j in 1:(ymax-ymin)){
      rr[i,j] <- intermediate[i,j]
    }
  }
  #plot(raster(im))
  #plot(rr)
  ss <- raster(nrow=28,ncol=28)
  ss <- resample(rr,ss,method="bilinear")
  #plot(ss)
  ggplot(melt(as.matrix(ss)), aes(Var1,-Var2,fill=value)) + geom_raster()   +
    theme(
      axis.line = element_blank(), 
      axis.text.x = element_blank(), 
      axis.text.y = element_blank(),
      axis.ticks = element_blank(), 
      axis.title.x = element_blank(), 
      axis.title.y = element_blank(), 
      axis.ticks.length = unit(0.001, "cm"), 
      axis.ticks.margin = unit(0.001, "cm"), 
      legend.position = "none", 
      panel.background = element_blank(), 
      panel.border = element_blank(), 
      panel.grid.major = element_blank(), 
      panel.grid.minor = element_blank(), 
      panel.margin = unit(0, "lines"), 
      plot.background = element_blank(), 
      plot.margin = unit(0*c(-1.5, -1.5, -1.5, -1.5), "lines")
    )}


plot_l(train[2,-1])
dev.off()
l=train[2,-1]
#train <- read.csv("../data/digits/digits_reduced_50.csv", sep= " ", header=FALSE)
train <- read.csv("../data/digits/digits_reduced_50.csv", sep= " ", header=FALSE)

for(set in c(0:9)){
  set_dat <- train[(1+set*50):(51+set*50),]
  Cairo(width = 600, height = 800, file=paste("digits/reduced_digit_",set,".png",sep=""), type="png",
        bg = "white", canvas = "white")
  grid.newpage()
  pushViewport(viewport(layout = grid.layout(10, 5)))
  for(i in c(0:49)){
    print(plot_l(set_dat[i+1,]), 
          vp = viewport(layout.pos.row = (i %/% 5) + 1, layout.pos.col = i %% 5 + 1))
  }
  dev.off()
}  

r <- raster(nrow=3, ncol=3)
r[] <- 1:ncell(r)
s <- raster(nrow=10, ncol=10)
s <- resample(r, s, method='bilinear')
#par(mfrow=c(1,2))
#plot(r)
#plot(s)


library(raster)
## Original data (4x4)
rr <- raster(ncol=4, nrow=4)
rr[] <- 1:16
## Resize to 5x5
ss <- raster(ncol=5,  nrow=5)
ss <- resample(rr, ss)
## Resize to 3x3
tt <- raster(ncol=3, nrow=3)
tt <- resample(rr, tt)
## Plot for comparison
par(mfcol=c(1,1))
plot(rr, main="original data")
plot(ss, main="resampled to 5-by-5")
plot(tt, main="resampled to 3-by-3")
?raster



r <- raster(nrow=20, ncol=24)
r[] <- 1:ncell(r)
s <- raster(nrow=18, ncol=10)
s <- resample(r, s, method='bilinear')
#par(mfrow=c(1,2))
plot(r)
plot(s)
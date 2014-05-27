require(Cairo)
require(png)
require(ggplot2)
require(grid)
require(gridExtra)
require(reshape2)
require(raster)

args <- commandArgs(trailingOnly = TRUE)
print(paste("provided arguments:", args))
print(paste("recizing",args[1]," into",args[2]))

#l=d
resize_l=function(l){
  # trying to resize the digit
  im <- matrix(unlist(as.matrix(l)),nrow=28,ncol=28,byrow=F)
  # find x
  xmax=0
  for(i in 1:28){
    for(j in 1:28){
      if(im[i,j]>0){
        xmax=i
        break
      }
    }
  }
  xmin=28
  for(i in 28:1){
    for(j in 1:28){
      if(im[i,j]>0){
        xmin=i;
        break
      }
    }
  }
  # find y
  ymax=0
  for(i in 1:28){
    for(j in 1:28){
      if(im[j,i]>0){
        ymax=i;
        break
      }
    }
  }
  ymin=28
  for(i in 28:1){
    for(j in 1:28){
      if(im[j,i]>0){
        ymin=i;
        break
      }
    }
  }
  #print(paste(xmin,xmax,ymin,ymax))
  if(xmin<ymin && xmax>ymax){
    ymin=xmin
    ymax=xmax
    #intermediate=im[ymin:ymax,ymin:ymax]
  }else if(xmin>ymin && xmax<ymax){
    xmin=ymin
    xmax=ymax
    #intermediate=im[xmin:xmax,xmin:xmax]
  }
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
  matrix(as.matrix(ss),nrow=1,ncol=784)
}

train <- read.csv(args[1], sep= " ", header=FALSE)
labels <- train[,1]
resized <- t(apply(train[,-1],1,resize_l))
resized <- cbind(labels,resized)
write(t(resized),file=paste(args[2],ncolumns=785)

file <- read.table("../data/digits/train.csv", header=F,sep="\n")
data=apply(file, 1, function(i)as.numeric((strsplit(i, "\\s")[[1]])))
data=t(data)
#data=rbind.fill(lapply(data, function (x) as.data.frame(t(x))))
row_names=dat[,1]
file=1
resized <- t(apply(data[,-1],1,resize_l))
write(t(resized),file="../data/digits/resized_train.csv",ncolumns=785)      
      

plot_l=function(l){
  ggplot(melt(1-matrix(unlist(l),nrow=28,ncol=28)/256), aes(Var1,-Var2,fill=value)) + geom_raster()   +
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
    )
}
      
train <- read.csv("../data/digits/test_resizer.csv", sep= " ", header=FALSE)
d=file[3,]
print(arrangeGrob(plot_l(d),plot_l(resize_l(d)),nrow=2))

resized <- t(apply(train,1,resize_l))

dev.off()

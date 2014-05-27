require(ggplot2)
require(Cairo)
require(plyr)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require(lattice)
require(seewave)
require(tuneR)

# this reads all wavs and makes the CSVs
#
smootheness=c(6,2)
sizes=c("test",0)
#
path="/media/Stock/sounds/"
classes=c("aedes","anopheles","beetles","fruit_flies","honeybees",
          "house_flies","moth_flies","quinx","tarsalis")
for(class in classes){
  print(class)
  files=list.files(paste(path,class,sep=""),pattern="*.wav$")
  counter=0
  plots=0
  for(file in files){
      wav=readWave(paste(path,class,"/",file,sep=""))
      dd = as.matrix(t(env(wav, smootheness, colwave=2, norm=T, plot=F)))
      row.names(dd) <- c(class)
      if(length(dd)<10001){
        fname = paste(path,class,"/",file,".csv",sep="")
        write.table(file=paste(path,class,"/",file,".csv",sep=""),
                   dd,dec=".",sep=" ",row.names=T,col.names=F,quote=F)
        sizes=rbind(sizes,c(fname,length(dd)))
      }
  }
}
ss = as.numeric(sizes[,2])
length(ss)
max(ss)
mean(ss)
hist(ss)

wav = readWave("/media/Stock/sounds/aedes/177246.5050.wav")
oscillo(wav, k=1)

smootheness=c(5,0)
par(new=TRUE)
env(wav, msmooth=smootheness, colwave=2, norm=T, plot=T)

png("/media/Stock/sounds/test2.png",width=1500,height=2400,units="px",res=86)
par=par(mfrow=c(9,5))
for(class in classes){
  print(class)
  files=list.files(paste(path,class,sep=""),pattern="*.wav$")
  counter=0
  plots=0
  for(file in files){
    counter = counter+1
    #print(file)  
    if((counter %% 10) == 0){
     wav=readWave(paste(path,class,"/",file,sep=""))
     dd = as.matrix(t(env(wav, smootheness, colwave=2, norm=T, plot=F)))
     row.names(dd) <- c(class)
     #oscillo(wav, k=1)
     dd=env(wav, msmooth=smootheness, colwave=3, norm=T, plot=T)
     #ifreq(wav)
     #write.table(file=paste(path,class,"/",file,".csv",sep=""),
     #             dd,dec=".",sep=" ",row.names=T,col.names=F,quote=F)
     plots=plots+1
     if(plots>4){
       break
     }
    } 
  }
}
dev.off()

wav=readWave("/media/Stock/sounds/fruit_flies/216054.6450.wav")


test <- strsplit(readLines("/media/Stock/sounds/all.txt")," ")
maxlen=max(unlist(lapply(test, function(x) length(x))))
newM <- lapply(test, function(.ele){
  c(.ele, rep(NA, maxlen))[1:maxlen]})
mat=do.call(rbind, newM)

data=as.data.frame(matrix(as.numeric(mat[,-1]),nrow=18099,byrow=F))
data$classes=factor(names)

dummy=data[1,]
for(c in classes){
  print(dim(data[data$class==c,]))
  si = sample(dim(data[data$class==c,])[1],100)
  s = (data[data$class==c,])[si,]
  dummy=rbind(dummy,s)
}
dummy=dummy[-1,]
dummy=cbind(dummy$class,dummy[,1:9361])
write.table(dummy,file="sample100.txt",quote=F,sep=" ",row.names=F,col.names=F,dec=".")

wav = readWave(file)
oscillo(wav, k=1)
par(new=TRUE)
dd=env(wav, msmooth=c(5,2), colwave=2, norm=T, plot=F)
write.table(file="/media/Stock/sounds/test.csv",as.matrix(t(dd)),dec=".",sep=" ",row.names=F,col.names=F)
str(t(dd))
files=list.files(path,pattern="*.wav$")
f=files[1]
ifreq(wav)

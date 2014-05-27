require(ggplot2)
require(Cairo)
require(reshape2)
require(scales)
require(RColorBrewer)
library(gridExtra)
require(lattice)
require(stringr)

#
#
znorm <- function(ts){
  d=as.numeric(ts)
  ts.mean <- mean(d)
  ts.dev <- sd(d)
  (d - ts.mean)/ts.dev
}

#
#
plotseries=function(data, series, title){
  # length of vectors
  size=as.numeric(length(data[1,]))
  # collect series
  pre_series=data[series[1],]
  # and the titles for the legend
  x2Seq=rep(paste("#",series[1]),size)
  # and join with the rest
  for(i in 2:(length(series))){
    seq = as.numeric(data[series[i],])
    pre_series = rbind(pre_series, (seq + (i-1)*9))
    x2Seq=cbind(x2Seq,rep(paste("#",series[i]),size))
  }
  # melt together
  dm=melt(t(pre_series))
  # legend titles
  dm$X2=c(x2Seq)
  dm$X1 <- factor(dm$X2, levels=c(paste(x2Seq[1,])), labels=c(paste(x2Seq[1,])))
  dm$index=c(rep(seq(1:size),length(series)))
  #
  p = ggplot(dm, aes(x = index, y = value, group = X1, color=X1)) + 
    geom_line(size = 1) + theme_bw() + ggtitle(title) +
    #geom_line(aes(linetype=X1), size = 1) + theme_bw() + ggtitle(title) +
    theme(plot.title=element_text(size=18),
          axis.text.x=element_blank(), axis.text.y=element_blank(),
          axis.ticks=element_blank(),
          axis.title.x=element_blank(),axis.title.y=element_blank()) +
    scale_colour_discrete(name="Index:",
          guide = guide_legend(title.theme=element_text(size=14, angle=0), reverse = TRUE,
          keywidth = 1, keyheight = 1.5, label.theme=element_text(size=14, angle=0)))
  #+
#    scale_linetype_discrete("Series index:",
#          guide = guide_legend(title.theme=element_text(size=14, angle=0), reverse = TRUE,
#          keywidth = 2, keyheight = 1.5, label.theme=element_text(size=14, angle=0)))
  p  
}
#
#
#
dat = read.csv("activity/test-amplitude-series.csv",sep=" ",header=F)
#
one=(dat[grep("one*",dat[,1]),])[,-1]

one[1,]=c(rnorm(10,mean=0,sd=0.002),rnorm(10,mean=4,sd=0.002),rnorm(10,mean=3,sd=0.002),
          rnorm(30,mean=0,sd=0.002))
one[2,]=c(rnorm(15,mean=0,sd=0.002),rnorm(5,mean=6,sd=0.002),rnorm(10,mean=4,sd=0.002),
          rnorm(30,mean=0,sd=0.002))

plot=plotseries(one, c(1:5), "Two units amplitude")
plot
for(i in 1:5){
  print(one[i,])
  p(unlist(one[i,]), paste("one",i,sep=""), col[1])
}

#
two=(dat[grep("two*",dat[,1]),])[,-1]
plot2=plotseries(two, c(1:5), "Three units amplitude")
plot2
for(i in 1:5){
  print(two[i,])
  p(unlist(two[i,]), paste("two",i,sep=""), col[2])
}

#
three=(dat[grep("three*",dat[,1]),])[,-1]
plot3=plotseries(three, c(1:5), "Four units amplitude")
plot3
for(i in 1:5){
  print(three[i,])
  p(unlist(three[i,]), paste("three",i,sep=""), col[3])
}

print(arrangeGrob(plot, plot2, plot3, ncol=3))
#
Cairo(width = 800, height = 400, 
      file="activity/test-amplitude-series.png", 
      type="png", pointsize=8, 
      bg = "transparent", canvas = "white", units = "px", dpi = 96)
print(arrangeGrob(plot, plot2, plot3, ncol=3))
dev.off()



dat = read.csv("activity/test3-series.csv",sep=" ",header=F)
full=(dat[dat[,1]==0,])[,-1]
plot=plotseries(full, c(1:10), "One hour events")
two=(dat[dat[,1]==1,])[,-1]
plot2=plotseries(two, c(1:10), "Two hour events")
three=(dat[dat[,1]==2,])[,-1]
plot3=plotseries(three, c(1:10), "Three hour events")

print(arrangeGrob(plot, plot2, plot3, ncol=3))

#
#
#
df=data.frame(dat[,-1])
row.names(df) = dat[,1]
hc <- hclust(dist(df), "complete"); par(mar=c(3,1,1,5));plot(as.dendrogram(hc),horiz=T)
library(ctc)
write.table(hc2Newick(hc), file="activity/test-amplitude-HC-Euclidean.newick",row.names=FALSE,col.names=FALSE)

#
# DTW
#
library(dtw);distMatrix <- dist(df, method="DTW")
hc <- hclust(distMatrix, method="complete");plot(hc)
write.table(hc2Newick(hc), file="activity/test-amplitude-HC-dtw.newick",row.names=FALSE,col.names=FALSE)

#
# require
#
require("biwavelet")
wt.t1=wt(cbind(c(1:60),c(unlist(dat[1,-1]))),mother="dog")
wt.t2=wt(cbind(c(1:60),c(unlist(dat[2,-1]))),mother="dog")
wt.t3=wt(cbind(c(1:60),c(unlist(dat[3,-1]))),mother="dog")
wt.t4=wt(cbind(c(1:60),c(unlist(dat[4,-1]))),mother="dog")
wt.t5=wt(cbind(c(1:60),c(unlist(dat[5,-1]))),mother="dog")
wt.t6=wt(cbind(c(1:60),c(unlist(dat[6,-1]))),mother="dog")
wt.t7=wt(cbind(c(1:60),c(unlist(dat[7,-1]))),mother="dog")
wt.t8=wt(cbind(c(1:60),c(unlist(dat[8,-1]))),mother="dog")
wt.t9=wt(cbind(c(1:60),c(unlist(dat[9,-1]))),mother="dog")
wt.t10=wt(cbind(c(1:60),c(unlist(dat[10,-1]))),mother="dog")
wt.t11=wt(cbind(c(1:60),c(unlist(dat[11,-1]))),mother="dog")
wt.t12=wt(cbind(c(1:60),c(unlist(dat[12,-1]))),mother="dog")
wt.t13=wt(cbind(c(1:60),c(unlist(dat[13,-1]))),mother="dog")
wt.t14=wt(cbind(c(1:60),c(unlist(dat[14,-1]))),mother="dog")
wt.t15=wt(cbind(c(1:60),c(unlist(dat[15,-1]))),mother="dog")
## Store all wavelet spectra into array
w.arr=array(NA, dim=c(15, NROW(wt.t1$wave), NCOL(wt.t1$wave)))
w.arr[1, , ]=wt.t1$wave
w.arr[2, , ]=wt.t2$wave
w.arr[3, , ]=wt.t3$wave
w.arr[4, , ]=wt.t4$wave
w.arr[5, , ]=wt.t5$wave
w.arr[6, , ]=wt.t6$wave
w.arr[7, , ]=wt.t7$wave
w.arr[8, , ]=wt.t8$wave
w.arr[9, , ]=wt.t9$wave
w.arr[10, , ]=wt.t10$wave
w.arr[11, , ]=wt.t11$wave
w.arr[12, , ]=wt.t12$wave
w.arr[13, , ]=wt.t13$wave
w.arr[14, , ]=wt.t14$wave
w.arr[15, , ]=wt.t15$wave

w.arr.dis=wclust(w.arr)
dm=w.arr.dis$dist.mat
hc <- hclust(w.arr.dis$dist.mat, method="complete");plot(hc)
write.table(hc2Newick(hc), file="activity/test-amplitude-HC-DWT.newick",row.names=FALSE,col.names=FALSE)

plot(hclust(w.arr.dis$dist.mat, method="complete"), sub="", main="",
     ylab="Dissimilarity", hang=-1)

hc <- hclust(distMatrix, method="complete");plot(hc)
write.table(hc2Newick(hc), file="activity/dtw.newick",row.names=FALSE,col.names=FALSE)

# extracting DWT coefficients (with Haar filter)
library(wavelets)
wtData <- NULL
for (i in 1:nrow(df)) {
  a <- t(df[i,])
  wt <- dwt(a, filter="haar", boundary="periodic")
  wtData <- rbind(wtData, unlist(c(wt@W,wt@V[[wt@level]])))
}
wtData <- as.data.frame(wtData)

# set class labels into categorical values
classId <- c(rep("1",5), rep("2",5), rep("3",5))
wtSc <- data.frame(cbind(classId, wtData))

# build a decision tree with ctree() in package party
library(party)
ct <- ctree(classId ~ ., data=wtSc,
              controls = ctree_control(minsplit=30, minbucket=10, maxdepth=5))
pClassId <- predict(ct)

# check predicted classes against original class labels
table(classId, pClassId)

(sum(classId==pClassId)) / nrow(wtSc)

plot(ct, ip_args=list(pval=FALSE), ep_args=list(digits=0))


?dwt
wt.t1=dwt(c(unlist(dat[1,-1])), filter="haar", boundary="periodic")
wt.t2=dwt(c(unlist(dat[2,-1])), filter="haar", boundary="periodic")
wt.t3=dwt(c(unlist(dat[3,-1])), filter="haar", boundary="periodic")
wt.t4=dwt(c(unlist(dat[4,-1])), filter="haar", boundary="periodic")
wt.t5=dwt(c(unlist(dat[5,-1])), filter="haar", boundary="periodic")
wt.t6=dwt(c(unlist(dat[6,-1])), filter="haar", boundary="periodic")
wt.t7=dwt(c(unlist(dat[7,-1])), filter="haar", boundary="periodic")
wt.t8=dwt(c(unlist(dat[8,-1])), filter="haar", boundary="periodic")
wt.t9=dwt(c(unlist(dat[9,-1])), filter="haar", boundary="periodic")
wt.t10=dwt(c(unlist(dat[10,-1])), filter="haar", boundary="periodic")
wt.t11=dwt(c(unlist(dat[11,-1])), filter="haar", boundary="periodic")
wt.t12=dwt(c(unlist(dat[12,-1])), filter="haar", boundary="periodic")
wt.t13=dwt(c(unlist(dat[13,-1])), filter="haar", boundary="periodic")
wt.t14=dwt(c(unlist(dat[14,-1])), filter="haar", boundary="periodic")
wt.t15=dwt(c(unlist(dat[15,-1])), filter="haar", boundary="periodic")
## Store all wavelet spectra into array
w.arr=array(NA, dim=c(15, NROW(c(wt.t1@W,wt.t1@V[[wt.t1@level]])), NCOL(c(wt.t1@W,wt.t1@V[[wt.t1@level]]))))
w.arr[1, , ]=c(wt.t1@W,wt.t1@V[[wt.t1@level]])
w.arr[2, , ]=c(wt.t2@W,wt.t2@V[[wt.t2@level]])
w.arr[3, , ]=c(wt.t3@W,wt.t3@V[[wt.t3@level]])
w.arr[4, , ]=c(wt.t4@W,wt.t4@V[[wt.t4@level]])
w.arr[5, , ]=c(wt.t5@W,wt.t5@V[[wt.t5@level]])
w.arr[6, , ]=c(wt.t6@W,wt.t6@V[[wt.t6@level]])
w.arr[7, , ]=c(wt.t7@W,wt.t7@V[[wt.t7@level]])
w.arr[8, , ]=c(wt.t8@W,wt.t8@V[[wt.t8@level]])
w.arr[9, , ]=c(wt.t9@W,wt.t9@V[[wt.t9@level]])
w.arr[10, , ]=c(wt.t10@W,wt.t10@V[[wt.t10@level]])
w.arr[11, , ]=c(wt.t11@W,wt.t11@V[[wt.t11@level]])
w.arr[12, , ]=c(wt.t12@W,wt.t12@V[[wt.t12level]])
w.arr[13, , ]=c(wt.t13@W,wt.t13@V[[wt.t13level]])
w.arr[14, , ]=c(wt.t14@W,wt.t14@V[[wt.t14level]])
w.arr[15, , ]=c(wt.t15@W,wt.t15@V[[wt.t15level]])




wt.t1=wt(cbind(c(1:60),c(unlist(dat[1,-1]))))
wt <- dwt(c(unlist(dat[1,-1])), filter="haar", boundary="periodic")
unlist(c(wt@W,wt@V[[wt@level]]))




#
theme_fullframe <- function (base_size = 12){
  structure(list(
    axis.line = element_blank(), 
    axis.text.x = element_blank(), 
    axis.text.y = element_blank(),
    axis.ticks = element_blank(), 
    axis.title.x = element_blank(), 
    axis.title.y = element_blank(), 
    axis.ticks.length = unit(0.01, "cm"), 
    axis.ticks.margin = unit(0.01, "cm"), 
    legend.position = "none", 
    panel.background = element_blank(), 
    panel.border = element_blank(), 
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank(), 
    panel.margin = unit(0, "lines"), 
    plot.background = element_blank(), 
    plot.margin = unit(0*c(-1.5, -1.5, -1.5, -1.5), "lines")
  ), class = "options")
}
#
gg_color_hue <- function(n) {
  hues = seq(15, 375, length=n+1)
  hcl(h=hues, l=65, c=100)[1:n]
}
col=gg_color_hue(3)
dev.new(width=4, height=4)
plot(1:6, pch=16, cex=2, col=gg_color_hue(6))

p=function(series, num, col){
  #fname=paste(num,".ps",sep="")
  fname=paste(num,sep="")
  dm = data.frame(index=c(1:60),value=series)
  p1 = ggplot(dm, aes(x = index, y = value)) +
    theme_bw() + geom_line(colour=col,lwd=1.1)+
    scale_x_continuous(expand=c(0,1)) + scale_y_continuous(expand=c(0,1)) +
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
  #Cairo(width = 250, height = 80, file=fname, type="png", pointsize=12, 
  #      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
  #print(p1)
  #dev.off()
  Cairo(width = 240, height = 75, 
        file=paste("activity/amplitude/new_",fname,sep=""),
        type="pdf", pointsize=18, 
        bg = "transparent", canvas = "white", units = "px", dpi = 96)
  print(p1)
  dev.off()
}
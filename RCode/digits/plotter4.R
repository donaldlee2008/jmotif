require(Cairo)
require(png)
require(ggplot2)
require(reshape2)
require(signal)

par(mfrow=c(2,1))

s1=c(-0.2414473041298642, 0.07681184937687652, 0.29939465712103164, 0.6913066443918887, 0.6930624541153522, 0.9542010176447088, 0.8580873749525448, 0.9474182944591215, 0.8288491669871455, 0.7683786167660592, 0.5693132122081876, 0.3184922231860103, 0.09023546081714691, 0.3727036654304376, 0.18081719862957263, 0.4562940730417024, 0.21990240421116214, 0.4245274381344169, 0.4245274381344169, 0.21006933869715572, -0.06555387251820247, -0.24126224672808538, -0.2802930307895497, -0.051482393410325455, 0.11189979855816395, 0.1844254067716664, 0.10164645420830115, 0.4967874276041049, 0.27665141174952657, 0.3727036654304376, 0.16939890710382513, 0.31125827814569534, 0.31125827814569534, 0.4271145145344954, 0.5893389390729968, 0.8580873749525448, 0.6191664880784747, 0.3421447558290979, 0.3401667615261674, 0.06760524515636197, -0.16418416680830766, -0.4732367160945338, -0.5447332683318851, -0.6234581110139547, -0.5280845002806083, -0.5280845002806083, -0.5729916501573185, -0.2923426786516931)
s2=c(0.8368466033272023,0.6050420168067228,0.5589827229373194,0.7090605237487737,0.0,0.5589827229373194,0.0,0.38083351192152526,0.6050420168067228,0.5436893203883495,0.7394957983193278,1.0072837636131335,1.107053830680096,0.8856293969290568,0.6167064597609442,0.888100201441836,0.623130690510073,0.6493806311844196,0.7899306613028443,0.5437059269582976,0.8368466033272023,0.719992540804959,0.7687404163131278,1.0060156973878098,1.0880262034222772,0.8191828013704274,0.5156601022200351,0.7258577956261318,0.40439749410063164,0.0,0.0,0.0,0.0,0.6793806310470656,0.5156601022200351,0.8558014985717318,1.1294502991504076,1.092896174863388,0.8441421035472716,0.8558014985717318,0.5437059269582976,0.6793806310470656,0.4828527834675139,0.0,0.4828527834675139,0.7899306613028443,1.0049237193209812,0.8368466033272023,1.0880262034222772,1.0060156973878098,1.0074599865705443,0.0,0.6167064597609442)
x=c(1:length(s1))
plot(x,s1,type="l")
bf <- butter(2, 0.2, type="low", plane="z")
z <- filter(bf, s1)
lines(x, z, col = "red")

x=c(1:length(s2))
plot(x,s2,type="l")
bf <- butter(2, 0.2, type="low", plane="z")
z <- filter(bf, s2)
lines(x, z, col = "red")


lo <- loess(s1~x,control = loess.control(surface = "direct"))
plot(x,s1)
lines(predict(lo,data.frame(x = seq(0, 47, 1))), col='red', lwd=2)

plot(x,s1,type="l")
xy.int.sp <- as.data.frame(with(coords, list(x = spline(x)$y, y = spline(y)$y)))
lines(spline(s1,n=80), col = "red")







# plot the first one
image=matrix(as.vector(unlist(set3[3,])),nrow=28,ncol=28,byrow=T)
writePNG(image/256, "digits/3.png")

x=c(1:length(s1))
plot(x,s1,type="l")
bf <- butter(3, 0.2, type="low", plane="z")
z <- filter(bf, s1)
lines(x, z, col = "red")

?spline
?approx
sp <- spline(x, s1, n = 201)
plot(c(1:201),sp$y,type="l")

dat = read.csv("../data/digits/digits_train.txt",sep=" ")
reduced = rep(NA,length(dat[1,]))
for(i in 0:9){
  datPart=dat[dat[,1]==i,-1]
  hc <- hclust(dist(datPart), "ave");
  memb <- cutree(hc, k = 100)
  for(j in 1:100){
    reduced = rbind(reduced, as.vector(c(i, unlist((datPart[memb==j,])[1,]))))
  }
}
write(t(reduced),file="digits_reduced_100.csv",ncolumns=785)

?write



for(j in 1:10){
  im <- matrix( 1 - unlist((datPart[memb==3,])[j,])/256, nrow = 28, byrow=T)
  writePNG(im, paste("clust",j,".png",sep="")) 
}


im <- matrix( 1 - unlist((datPart[memb==3,])[1,])/256, nrow = 28, byrow=T)
?cutree
dat1=dat[dat[,1]==1,-1]
hc <- hclust(dist(dat1), "complete");
Cairo(width = 3000, height = 5000, file="clustering.png", type="png")
plot(as.dendrogram(hc),horiz=T)
dev.off()

memb <- cutree(hc, k = 50)
cent <- NULL
for(k in 1:50){
  cent <- rbind(cent, colMeans(dat1[memb == k, , drop = FALSE]))
}

# averages the images, for uses as prospect
library(png)
image=matrix(as.vector(unlist(cent[1,-1])),nrow=28,ncol=28,byrow=F)
writePNG(image, "averages.png")


train <- read.csv("../data/train.csv", header=TRUE)

labels <- as.numeric(train[,1])
train <- train[,-1]

bigify <- function(im, r){
  result <- matrix(nrow=nrow(im)*r, ncol=ncol(im)*r)
  for(i in 1:nrow(im)){
    for(j in 1:ncol(im)){
      for(k in 1:r){
        for(l in 1:r){
          result[(i - 1) * r + (k - 1) + 1, (j - 1) * r + (l - 1) + 1] <- im[i, j]
        }
      }
    }
  }
  return(result)
}

images <- list()
for(x in 0:9){
  average <- colMeans(train[labels == x,])
  im <- t(matrix(1 - average/256, nrow = 28))
  im <- bigify(im, 8)
  images[[as.character(x)]] <- im
}

row1 <- matrix(nrow=28*8)
for(i in 0:4){
  row1 <- cbind(row1, images[[as.character(i)]])
}
row1 <- row1[,-1] # kills the NA row

row2 <- matrix(nrow=28*8)
for(i in 5:9){
  row2 <- cbind(row2, images[[as.character(i)]])
}
row2 <- row2[,-1] # kills the NA row

writePNG(rbind(row1, row2), "averages.png")
#
#
#

library(reshape2)
library(ggplot2)
dat=read.csv("../digits_reduced_50.csv",sep=" ")
series_2plot = 15
im <- matrix( 1 - as.vector(unlist(dat[series_2plot,-1]))/256,nrow=28,ncol=28,byrow=F)
im2 <- matrix( 1 - as.vector(unlist(dat[series_2plot,-1]))/256,nrow=28,ncol=28,byrow=F)
ggplot(melt(cbind(im,im2)), aes(Var1,-Var2,fill=value)) + geom_raster()


writePNG(im, "digits/averages.png")


im <- matrix( 1 - d/256,nrow=28,ncol=28,byrow=F)

(p1=ggplot(melt(im), aes(X1,-X2,fill=value)) + geom_raster()  +
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
   ))


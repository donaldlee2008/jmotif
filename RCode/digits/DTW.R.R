require(reshape)
file <- scan("../data/digits//test.csv",what=double())
data <-cbind(rep(0,28000),matrix(file,nrow=28000,ncol=784,byrow=T))

write(t(data),file="../data/digits/test_DTW.csv",ncol=785)

plot(c(1:80),res[209,-1],type="l")


line=data[1,]
line=line[!is.na(line)]
x=c(1:length(line))
plot(x,line,type="l")
lines(spline(line,n=80), col = "red")

plot(spline(line,n=80)$x,spline(line,n=80)$y,type="l",col = "red")
plot(c(1:80),res[1,],type="l",col = "red")
lines(spline(line,n=80), col = "red")

xy.int.sp <- as.data.frame(with(coords, list(x = spline(x)$y, y = spline(y)$y)))
lines(spline(s1,n=80), col = "red")


data1=data[data[,1]==1,]

s1=(data[1,])
s1=s1[!is.na(s1)]
x=c(1:length(s1))
plot(x,s1,type="l")
bf <- butter(2, 0.57, type="low", plane="z")
z <- filter(bf, s1)
lines(x, z, col = "blue")

lo <- loess(s1~x,control = loess.control(surface = "direct"))
plot(x,s1)
lines(predict(lo,data.frame(x = seq(0, 47, 1))), col='red', lwd=2)

plot(x,s1,type="l")
xy.int.sp <- as.data.frame(with(coords, list(x = spline(x)$y, y = spline(y)$y)))
lines(spline(s1,n=80), col = "red")


# get those numbers 3
train <- read.csv("../data/digits/digits_reduced_50.csv", sep= " ", header=FALSE)
set3 <- train[train[,1]==1,-1]
image=matrix(as.vector(unlist(set3[1,])),nrow=28,ncol=28,byrow=T)
writePNG(image/256, "digits/3.png")

l = set3[1,]
plots=apply(set3,1,plot_l)
p = rectGrob()
grid.arrange(plots, ncol=5)
print(arrangeGrob(plots, ncol=5))

grid.newpage()
pushViewport(viewport(layout = grid.layout(10, 5)))
for(i in c(0:49)){
  print(plot_l(set3[i+1,]), vp = viewport(layout.pos.row = (i %/% 5) + 1, layout.pos.col = i %% 5 + 1))
}
i=0
for(i in c(0:49)){
  print(paste(i %/% 5+1, " ", i %% 5 + 1))
}       

print(plot_l(set3[i,]), vp = viewport(layout.pos.row = i %% 10, layout.pos.col = i %/% 10))



grid.text("MAIN TITLE", vp = viewport(layout.pos.row = 1, layout.pos.col = 1:2))
print(plots[1], vp = viewport(layout.pos.row = 1, layout.pos.col = 1))         
print(plots[2], vp = viewport(layout.pos.row = 2, layout.pos.col = 2))         

print(plot_l(set3[2,]), vp = viewport(layout.pos.row = 2, layout.pos.col = 4))
print(plot_l(set3[2,]), vp = viewport(layout.pos.row = 2, layout.pos.col = 4))

library(gridBase)
vps <- baseViewports()
pushViewport(vps$figure)
vp1=plotViewport(c(0,0,0,0))
print(plot_l(set3[2,]), vp=vp1)

pushViewport(viewport(layout.pos.col=1, layout.pos.row=1))
grid.draw(plots[1])

do.call(grid.arrange, plots)

grid(place())
testlay <- function(just="centre") {
  pushViewport(viewport(layout=grid.layout(1, 1, widths=unit(1, "inches"),
                                           heights=unit(0.25, "npc"),
                                           just=just)))
  pushViewport(viewport(layout.pos.col=1, layout.pos.row=1))
  grid.rect()
  grid.text(paste(just, collapse="-"))
  popViewport(2)
}
testlay()
testlay(plotsc("left", "top"))
testlay(c("right", "top"))
testlay(c("right", "bottom"))
testlay(c("left", "bottom"))
testlay(c("left"))
testlay(c("right"))
testlay(c("bottom"))
testlay(c("top"))


plot_l(l)
plot_l=function(l){
  im <- matrix(1 - unlist(l)/256,nrow=28,ncol=28,byrow=F)
  ggplot(melt(im), aes(Var1,-Var2,fill=value)) + geom_raster()   +
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
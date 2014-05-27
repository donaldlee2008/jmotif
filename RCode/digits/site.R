require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require(lattice)
require(colorRamps)

plot_d2(data[1,-1],data[2,-1])

grid.newpage()
pushViewport(viewport(layout = grid.layout(1, 1)))
print(plot_p(data[2,-1]), vp = viewport(layout.pos.row = 1, layout.pos.col = 1))
print(plot_d(data[1,-1]), vp = viewport(layout.pos.row = 1, layout.pos.col = 1))



plot_d=function(l){
  v = unname(unlist(l))
  v[v<(min(v)+0.3)] = NA
  im <- data.frame(value=v,x=rep(c(1:28),28),y=rep(c(28:1),each=28))
  ggplot(im, aes(x,y,fill=value)) + geom_raster()  +
    scale_fill_gradient(low="white", high="black", na.value=NA) +
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

plot_d2=function(d, p){
  dd = rescale(unname(unlist(d)))
  pp = rescale(unname(unlist(p)))
  pp[d<0.4]=NA
  im <- data.frame(value=pp,x=rep(c(1:28),28),y=rep(c(28:1),each=28))
  ggplot(im, aes(x,y,fill=value)) + geom_raster()  +
    scale_fill_gradient(low="green", high="red", na.value=NA) +
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
      plot.background = element_rect(fill="azure1"), 
      plot.margin = unit(0*c(-1.5, -1.5, -1.5, -1.5), "lines")
    )
}
plot_d2(data[1,-1],data[2,-1])


plot_p=function(l){
  im <- data.frame(value=unname(unlist(l)),x=rep(c(1:28),28),y=rep(c(28:1),each=28))
  ggplot(im, aes(x,y,fill=value)) + geom_tile()  +
    scale_fill_gradient(low="chartreuse", high="brown2") +
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

data=read.table("data/series_heat.txt", colClasses=rep("numeric",785),header=F)
grid.newpage()
pushViewport(viewport(layout = grid.layout(10, 8)))
for(key in c(0:9)){
  ds = data[data[,1]==key,]
 for(idx in seq(0,14,by=2)){
   digit <- ds[idx+1,-1]
   heat <-  ds[idx+2,-1]
   #Cairo(width = 600, height = 800, file=paste("digits/test_SVM_",set,".png",sep=""), type="png",
   #bg = "white", canvas = "white")
   #grid.newpage()
   #pushViewport(viewport(layout = grid.layout(10, 5)))
   print(plot_d2(digit, heat),
         vp = viewport(layout.pos.row = key+1, layout.pos.col = idx/2 + 1))
 }
}


plot_d(data[21,-1])
plot_p(data[22,-1])

pushViewport(viewport(layout = grid.layout(1, 1)))
print(plot_p(data[2,-1]), vp = viewport(layout.pos.row = 1, layout.pos.col = 1))
print(plot_d(data[1,-1]), vp = viewport(layout.pos.row = 1, layout.pos.col = 1))

require(Cairo)
require(reshape)
require(reshape2)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require(png)
require(ggplot2)

# plot function
#
plot_l=function(l){
  im <- matrix(1 - unlist(as.matrix(l))/256,nrow=28,ncol=28,byrow=F)
  ggplot(melt(im), aes(X1,-X2,fill=value)) + geom_raster()   +
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

#
# read the data
train <- read.csv("../data/digits/test_resized.csv", sep= " ", header=F)

indexes=c(1444,
          2219,
          2785,
          2933,
          3522,
          4631,
          4652,
          5322,
          5708,
          6285,
          6431,
          6873,
          7027,
          7128,
          7340,
          8394,
          8576,
          8779,
          9373,
          9705,
          10320,
          10345,
          10372,
          11744,
          11747,
          12442,
          12971,
          13334,
          14477,
          14646,
          15629,
          15711,
          16149,
          16725,
          16935,
          17293,
          17927,
          18224,
          18650,
          19084,
          19663,
          21291,
          21308,
          21727,
          23129,
          24175,
          24198,
          27405,
          27811
)
set=0
for(set in c(0:19)){
  set_dat <- train[(1+set*50):(51+set*50),]
  set_dat <- train[c(indexes,1),]
  Cairo(width = 600, height = 800, file=paste("digits/test_SVM_",set,".png",sep=""), type="png",
        bg = "white", canvas = "white")
  grid.newpage()
  pushViewport(viewport(layout = grid.layout(10, 5)))
  for(i in c(0:49)){
    print(plot_l(set_dat[i+1,]), 
          vp = viewport(layout.pos.row = (i %/% 5) + 1, layout.pos.col = i %% 5 + 1))
  }
  dev.off()
}  

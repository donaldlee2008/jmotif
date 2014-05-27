require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require(lattice)
require(VennDiagram)
library(grid)
library(gridBase)

#
# words plot
#
dat = read.csv("cbf/cbf_words-nored.csv",header=F,skip=1)
names(dat)=c("train_size","Total","Cylinder","Bell","Funnel")
index=sort(unique(dat$train_size))
total=rep(-1,length(index))
cylinder=rep(-1,length(index))
bell=rep(-1,length(index))
funnel=rep(-1,length(index))
for(i in 1:(length(index))){
  total[i]=mean(dat[dat$train_size==index[i],2])
  cylinder[i]=mean(dat[dat$train_size==index[i],3])
  bell[i]=mean(dat[dat$train_size==index[i],4])
  funnel[i]=mean(dat[dat$train_size==index[i],5])
}
#
d=data.frame(index,total,cylinder,bell,funnel)
#
#
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
colnames(dat)<-c("index","total","cylinder","bell","funnel",
                 "area_bell","area_funnel","area_cylinder")
#
#
#dm=melt(d,id.var="index")
dm=melt(dat[,1:5],id.var="index")
p_words <- ggplot(dm, aes(index, value, color=variable)) + geom_line(lwd=1.6) +
  geom_point(size=4) + theme_bw() +
  scale_x_continuous(expression(paste("TRAIN dataset size, ", 10^3)), limits=c(0,1000000),
        breaks=c(1000,100000,200000,500000,1000000),labels=c("1","100","200","500","1000")) + 
  scale_y_continuous(expression(paste("terms, ", 10^3)), limits=c(0,75000),
            breaks=c(1000,5000,10000,25000,50000,75000),labels=c("1","5","10","25","50","75")) +
  ggtitle("Terms count in corpus and classes") +
  scale_colour_discrete(name = element_blank(), labels=c("All terms", "Cylinder", "Bell", "Funnel"),
       guide = guide_legend(title.theme=element_text(size=16, angle=0),
       keywidth = 1, keyheight = 1, label.theme=element_text(size=13, angle=0))) +
  theme(plot.title=element_text(size=18),
       axis.title.x=element_text(size=16), axis.text.x=element_text(size=12), 
       axis.title.y=element_text(size=18), axis.text.y=element_text(size=14),
       legend.position = "bottom")
p_words
g <- ggplot_build(p_words)
unique(g$data[[1]]["colour"])

Cairo(width = 1000, height = 400, 
      file="/media/Stock/csdl-techreports/techreports/2011/11-09/figures/pre-venn", 
      #file="/home/psenin/Dropbox/PKDD/pre-venn", 
      type="ps", pointsize=18, 
      bg = "transparent", canvas = "white", units = "px", dpi = 82)
print(arrangeGrob(p_words, p_words, ncol=2, widths=c(0.8,1.2),clip=F))
dev.off()

#colour
#1  #F8766D
#8  #7CAE00
#15 #00BFC4
#22 #C77CFF
# A more complicated diagram
venn.plot <- draw.triple.venn(
  area1=23569,
  area2=16571,
  area3=22711,
  n12=4658,
  n13=8448,
  n23=1581,
  n123=0,
  category = c("Cylinder", "Funnel", "Bell"),
  fill = c("#7CAE00", "#00BFC4", "#C77CFF"),
  cex = 1.1,
  fontfamily = "sans",
  fontface = "plain",
  alpha = 0.50,
  lty = "blank",
  cat.col = c("#7CAE00", "#00BFC4", "#C77CFF"),
  cat.cex = 1.1,
  cat.fontfamily = "sans",
  cat.fontface = "bold",
  cat.dist = 0.09,
  scaled = TRUE,
  inverted = TRUE,
  rotation.degree = 45,
  main = "Complex Venn Diagram",
  sub = "Featuring: rotation and external lines",
  main.cex = 2,
  sub.cex = 1,
  margin = 0.2
);
dev.off()

Cairo(width = 1000, height = 400, 
      file="/media/Stock/csdl-techreports/techreports/2011/11-09/figures/bubbles", 
      #file="/home/psenin/thesis/csdl-techreports/pkdd/figures/precision-runtime", 
      type="ps", pointsize=18, 
      bg = "transparent", canvas = "white", units = "px", dpi = 82)


gl <- grid.layout(nrow=1, ncol=2)
# grid.show.layout(gl)

# setup viewports
vp.1 <- viewport(layout.pos.col=1, layout.pos.row=1) 
vp.2 <- viewport(layout.pos.col=2, layout.pos.row=1,width=1.6, height=1.6, clip="off") 

# init layout
pushViewport(viewport(layout=gl))
# access the first position

pushViewport(vp.1)

# start new base graphics in first viewport
par(new=TRUE, fig=gridFIG())

grid.draw(arrangeGrob(p_words))

# done with the first viewport
popViewport()

# move to the next viewport
pushViewport(vp.2)

grid.draw(venn.plot)

# done with this viewport
popViewport(1)

dev.off()
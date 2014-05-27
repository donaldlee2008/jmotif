require(ggplot2)
require(Cairo)
require(reshape)
require(scales)
require(RColorBrewer)
require(grid)
library(gridExtra)
require("lattice")

dat = read.table("../data/synthetic_control/synthetic_control_TRAIN",header=F)

dat=t(dat)

ones=(dat[,dat[1,]==1])[-1,1]
twos=(dat[,dat[1,]==2])[-1,1]
threes=(dat[,dat[1,]==3])[-1,1]
fours=(dat[,dat[1,]==4])[-1,1]
fives=(dat[,dat[1,]==5])[-1,1]
sixs=(dat[,dat[1,]==6])[-1,2]

# Take the twelve series and melt (or equivalently, stack) them:
dm <- melt(cbind(ones,twos,threes,fours,fives,sixs))
# add an index variable:
dm$index <- rep(1:60, 6)
dm$class <- c(rep("One",(60*1)), rep("Two",(60*1)), rep("Three",(60*1)),
              rep("Four",(60*1)), rep("Five",(60*1)), rep("Six",(60*1)))

# dm$variable is a factor with a level for each series; use it
# as a grouping variable. dm$value holds the values of each series.

# This produces a 'spaghetti plot' (familiar to mixed modelers):
p = ggplot(dm, aes(x = index, y = value, group = X2, color=class)) +
  theme_bw() + geom_line() + geom_hline(yintercept=0,lty=2) +
  ggtitle("Sample of six classes from UCR Synthetic Control set") +
  scale_x_continuous("time ticks", limits=c(0,60), breaks=seq(0,60,5)) + 
  scale_y_continuous("Value",limits=c(-2.3,2.3),breaks=seq(-2,2,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p
Cairo(width = 750, height = 250, file="synthetic/all_classes.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(p)
dev.off()
#
#
#
p1 = ggplot(dm[dm$X2=="ones",], aes(x = index, y = value, group = X2, color="black")) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 1, Normal") +
  scale_x_continuous("time ticks", limits=c(0,60), breaks=seq(0,60,10)) + 
  scale_y_continuous("Value",limits=c(-2.3,2.3),breaks=seq(-2,2,1))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p1
#
#
#
p2 = ggplot(dm[dm$X2=="twos",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 2, Periodic") +
  scale_x_continuous("time ticks", limits=c(0,60), breaks=seq(0,60,10)) + 
  scale_y_continuous("Value",limits=c(-2.3,2.3),breaks=seq(-2,2,1))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p2
#
#
#
p3 = ggplot(dm[dm$X2=="threes",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 3, Increasing trend") +
  scale_x_continuous("time ticks", limits=c(0,60), breaks=seq(0,60,10)) + 
  scale_y_continuous("Value",limits=c(-2.3,2.3),breaks=seq(-2,2,1))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p3
#
#
#
p4 = ggplot(dm[dm$X2=="fours",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 4, Decreasing trend") +
  scale_x_continuous("time ticks", limits=c(0,60), breaks=seq(0,60,10)) + 
  scale_y_continuous("Value",limits=c(-2.3,2.3),breaks=seq(-2,2,1))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p4
#
#
#
p5 = ggplot(dm[dm$X2=="fives",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 5, Upward shift") +
  scale_x_continuous("time ticks", limits=c(0,60), breaks=seq(0,60,10)) + 
  scale_y_continuous("Value",limits=c(-2.3,2.3),breaks=seq(-2,2,1))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p5
#
#
#
p6 = ggplot(dm[dm$X2=="sixs",], aes(x = index, y = value, group = X2)) +
  theme_bw() + geom_line(colour="black") + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 6, Downward shift") +
  scale_x_continuous("time ticks", limits=c(0,60), breaks=seq(0,60,10)) + 
  scale_y_continuous("Value",limits=c(-2.3,2.3),breaks=seq(-2,2,1))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p6
#
#
print(arrangeGrob(p1, p2, p3, p4, p5, p6, ncol=2))

Cairo(width = 1200, height = 800, 
      #file="/media/Stock/csdl-techreports/techreports/2011/11-09/figures/gun-point", 
      file="/home/psenin/thesis/csdl-techreports/pkdd/figures/synthetic-classes", 
      type="ps", pointsize=18, 
      bg = "transparent", canvas = "white", units = "px", dpi = 82)
print(arrangeGrob(p1, p2, p3, p4, p5, p6, ncol=2))
dev.off()


Cairo(width = 750, height = 500, file="synthetic/classes.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(arrangeGrob(p1, p2, p3, p4, p5, p6, ncol=2))
dev.off()

#
# misclassification analysis part
#
dat = read.table("../data/synthetic_control/synthetic_control_TRAIN",header=F)
dat=t(dat)
#classified as: 2, should be of class: 1
series21 = c(0.82607151, 1.4558358, 1.3495096, -0.01804232, -0.24880477, -1.4515907, -0.11697082, -0.54118873, 1.3136874, -0.079372154, 0.94992436, -0.043152287, 1.1676413, 0.45867584, -0.63388613, 0.43542194, -0.42990411, 0.010010843, -1.4800416, -0.51374541, -1.5957013, 1.5450332, 0.33219797, -1.2665937, 0.95069331, 1.0750234, 0.8052305, -0.96484981, 1.3454262, -1.0621344, 1.2325772, 0.75585906, 0.11760983, -0.15181189, -1.1242331, -1.3657078, 0.83842763, -0.58101467, -0.91722838, -1.5307654, -1.2494648, 1.1243949, -0.10458818, 1.4818473, -0.6348672, 0.78955997, 0.69140042, -0.47323007, 1.3209791, -1.4693295, -1.3319273, 0.39617933, 0.63571834, 0.75596512, -0.80758771, -1.2346693, -1.4958978, -1.2335821, 0.6320062, 1.3589755)
ones=cbind((dat[,dat[1,]==1])[-1,1:1],as.vector(series21))
dm=melt(ones)
dm$index <- rep(1:60, 2)
dm$color <- c(rep("true",(60*1)), rep("false",(60)))
              
p1 = ggplot(dm, aes(x = index, y = value, group = X2, colour=color)) +
  theme_bw() + geom_line() + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 1, Normal") +
  scale_x_continuous("time ticks", limits=c(0,60), breaks=seq(0,60,5)) + 
  scale_y_continuous("Value",limits=c(-2.3,2.3),breaks=seq(-2,2,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p1

twos=cbind((dat[,dat[1,]==2])[-1,3],as.vector(series21))
dm=melt(twos)
dm$index <- rep(1:60, 2)
dm$color <- c(rep("true",(60*1)), rep("false",(60)))

p1 = ggplot(dm, aes(x = index, y = value, group = X2, colour=color)) +
  theme_bw() + geom_line() + geom_hline(yintercept=0,lty=2) +
  ggtitle("Class 2, Periodic") +
  scale_x_continuous("time ticks", limits=c(0,60), breaks=seq(0,60,5)) + 
  scale_y_continuous("Value",limits=c(-2.3,2.3),breaks=seq(-2,2,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p1


twos=cbind((dat[,dat[1,]==2])[-1,1:5],series21)
dm <- melt(ones)
dm$index <- rep(1:60, 6)
dm$class <- c(rep("True",(60*5)), rep("Two",(60*1)), rep("Three",(60*1)),
              rep("Four",(60*1)), rep("Five",(60*1)), rep("Six",(60*1)))

# dm$variable is a factor with a level for each series; use it
# as a grouping variable. dm$value holds the values of each series.

# This produces a 'spaghetti plot' (familiar to mixed modelers):
p = ggplot(dm, aes(x = index, y = value, group = X2, color=class)) +
  theme_bw() + geom_line() + geom_hline(yintercept=0,lty=2) +
  ggtitle("Sample of six classes from UCR Synthetic Control set") +
  scale_x_continuous("time ticks", limits=c(0,60), breaks=seq(0,60,5)) + 
  scale_y_continuous("Value",limits=c(-2.3,2.3),breaks=seq(-2,2,0.5))+
  theme(plot.title=element_text(size = 18, vjust = 2))
p



Cairo(width = 750, height = 250, file="synthetic/all_classes.png", type="png", pointsize=12, 
      bg = "transparent", canvas = "white", units = "px", dpi = "auto")
print(p)
dev.off()


classified as: 2, should be of class: 1
[-0.78956823, 0.29916353, 0.36370087, -0.016663571, 1.5016502, 1.5227435, -0.15962893, -0.78925383, -0.13567751, -0.34046495, -0.86462361, 0.33326143, 0.63565516, -1.3611724, -1.5407508, -0.60370184, -0.14482364, 1.0666948, -1.0974211, -0.9255025, 0.89343295, -1.2383571, 0.30545149, 0.016805527, -0.42526667, -1.1013939, -1.0811295, -0.30476648, -1.6202078, 0.74732362, -0.84856073, 0.58317927, -0.46399479, 1.3558553, 0.38973874, 0.25820604, 0.74680915, 0.19261118, 0.69704852, -0.35209768, -1.6014297, -1.4448309, -0.98363756, -1.4268816, 1.359428, 1.5933687, -0.14933954, 1.0521182, 1.7412787, 1.5563269, -1.3953846, -0.48162966, -1.3993861, 1.6996066, -0.28673147, 1.6868021, 0.31142505, 0.99732721, 1.0297674, 0.43749866]
classified as: 2, should be of class: 1
[-0.46350058, -0.76728475, -0.99355764, 0.40631995, 0.41391243, 1.0437199, -0.015855912, 0.83149881, -0.30403017, 0.30634286, 0.88923565, 1.298493, 1.1925949, 0.92637647, 0.24631128, 1.0747415, 0.41827527, 0.61468819, -0.68240763, 1.2555445, -1.8094092, -0.05007873, -0.79434004, -1.4579738, -0.73286362, -1.6295128, -0.33389015, 1.1585704, -0.8890194, -1.4908367, 0.16619362, 0.5389617, 1.0777445, 1.0803508, -1.3957607, 1.1586837, -1.0667061, 1.5047081, -1.5471287, 1.2369316, 1.0847137, 1.1620266, -0.70997286, -0.58854985, 0.75398752, 0.14041318, -1.4777482, -1.482111, -0.84303957, 1.4187828, -0.28113942, -0.23932412, -0.44667247, 0.16681688, 0.82005343, -0.68563727, 0.82328307, -1.6724896, -1.4577754, 1.0983405]
classified as: 4, should be of class: 6
[1.9844942, 0.0049071139, 1.484761, 1.5200669, 0.14657724, 1.8169305, 1.649925, 0.7330127, 0.85131916, 1.0738692, 1.6062111, 2.1615632, 0.28415501, 0.12295315, 0.33689067, 0.85282589, 0.38198106, 1.7013585, 0.91977321, 1.8302493, 0.37978606, 0.3938117, 0.42857818, 0.11770749, -1.3691034, 0.44230619, 0.22131865, -0.95953237, -0.81799245, -1.1746418, -0.12171428, -0.43252917, 0.35350194, -1.0158209, -0.4045895, -0.23032929, -0.35574158, -1.4088737, -1.0839216, -0.16652565, -1.0728536, -0.71860386, -0.84784809, -1.5657042, -0.06140775, -0.80022788, -0.83555241, 0.079239287, 0.43745116, -0.79168973, -0.59851164, -0.086612979, -0.22419074, -1.235432, -1.1223712, -1.3393966, -0.87681085, -1.1144469, -0.0098253888, -1.4747235]
classified as: 4, should be of class: 6
[0.85954616, 0.98260828, 0.6257659, 0.92300639, 0.50201575, 0.21869766, 0.42750664, 0.51866327, 0.89754945, 1.5635716, 1.5476661, 0.26456603, 1.5645024, 1.3993898, -0.0045868364, 0.65910141, 0.52613712, 1.4182093, 0.97467575, 1.5163542, 1.5754029, 0.82858501, 0.25946654, 0.41382708, 1.2764761, 0.65201879, 0.72756669, 0.92216997, 0.19287647, 0.27357781, 0.18534866, 1.4463509, -0.88037579, -0.42000582, -0.6740491, -0.47851496, -0.50447106, -1.1263516, -0.91921551, -0.71298325, -0.29937202, -1.3847524, -1.0463383, -1.3752415, -0.16249542, -0.78263571, -0.39637012, -1.2045707, -1.4149176, -0.30511906, -1.4602464, -1.5508634, -0.32310215, -1.2757071, -1.4903171, -1.3064794, -1.4775954, -1.5421484, -0.49381341, -1.1305607]
classified as: 4, should be of class: 6
[0.8455511, 0.057141524, 1.2228095, 1.1976576, 1.5959747, 0.59080032, 0.71147174, 1.0495965, 0.023994658, 0.31906488, 1.2647356, -0.1794196, 1.18249, 1.2334823, 1.8446814, 0.77392097, 0.58666891, 2.0228864, 1.1987861, 1.3613836, 0.63190396, 0.89178074, 1.1991304, 0.75510013, -0.20659888, 0.032831272, -1.7763411, -0.56882354, -1.3275291, -0.11909345, -1.2480952, 0.22289498, -0.20099471, 0.13341948, -0.077435132, -1.5170955, 0.049414268, -0.55631457, 0.31961956, -0.13265441, 0.095203994, -0.73620278, 0.14590933, -1.8549525, -0.17668446, -0.034323168, -0.66076641, -1.6004695, -1.9367008, -1.5055811, 0.29496502, -1.2098032, -0.7406976, -0.28941823, -0.55371332, -1.1607237, -1.8972994, -0.51199761, -0.86978484, -0.2057573]
classified as: 3, should be of class: 5
[-0.53261259, -1.1153491, -1.1593086, -0.45048816, 0.25484457, -1.0936781, 0.18307425, -1.5917652, -0.073671295, -1.3811772, -1.2619778, -0.37117933, -1.4407405, -0.50525595, -0.81771386, 0.1499956, -0.24556765, -0.17020065, 0.09782543, -1.3187982, -1.1193454, -1.4102595, 0.19128488, 0.26859555, 0.25052128, -0.10696793, -1.7662046, 0.35671446, -0.36463989, -0.92750374, 0.1762805, -0.22042715, -1.4187971, 0.11070449, -0.096286846, -1.7086939, 0.04687232, -0.50986988, 1.1331454, -0.011601142, 0.95810648, 0.95850611, 0.21526281, 1.4766838, 0.3446165, -0.17828412, -0.05755885, 0.91788895, 1.9049987, 1.6744654, -0.059429855, 0.58368741, 0.84050561, 0.6569291, 0.96150336, 1.7074714, 1.5632042, 1.8189507, 1.8510302, 1.8316844]
NOREDUCTION,45,7,5,0.9766666666666667,0.023333333333333317



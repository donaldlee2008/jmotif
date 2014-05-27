require(Cairo)
require(ggplot2)
require(gridExtra)
require(reshape)
require(scales)
require(pracma)

window_size <- 128
discord1    <- 2575
discord2    <- 4161

# constant, window size
data_raw<-scan("sigmoids.txt")
data_length <- length(data_raw)

data <- data.frame(seq(1,5000,1), data_raw, 
c(rep(NA,discord1),data_raw[discord1:(discord1+window_size)],rep(NA,data_length-(discord1+window_size+1))),
c(rep(NA,discord2),data_raw[discord2:(discord2+window_size)],rep(NA,data_length-(discord2+window_size+1))))
                   
colnames(data) <- c("x", "sigmoids series", "discord1", "discord2")

plot_data <- melt(data, id.vars=c("x"))

p<-ggplot(plot_data, aes(x=x, y=value, group=variable, colour=variable)) +
  geom_line(size=0.8) + geom_point(size=3) +
  opts(title = "Sigmoid series discords", plot.title = theme_text(size=28, vjust = 2.2), 
       axis.text.x=theme_text(size=18), axis.title.x=theme_text(size=22),
       axis.text.y=theme_text(size=18), axis.title.y=theme_text(size=22, angle=90, hjust = 0.5, vjust = 0.3),
       panel.background = theme_rect(fill='white', colour='black'),
       panel.grid.minor = theme_blank(), panel.grid.major = theme_line("black", size = 0.1),
       plot.margin = unit(c(0.6, 0.2, 0.1, 0.3), "cm"),
       legend.title=theme_text(size=20,hjust=0.0,vjust=0.4),
       legend.text=theme_text(size = 18), legend.key.size=unit(2, "cm")) + labs(colour = "Plot curves:")
p

drops<-data.frame(seq(0,300,1),
                  data_raw[600:900], data_raw[1600:1900],data_raw[2600:2900],
                  data_raw[3600:3900], data_raw[4600:4900])
colnames(drops) <- c("x", "drop1", "drop2", "drop3 ** ", "drop4", "drop5")

plot_data <- melt(drops, id.vars=c("x"))

p<-ggplot(plot_data, aes(x=x, y=value, group=variable, colour=variable)) +
  geom_line(size=0.8) + geom_point(size=1.6) +
  opts(title = "Sigmoids drops", plot.title = theme_text(size=28, vjust = 2.2), 
       axis.text.x=theme_text(size=18), axis.title.x=theme_text(size=22),
       axis.text.y=theme_text(size=18), axis.title.y=theme_text(size=22, angle=90, hjust = 0.5, vjust = 0.3),
       panel.background = theme_rect(fill='white', colour='black'),
       panel.grid.minor = theme_blank(), panel.grid.major = theme_line("black", size = 0.1),
       plot.margin = unit(c(0.6, 0.2, 0.1, 0.3), "cm"),
       legend.title=theme_text(size=20,hjust=0.0,vjust=0.4),
       legend.text=theme_text(size = 18), legend.key.size=unit(2, "cm")) + labs(colour = "Sigmoids drops:")
p

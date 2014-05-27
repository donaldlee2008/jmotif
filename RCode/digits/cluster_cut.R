#
#
dat = read.csv("data/digits/train_normalized.csv",sep=" ")
reduced = rep(NA,length(dat[1,]))
for(i in 0:9){
  datPart=dat[dat[,1]==i,-1]
  hc <- hclust(dist(datPart), "ave");
  memb <- cutree(hc, k = 200)
  for(j in 1:200){
    reduced = rbind(reduced, as.vector(c(i, unlist((datPart[memb==j,])[1,]))))
  }
}
write(t(reduced),file=paste("train_normalized_reduced_200.csv",ncolumns=785)
      

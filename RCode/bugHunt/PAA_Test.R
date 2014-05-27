n=18
inc=1/n
d<-seq(0,1,by=inc)
f<-qnorm(d,mean=0,sd=1)
s<-""
for(i in 1:n){
  s<-paste(s,f[i],",")
}
s

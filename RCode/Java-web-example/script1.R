source("d:/workspace/jmotif/RCode/SAX/PAA_SAX.R")

##
## the normalization java web example test
##
data      <- c(0.22, 0.23, 0.24, 0.50, 0.83)
data.mean <- mean(data)
data.sd   <- sqrt(var(data))
data.norm <- (data - data.mean) / data.sd
data.norm

##
## the PAA java web example test
## 
data.norm <- znorm(t(as.matrix(data)))
data.paa3 <- paa(data.norm, 3)
data.paa3


##
## the SAX java web example test
## 
data.norm <- znorm(t(as.matrix(data)))
data.paa3 <- paa(data.norm, 3)
data.sax3 <- ts2string(data.paa3, 3)
data.sax3

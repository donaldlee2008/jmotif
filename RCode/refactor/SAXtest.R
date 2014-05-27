ts=as.matrix(c(2.02, 2.33, 2.99, 6.85, 9.20, 8.80, 7.50, 6.00, 5.85, 3.85, 4.85, 3.85, 2.22, 1.45, 1.34))

ap=10
  len <- ncol(ts)
  res <- ts
  if(len != ap){
    if( (len %% ap) == 0 ){
      res <- reshape(ts, len %/% ap, ap)
    }else{
      tmp <- matrix( rep(0, ap*len), ap, len)
      for(i in 1:ap){
        tmp[i, ] <- ts[1, ]
      }
      extended <- reshape(tmp, 1, ap*len)
      res <- reshape(extended, len, ap)
    }
  }
  matrix(colMeans(res), nrow=1, ncol=ap)
}

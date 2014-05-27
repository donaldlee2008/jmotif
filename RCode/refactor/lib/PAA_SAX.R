##
## This code implements PAA and SAX algorithms.
##
## changelog:
##
## last edited 25-08-2009, seninp@gmail.com
##
## v. 0.0
## 27-02-2009, seninp@gmail.com, created first implementations of PAA & SAX
##
##
## This code is based on the original work of 
## Lin, J., Keogh, E., Lonardi, S. & Chiu, B. 
## which is bearing next copyright:
##

##
## THE ORIGINAL COPYRIGHT FROM THE AUTHORS
##
##% Copyright and terms of use (DO NOT REMOVE):
##% The code is made freely available for non-commercial uses only, provided that the copyright 
##% header in each file not be removed, and suitable citation(s) (see below) be made for papers 
##% published based on the code.
##%
##% The code is not optimized for speed, and we are not responsible for any errors that might
##% occur in the code.
##%
##% The copyright of the code is retained by the authors.  By downloading/using this code you
##% agree to all the terms stated above.
##%
##%   Lin, J., Keogh, E., Lonardi, S. & Chiu, B. 
##%   "A Symbolic Representation of Time Series, with Implications for Streaming Algorithms." 
##%   In proceedings of the 8th ACM SIGMOD Workshop on Research Issues in Data Mining and 
##%   Knowledge Discovery. San Diego, CA. June 13, 2003. 
##%
##%
##%   Lin, J., Keogh, E., Patel, P. & Lonardi, S. 
##%   "Finding Motifs in Time Series". In proceedings of the 2nd Workshop on Temporal Data Mining, 
##%   at the 8th ACM SIGKDD International Conference on Knowledge Discovery and Data Mining. 
##%   Edmonton, Alberta, Canada. July 23-26, 2002



## load matlab library for the 'reshape' function code, why not?
#
library(reshape)

## Compute Z normalization for the timeseries.
##  parameters:
##  ts - the timeseries to normalize
##
##  ts should be a matrix, we do care only about first row
#
znorm <- function(ts){
 ts.mean <- mean(ts[1,])
 ts.dev <- sd(ts[1,])
 (ts - ts.mean)/ts.dev
}

##
## Compute PAA approximation for the timeseries with reduction
##  parameters:
##  ts - timeseries
##  ap - number of points in approximated timeseries
#
paa <- function(ts, ap){
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

##
## Converts the specified resolution into the cut points
##
alphabet2cut <- function(alphabet_size){
 switch(alphabet_size,
  0.00,
  c(-Inf,  0.00),
  c(-Inf, -0.43,  0.43),
  c(-Inf, -0.67,  0.00,  0.67),
  c(-Inf, -0.84, -0.25,  0.25,  0.84),
  c(-Inf, -0.97, -0.43,  0.00,  0.43,  0.97),
  c(-Inf, -1.07, -0.57, -0.18,  0.18,  0.57,  1.07),
  c(-Inf, -1.15, -0.67, -0.32,  0.00,  0.32,  0.67,  1.15),
  c(-Inf, -1.22, -0.76, -0.43, -0.14,  0.14,  0.43,  0.76,  1.22),
  c(-Inf, -1.28, -0.84, -0.52, -0.25,  0.00,  0.25,  0.52,  0.84,  1.28),
  c(-Inf, -1.34, -0.91, -0.60, -0.35, -0.11,  0.11,  0.35,  0.60,  0.91, 1.34),
  c(-Inf, -1.38, -0.97, -0.67, -0.43, -0.21,  0.00,  0.21,  0.43,  0.67, 0.97, 1.38),
  c(-Inf, -1.43, -1.02, -0.74, -0.50, -0.29, -0.10,  0.10,  0.29,  0.50, 0.74, 1.02, 1.43),
  c(-Inf, -1.47, -1.07, -0.79, -0.57, -0.37, -0.18,  0.00,  0.18,  0.37, 0.57, 0.79, 1.07, 1.47),
  c(-Inf, -1.50, -1.11, -0.84, -0.62, -0.43, -0.25, -0.08,  0.08,  0.25, 0.43, 0.62, 0.84, 1.11, 1.5),
  c(-Inf, -1.53, -1.15, -0.89, -0.67, -0.49, -0.32, -0.16,  0.00,  0.16, 0.32, 0.49, 0.67, 0.89, 1.15, 1.53),
  c(-Inf, -1.56, -1.19, -0.93, -0.72, -0.54, -0.38, -0.22, -0.07,  0.07, 0.22, 0.38, 0.54, 0.72, 0.93, 1.19, 1.56),
  c(-Inf, -1.59, -1.22, -0.97, -0.76, -0.59, -0.43, -0.28, -0.14,  0.00, 0.14, 0.28, 0.43, 0.59, 0.76, 0.97, 1.22, 1.59),
  c(-Inf, -1.62, -1.25, -1.00, -0.80, -0.63, -0.48, -0.34, -0.20, -0.07, 0.07, 0.20, 0.34, 0.48, 0.63, 0.80, 1.00, 1.25, 1.62),
  c(-Inf, -1.64, -1.28, -1.04, -0.84, -0.67, -0.52, -0.39, -0.25, -0.13, 0.00, 0.13, 0.25, 0.39, 0.52, 0.67, 0.84, 1.04, 1.28, 1.64),
 )
}

##
## compute distance matrix for the alphabet size specified
##
distance_matrix <- function (alphabet_size){
 if(alphabet_size>1 && alphabet_size<20){
  cutlines <- alphabet2cut(alphabet_size)[2:alphabet_size]
  distance_matrix <- matrix(rep(0, alphabet_size*alphabet_size), byrow=T, nrow=alphabet_size, ncol=alphabet_size)
  i=1
  while(i <= alphabet_size){
    # the min_dist for adjacent symbols are 0, so we start with i+2
    j=i+2;
    while(j <= alphabet_size){
      # square the distance now for future use
      distance_matrix[i,j]=(cutlines[i]-cutlines[j-1])*(cutlines[i]-cutlines[j-1])
      # the distance matrix is symmetric
      distance_matrix[j,i] = distance_matrix[i,j]
      j=j+1;
    }
    i=i+1;
  }
  distance_matrix
 }
}

##
## Converts the specified resolution into the cut points
##
num2letter <- function(num){
  letters <- c("a",  "b",  "c",  "d",  "e",
               "f",  "g",  "h",  "i",  "j",
               "k",  "l",  "m",  "n",  "o",
               "p",  "q",  "r",  "s",  "t",
               "u",  "v",  "w",  "x",  "y",  "z")
  letters[num]
}


##
## Converts the timeseries into string
##
ts2string <- function(ts, aSize){
 cut_points <- alphabet2cut(aSize)
 res <- rep(0, ncol(ts))
 for(i in 1:ncol(ts)){
  res[i] = length(cut_points[cut_points<=ts[i]])
 }
 num2letter(res)
}

##
## compute distance between strings
##
min_dist <- function(str1, str2, alphabet_size, compression_ratio){
 if(length(str1) != length(str2)){
  stop("error: the strings must have equal length");
 }else{    
  if(any(str1 > alphabet_size) | any(str2 > alphabet_size)){
   stop('error: some symbol(s) in the string(s) exceed(s) the alphabet size!');
  }else{
    dist_table <- distance_matrix(alphabet_size);
    dist <- 0;
    dist = sqrt(compression_ratio * sum(diag(dist_table[str1,str2])));
  }
 }
}

##
## compute the Euclidean distance between the set of points
##
euclidean <- function(x, y){
 as.numeric(dist( rbind(x,y) ))
}

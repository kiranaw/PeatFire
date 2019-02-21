library(raster)
r15 <- raster("f15.asc", package="raster")
crs(r15) <- CRS("+proj=robin +datum=WGS84")
plot(r15)
w <- matrix(c(0,1,0,1,0,1,0,1,0), nr=3,nc=3) #neighbourhood
f <- focal(r15, w=w, pad=TRUE, padValue=0) #apply w
plot(f)


#test
#create a raster file
r <- raster(ncol=6, nrow=6, vals = 0)
crs(r) <- CRS("+proj=robin +datum=WGS84")
r[1,1] <- 1.0
r[1,2] <- 1.0
r[2,1] <- 1.0
r[3,3] <- 1.0
plot(r)
values(r)
(w <- matrix(c(0,1,0,1,0,1,0,1,0), nr=3,nc=3)) #neighbourhood
(f <- focal(r, w=w, pad=TRUE, padValue=0)) #apply w
values(f)
plot(f)
hist(f)

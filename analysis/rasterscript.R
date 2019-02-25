library(raster)
r15 <- raster("f15.asc", package="raster")
crs(r15) <- CRS("+proj=robin +datum=WGS84")
plot(r15)
w <- matrix(c(0,1,0,1,0,1,0,1,0), nr=3,nc=3) #neighbourhood
f <- focal(r15, w=w, pad=TRUE, padValue=0) #apply w
plot(f) #plot all cells

#Sorry - we need the average for each cell but this gives us the number of all cells. I saw that you found
# ab better solution. Can you insert this?
hist(f, main = "all cells")         #hist of burned neighbour cells for all cells 
hist(f[r15 == 1], main = "focal cells all burned", xlab = "# of burned cells") #hist of burned neighbour cells for burned cells only
hist(f[r15 == 0], main = "focal cells all unburned", xlab = "# of burned cells") #hist of burned neighbour cells for not burned cells only


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

#separate the results of counting for cells which are originally burned (have a value of "1" ), and the ones which were orignally not burned (f-value == "0")
f_burned <- f[r == 1]  #vector with number of burned neighbours for burned cells
f_notburned <- f[r == 0]  #vector with number of burned neighbours for non-burned cells
hist(f_burned)
hist(f_notburned)

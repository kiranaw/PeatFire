library(raster)
r15 <- raster("f15.asc", package="raster")
crs(r15) <- CRS("+proj=robin +datum=WGS84")
plot(r15, main = "2015", legend = F)
w <- matrix(c(0,1,0,1,0,1,0,1,0), nr=3,nc=3) #neighbourhood
f15 <- focal(r15, w=w, pad=TRUE, padValue=0) #apply w
plot(f15, main = "2015", legend = F)

r14 <- raster("f14.asc", package="raster")
crs(r14) <- CRS("+proj=robin +datum=WGS84")
plot(r14, main = "2014", legend = F)
w <- matrix(c(0,1,0,1,0,1,0,1,0), nr=3,nc=3) #neighbourhood
f14 <- focal(r14, w=w, pad=TRUE, padValue=0) #apply w
plot(f14, main = "2014", legend = F)

r13 <- raster("f13.asc", package="raster")
crs(r13) <- CRS("+proj=robin +datum=WGS84")
plot(r13, main = "2013", legend = F)
w <- matrix(c(0,1,0,1,0,1,0,1,0), nr=3,nc=3) #neighbourhood
f13 <- focal(r13, w=w, pad=TRUE, padValue=0) #apply w
plot(f13, main = "2013", legend = F)

r12 <- raster("f12.asc", package="raster")
crs(r12) <- CRS("+proj=robin +datum=WGS84")
plot(r12, main = "2012", legend = F)
w <- matrix(c(0,1,0,1,0,1,0,1,0), nr=3,nc=3) #neighbourhood
f12 <- focal(r12, w=w, pad=TRUE, padValue=0) #apply w
plot(f12, main = "2012", legend = T)

r11 <- raster("f11.asc", package="raster")
crs(r11) <- CRS("+proj=robin +datum=WGS84")
plot(r11, main = "2011", legend = F)
w <- matrix(c(0,1,0,1,0,1,0,1,0), nr=3,nc=3) #neighbourhood
f11 <- focal(r11, w=w, pad=TRUE, padValue=0) #apply w
plot(f11, main = "2011", legend = F)

r10 <- raster("f10.asc", package="raster")
crs(r10) <- CRS("+proj=robin +datum=WGS84")
plot(r10, main = "2010", legend = F)
w <- matrix(c(0,1,0,1,0,1,0,1,0), nr=3,nc=3) #neighbourhood
f10 <- focal(r10, w=w, pad=TRUE, padValue=0) #apply w
plot(f10, main = "2010", legend = F)

r09 <- raster("f09.asc", package="raster")
crs(r09) <- CRS("+proj=robin +datum=WGS84")
plot(r09, main = "2009", legend = F)
w <- matrix(c(0,1,0,1,0,1,0,1,0), nr=3,nc=3) #neighbourhood
f09 <- focal(r09, w=w, pad=TRUE, padValue=0) #apply w
plot(f09, main = "2009", legend = F)

r08 <- raster("f08.asc", package="raster")
crs(r08) <- CRS("+proj=robin +datum=WGS84")
plot(r08, main = "2008", legend = F)
w <- matrix(c(0,1,0,1,0,1,0,1,0), nr=3,nc=3) #neighbourhood
f08 <- focal(r08, w=w, pad=TRUE, padValue=0) #apply w
plot(f08, main = "2008", legend = F)

r07 <- raster("f07.asc", package="raster")
crs(r07) <- CRS("+proj=robin +datum=WGS84")
plot(r07, main = "2007", legend = F)
w <- matrix(c(0,1,0,1,0,1,0,1,0), nr=3,nc=3) #neighbourhood
f07 <- focal(r07, w=w, pad=TRUE, padValue=0) #apply w
plot(f07, main = "2007", legend = F)

r06 <- raster("f06.asc", package="raster")
crs(r06) <- CRS("+proj=robin +datum=WGS84")
plot(r06, main = "2006", legend = F)
w <- matrix(c(0,1,0,1,0,1,0,1,0), nr=3,nc=3) #neighbourhood
f06 <- focal(r06, w=w, pad=TRUE, padValue=0) #apply w
plot(f06, main = "2006", legend = F)

r05 <- raster("f05.asc", package="raster")
crs(r05) <- CRS("+proj=robin +datum=WGS84")
plot(r05, main = "2005", legend = F)
w <- matrix(c(0,1,0,1,0,1,0,1,0), nr=3,nc=3) #neighbourhood
f05 <- focal(r05, w=w, pad=TRUE, padValue=0) #apply w
plot(f05, main = "2005", legend = F)

r04 <- raster("f04.asc", package="raster")
crs(r04) <- CRS("+proj=robin +datum=WGS84")
plot(r04, main = "2004", legend = F)
w <- matrix(c(0,1,0,1,0,1,0,1,0), nr=3,nc=3) #neighbourhood
f04 <- focal(r04, w=w, pad=TRUE, padValue=0) #apply w
plot(f04, main = "2004", legend = F)

r03 <- raster("f03.asc", package="raster")
crs(r03) <- CRS("+proj=robin +datum=WGS84")
plot(r03, main = "2003", legend = F)
w <- matrix(c(0,1,0,1,0,1,0,1,0), nr=3,nc=3) #neighbourhood
f03 <- focal(r03, w=w, pad=TRUE, padValue=0) #apply w
plot(f03, main = "2003", legend = F)

r02 <- raster("f02.asc", package="raster")
crs(r02) <- CRS("+proj=robin +datum=WGS84")
map02 <- plot(r02, main = "2002", legend = F)
w <- matrix(c(0,1,0,1,0,1,0,1,0), nr=3,nc=3) #neighbourhood
f02 <- focal(r02, w=w, pad=TRUE, padValue=0) #apply w
plot(f02, main = "2002", legend = F)

r01 <- raster("f01.asc", package="raster")
crs(r01) <- CRS("+proj=robin +datum=WGS84")
map01 <- plot(r01, main = "2001", legend = F)
w <- matrix(c(0,1,0,1,0,1,0,1,0), nr=3,nc=3) #neighbourhood
f01 <- focal(r01, w=w, pad=TRUE, padValue=0) #apply w
plot(f01, main = "2001", legend = F)

val01 <- c(
  + length((f01[f01 == 0])) / length(f01), 
  + length((f01[f01 == 1])) / length(f01), 
  + length((f01[f01 == 2])) / length(f01), 
  + length((f01[f01 == 3])) / length(f01), 
  + length((f01[f01 == 4])) / length(f01))

val02 <- c(
  + length((f02[f02 == 0])) / length(f02), 
  + length((f02[f02 == 1])) / length(f02), 
  + length((f02[f02 == 2])) / length(f02), 
  + length((f02[f02 == 3])) / length(f02), 
  + length((f02[f02 == 4])) / length(f02))

val03 <- c(
  + length((f03[f03 == 0])) / length(f03), 
  + length((f03[f03 == 1])) / length(f03), 
  + length((f03[f03 == 2])) / length(f03), 
  + length((f03[f03 == 3])) / length(f03), 
  + length((f03[f03 == 4])) / length(f03))

val04 <- c(
  + length((f04[f04 == 0])) / length(f04), 
  + length((f04[f04 == 1])) / length(f04), 
  + length((f04[f04 == 2])) / length(f04), 
  + length((f04[f04 == 3])) / length(f04), 
  + length((f04[f04 == 4])) / length(f04))

val05 <- c(
  + length((f05[f05 == 0])) / length(f05), 
  + length((f05[f05 == 1])) / length(f05), 
  + length((f05[f05 == 2])) / length(f05), 
  + length((f05[f05 == 3])) / length(f05), 
  + length((f05[f05 == 4])) / length(f05))

val06 <- c(
  + length((f06[f06 == 0])) / length(f06), 
  + length((f06[f06 == 1])) / length(f06), 
  + length((f06[f06 == 2])) / length(f06), 
  + length((f06[f06 == 3])) / length(f06), 
  + length((f06[f06 == 4])) / length(f06))

val07 <- c(
  + length((f07[f07 == 0])) / length(f07), 
  + length((f07[f07 == 1])) / length(f07), 
  + length((f07[f07 == 2])) / length(f07), 
  + length((f07[f07 == 3])) / length(f07), 
  + length((f07[f07 == 4])) / length(f07))

val08 <- c(
  + length((f08[f08 == 0])) / length(f08), 
  + length((f08[f08 == 1])) / length(f08), 
  + length((f08[f08 == 2])) / length(f08), 
  + length((f08[f08 == 3])) / length(f08), 
  + length((f08[f08 == 4])) / length(f08))

val09 <- c(
  + length((f09[f09 == 0])) / length(f09), 
  + length((f09[f09 == 1])) / length(f09), 
  + length((f09[f09 == 2])) / length(f09), 
  + length((f09[f09 == 3])) / length(f09), 
  + length((f09[f09 == 4])) / length(f09))

val10 <- c(
  + length((f10[f10 == 0])) / length(f10), 
  + length((f10[f10 == 1])) / length(f10), 
  + length((f10[f10 == 2])) / length(f10), 
  + length((f10[f10 == 3])) / length(f10), 
  + length((f10[f10 == 4])) / length(f10))

val11 <- c(
  + length((f11[f11 == 0])) / length(f11), 
  + length((f11[f11 == 1])) / length(f11), 
  + length((f11[f11 == 2])) / length(f11), 
  + length((f11[f11 == 3])) / length(f11), 
  + length((f11[f11 == 4])) / length(f11))

val12 <- c(
  + length((f12[f12 == 0])) / length(f12), 
  + length((f12[f12 == 1])) / length(f12), 
  + length((f12[f12 == 2])) / length(f12), 
  + length((f12[f12 == 3])) / length(f12), 
  + length((f12[f12 == 4])) / length(f12))

val13 <- c(
  + length((f13[f13 == 0])) / length(f13), 
  + length((f13[f13 == 1])) / length(f13), 
  + length((f13[f13 == 2])) / length(f13), 
  + length((f13[f13 == 3])) / length(f13), 
  + length((f13[f13 == 4])) / length(f13))

val14 <- c(
  + length((f14[f14 == 0])) / length(f14), 
  + length((f14[f14 == 1])) / length(f14), 
  + length((f14[f14 == 2])) / length(f14), 
  + length((f14[f14 == 3])) / length(f14), 
  + length((f14[f14 == 4])) / length(f14))

val15 <- c(
  + length((f15[f15 == 0])) / length(f15), 
  + length((f15[f15 == 1])) / length(f15), 
  + length((f15[f15 == 2])) / length(f15), 
  + length((f15[f15 == 3])) / length(f15), 
  + length((f15[f15 == 4])) / length(f15))

# I want to plot every map within a grid
par(mfrow=c(3,5))
pal <- colorRampPalette(c("black","darkgreen"))
plot(r01, main = "2001", col = pal(2), legend = T)
plot(r02, main = "2002", col = pal(3), legend = F)
plot(r03, main = "2003", col = pal(3), legend = F)
plot(r04, main = "2004", col = pal(3), legend = F)
plot(r05, main = "2005", col = pal(3), legend = F)
plot(r06, main = "2006", col = pal(3), legend = F)
plot(r07, main = "2007", col = pal(3), legend = F)
plot(r08, main = "2008", col = pal(3), legend = F)
plot(r09, main = "2009", col = pal(3), legend = F)
plot(r10, main = "2010", col = pal(3), legend = F)
plot(r11, main = "2011", col = pal(3), legend = F)
plot(r12, main = "2012", col = pal(3), legend = F)
plot(r13, main = "2013", col = pal(3), legend = F)
plot(r14, main = "2014", col = pal(3), legend = F)
plot(r15, main = "2015", col = pal(3), legend = F)

#
#test
#create a raster file
r <- raster(ncol=6, nrow=6, vals = 0)
crs(r) <- CRS("+proj=robin +datum=WGS84")
r[1,1] <- 1.0
r[1,2] <- 1.0
r[2,1] <- 1.0
r[3,3] <- 1.0
r[2,3] <- 1.0
r[3,2] <- 1.0
plot(r)
plot(r, breaks = br, col = terrain.colors(4))
values(r)
(w <- matrix(c(0,1,0,1,0,1,0,1,0), nr=3,nc=3)) #neighbourhood
(f <- focal(r, w=w, pad=TRUE, padValue=0)) #apply w
values(f)
plot(f)
br <- seq(0,4,1)
plot(f, col = rev(terrain.colors(4)), breaks = c(0,1,2,3,4))
hist(f)
values(f)

length((f[f == 0]))
length((f[f == 1]))
length((f[f == 2]))
length((f[f == 3]))
length((f[f == 4]))

all <- cbind(nbr, val01, val02, val03, val04, val05, val06, val07, val08, val09, val10, val11, val12, val13, val14, val15)

plot(all)
plot(all[2.])


all[1,]

all[1,2:16]

nol <- all[1,2:16]
satu <- all[2, 2:16]



year <- c('2001', '2002', '2003', '2004', '2005', '2006', '2007', '2008', '2009', '2010', '2011', '2012', '2013', '2014', '2015')


p <- plot_ly(data, x = ~year, y = ~nol, name = '0', type = 'scatter', mode = 'lines',
             line = list(color = 'rgb(205, 12, 24)', width = 4)) %>%
  add_trace(y = ~satu, name = '1', line = list(color = 'rgb(22, 96, 167)', width = 4)) %>%
  add_trace(y = ~dua, name = '2', line = list(color = 'rgb(205, 12, 24)', width = 4, dash = 'dash')) %>%
  add_trace(y = ~tiga, name = '3', line = list(color = 'rgb(22, 96, 167)', width = 4, dash = 'dash')) %>%
  add_trace(y = ~empat, name = '4', line = list(color = 'rgb(205, 12, 24)', width = 4, dash = 'dot')) %>%
  layout(title = "nearest burned neighbors",
         xaxis = list(title = "Year"),
         yaxis = list (title = "Probability"))
p

q <- plot_ly(data, x = ~year, y = ~dua, name = '2', type = 'scatter', mode = 'lines',
             line = list(color = 'rgb(205, 12, 24)', width = 4)) %>%
#  add_trace(y = ~satu, name = '1', line = list(color = 'rgb(22, 96, 167)', width = 4)) %>%
  add_trace(y = ~dua, name = '2', line = list(color = 'rgb(205, 12, 24)', width = 4, dash = 'dash')) %>%
  add_trace(y = ~tiga, name = '3', line = list(color = 'rgb(22, 96, 167)', width = 4, dash = 'dash')) %>%
#  add_trace(y = ~empat, name = '4', line = list(color = 'rgb(205, 12, 24)', width = 4, dash = 'dot')) %>%
  layout(title = "nearest burned neighbors",
         xaxis = list(title = "Year"),
         yaxis = list (title = "Probability"))
q

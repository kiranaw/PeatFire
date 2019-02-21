NLQuit()

nl.path <- "C:\\Program Files\\NetLogo 6.0\\app\\"
Sys.setenv(JAVA_HOME = "C:\\Program Files\\NetLogo 6.0\\runtime")
library(RNetLogo)
NLStart(nl.path, nl.jarname = "netlogo-6.0.0.jar")

#C:\Users\I5\Dropbox\KLN_2017\rebuild model wildfire\peatfire-v10-TEST-R\peatfire-model-v10

model.path <- "C:\\Users\\I5\\Dropbox\\KLN_2017\\rebuild model wildfire\\peatfire-v10-TEST-R\\peatfire-model-v10\\rebuild-model-wildfire-v10-R-EXP1.nlogo"
NLLoadModel(model.path)

sim <- function(evapotranspiration) {
  NLCommand("set evapotranspiration ", evapotranspiration, "setup")
  NLDoCommand(365, "go")
  ret <- NLReport("total-fire")
  return(ret)
}

d <- seq(0.003, 0.005, 0.0002)
pb <- sapply(d, function(evap) sim(evap))
plot(d, pb, xlab = "evapotranspiration", ylab = "fires")

rep.sim <- function(evapotranspiration, rep)
  lapply(evapotranspiration, function(evap) replicate(rep, sim(evap)))

d <- seq(0.003, 0.005, 0.0002)
res <- rep.sim(d, 10)
boxplot(res, names = d, xlab = "evapotranspiration", ylab = "fires")

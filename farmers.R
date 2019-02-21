nl.path <- "C:\\Program Files\\NetLogo 6.0\\app\\"
Sys.setenv(JAVA_HOME = "C:\\Program Files\\NetLogo 6.0\\runtime")
library(RNetLogo)
NLStart(nl.path, nl.jarname = "netlogo-6.0.0.jar")

model.path <- "C:\\Users\\I5\\Dropbox\\KLN_2017\\rebuild model wildfire\\peatfire-v10-TEST-R\\peatfire-model-v10\\rebuild-model-wildfire-v10-R-EXP1.nlogo"
NLLoadModel(model.path)

sim <- function(farmers) {
  NLCommand("set farmers ", farmers, "setup")
  NLDoCommand(365, "go")
  ret <- NLReport("total-fire")
  return(ret)
}

d <- seq(20, 200, 20)
pb <- sapply(d, function(evap) sim(evap))
plot(d, pb, xlab = "farmers", ylab = "fires")

rep.sim <- function(farmers, rep)
  lapply(farmers, function(farm) replicate(rep, sim(farm)))

d <- seq(20, 200, 20)
res <- rep.sim(d, 10)
boxplot(res, names = d, xlab = "farmers", ylab = "fires")

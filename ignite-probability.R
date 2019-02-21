nl.path <- "C:\\Program Files\\NetLogo 6.0\\app\\"
Sys.setenv(JAVA_HOME = "C:\\Program Files\\NetLogo 6.0\\runtime")
library(RNetLogo)
NLStart(nl.path, nl.jarname = "netlogo-6.0.0.jar", gui = FALSE)

model.path <- "C:\\Users\\I5\\Dropbox\\KLN_2017\\rebuild model wildfire\\peatfire-v10-TEST-R\\peatfire-model-v10\\rebuild-model-wildfire-v10-R-EXP1.nlogo"
NLLoadModel(model.path)

sim <- function(igniteprob) {
  NLCommand("set ignite-probability ", igniteprob, "setup")
  NLDoCommand(365, "go")
  ret <- NLReport("total-fire")
  return(ret)
}

d <- seq(0.1, 1, 0.1)
pb <- sapply(d, function(evap) sim(evap))
plot(d, pb, xlab = "ignition-probability", ylab = "fires")

rep.sim <- function(igniteprob, rep)
  lapply(igniteprob, function(evap) replicate(rep, sim(evap)))

d <- seq(0.1, 1, 0.1)
res <- rep.sim(d, 10)
boxplot(res, names = d, xlab = "ignition-probability", ylab = "fires")

NLQuit()

nl.path <- "C:\\Program Files\\NetLogo 6.0.1\\app\\"
Sys.setenv(JAVA_HOME = "C:\\Program Files\\NetLogo 6.0.1\\runtime")
library(RNetLogo)
NLStart(nl.path, nl.jarname = "netlogo-6.0.1.jar")
#model.path <- "F:\\Ising.nlogo"

model.path <- "F:\\peatfire-model-v10test-R\\peatfire-model-v10\\rebuild-model-wildfire-v10-R-EXP1.nlogo"
NLLoadModel(model.path)

sim <- function(mindrydays) {
  NLCommand("set mindays-decide-ignite ", mindrydays, "setup")
  NLDoCommand(365, "go")
  ret <- NLReport("total-fire")
  return(ret)
}

d <- seq(1, 10, 1)
pb <- sapply(d, function(dryt) sim(dryt))
plot(d, pb, xlab = "dry-days-before-ignite", ylab = "fires")

rep.sim <- function(evapotranspiration, rep)
  lapply(evapotranspiration, function(evap) replicate(rep, sim(evap)))

d <- seq(0.003, 0.005, 0.0002)
res <- rep.sim(d, 10)
boxplot(res, names = d, xlab = "evapotranspiration", ylab = "fires")

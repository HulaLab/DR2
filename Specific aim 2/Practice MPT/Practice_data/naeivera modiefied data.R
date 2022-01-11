data <- read_excel("~/GitHub/DR2/Specific aim 2/Practice MPT/naveirmd_start_table.xlsx")
data= read_excel("~/GitHub/DR2/Specific aim 2/Practice MPT/naveirmd_start_table.xlsx")

number.of.nodes <- 2
for (node in 1:number.of.nodes){
  data.copy <- data
  data.copy$node <- rep(node, nrow(data))
  if (node==1){data.node <- data.copy} else {data.node <- rbind(data.node,data.copy)}
}

yy.list <- list(list(1,1,0),list(1,0,NA))

for (observation in 1:nrow(data.node)){
  data.node$yy[observation] <- yy.list[[data.node$node[observation]]][[data.node$y[observation]]]
}

data.el <- data.node[,c(1,3,4,8,9)]
names(data.el) <- variable.names <- names(data.node[,c(1,3,4,8,9)])
head(data.el)


data.el = data.frame(
  trial = data.node$trial,
  person = data.node$person,
  
  
)
unique.trial <- sort(unique(data.el$trial))
unique.time <- sort(unique(data.el$time))
unique.node <- sort(unique(data.el$node))



number.variables <- 3

Empirical.Logit <- matrix(nrow=prod(length(unique.trial),length(unique.time),
                                    length(unique.node)), ncol = (number.variables + 1))

row.index <- 1

for (trial in 1:length(unique.trial)){
  for (time in 1:length(unique.time)){
    for (node in 1:length(unique.node)){
      
      data.el.trial.time.node <- data.el[(data.el$trial==unique.trial[trial] 
                                          & data.el$time==unique.time[time] & data.el$node==unique.node[node]),]
      yy.trial.time.node <- data.el.trial.time.node$yy
      proportion <- sum(yy.trial.time.node[!is.na(yy.trial.time.node)])/length(yy.trial.time.node)
      empirical.logit <- log(proportion/(1 - proportion))
      Empirical.Logit[row.index,] <- c(unique.trial[trial], unique.time[time], 
                                       unique.node[node], empirical.logit)
      row.index <- row.index + 1
    }}}

Empirical.Logit <- data.frame(Empirical.Logit)
names(Empirical.Logit) <- c("trial", "time", "node", "empirical.logit")
Empirical.Logit$empirical.logit[Empirical.Logit$empirical.logit < -10^6] <- -10^6
Empirical.Logit$empirical.logit[Empirical.Logit$empirical.logit > 10^6] <- 10^6
data.el$trial = data.node$trial

Emp2= data.el %>%
  count(trial, time, yy, node, person) %>%
  na.omit() %>%
  group_by(trial) %>%
  mutate(n_obs = n()) %>%
  ungroup() %>%
  group_by(node, yy) %>%
  mutate(n_yy = n()) %>%
  mutate(prop_yy = n_yy/n_obs)

Empirical.Logit = data.frame(
  person = EL2$person,
  trial = EL2$trial,
  time = EL2$time,
  node = EL2$node,
  empirical.logit = (EL2$prop_yy) / (EL2$n_obs - EL2$n_yy))


time.lag.max <- 20
AC.PAC <- matrix(nrow=prod(length(unique.trial),length(unique.node),time.lag.max), 
                 ncol=(number.variables + 2))

row.index <- 1

for (trial in 1:length(unique.trial)){
  for (node in 1:length(unique.node)){
    
    Empirical.Logit.trial.node <- Empirical.Logit[(Empirical.Logit$trial==unique.trial[trial] 
                                                   & Empirical.Logit$node==unique.node[node]),]
    autocorrelations <- acf(Empirical.Logit.trial.node$empirical.logit, 
                            lag.max = time.lag.max, plot=FALSE)
    autocorrelations <- autocorrelations$acf[2:(time.lag.max + 1)]
    partial.autocorrelations <- pacf(Empirical.Logit.trial.node$empirical.logit, 
                                     lag.max = time.lag.max, na.action=na.pass, plot=FALSE)
    partial.autocorrelations <- c(partial.autocorrelations$acf)
    for (time.lag in 1:time.lag.max){
      AC.PAC[(row.index + time.lag - 1),] <- c(unique.trial[trial], unique.node[node], time.lag, 
                                               autocorrelations[time.lag], partial.autocorrelations[time.lag])
    }
    row.index <- row.index + time.lag.max
  }}

AC.PAC <- data.frame(AC.PAC)
names(AC.PAC) <- c("trial", "node", "time.lag", "autocorrelation", "partial.autocorrelation")


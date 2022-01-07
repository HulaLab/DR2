data = naveirmd_start_table


number.of.nodes <- 2
for (node in 1:number.of.nodes){
  data.copy <- data
  data.copy$node <- rep(node, nrow(data))
  if (node==1){data.node <- data.copy} else {data.node <- rbind(data.node,data.copy)}
}



yy.list <- list(list(1,1,0),list(1,0,NA)) #two elements with 1 1 0 1 0 na


#node tells what list to pull from and y says which element in the list
for (observation in 1:nrow(data.node)){
  data.node$yy[observation] <- yy.list[[data.node$node[observation]]][[data.node$y[observation]]]
}

data.el <- data.node[,c(1,3,4,8,9)]
names(data.el) <- variable.names <- names(data.node[,c(1,3,4,8,9)])
head(data.el)

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
library(readr)
#to manipulate data, dplyr, purr, etc and to plot w ggplot2
library(dplyr)
#Bayesian multilevel models
library(brms)
library(cmdstanr)
#pretty plots
#library(stargazer)
#intepretation and plotting
#library(tidybayes)

#load formatted data
d = read_csv("analysisDf.csv") 
d$yy.lag <- as.numeric(d$yy.lag)
d$t.lag <- as.numeric(d$t.lag)
d$c.lag <- as.numeric(d$c.lag)
d$time.coded <- as.numeric(d$BIN_START_TIME)
d$time.coded.centered <- as.numeric(d$time.coded.center)
d$item <- as.factor(d$item)
d$person <- as.factor(d$id)
d$trial <- as.factor(d$TRIAL_INDEX)
d$node <- as.factor(d$node)
d$node.1 <- as.factor(d$node.1)
d$node.2 <- as.factor(d$node.2)
d$node.3 <- as.factor(d$node.3)
d$obs <- seq(1,nrow(d))

#remove node 2 and 3 (doesnt matter what node is actually removed, just dont want triplicated data)
d2 = d %>%
  filter(node  == 1)

#Create outcome variables
d2$correct = ifelse(d2$y == 1, 1, 0)
d2$unrelated = ifelse(d2$y == 2, 1, 0)
d2$phonological = ifelse(d2$y == 4, 1, 0)
d2$semantic = ifelse(d2$y == 3,1,0)

#create trial level variable for bin number
d3 = d2 %>%
  mutate(sum_var = rep(1, nrow(d2)))


d3 = d3 %>%
  group_by(item, person, Session) %>%
  mutate(n_bins = sum(sum_var)) %>%
  mutate(n_cor = sum(correct)) %>%
  mutate(n_phon = sum(phonological)) %>%
  mutate(n_sem = sum(semantic)) %>%
  mutate(n_unrel = sum(unrelated)) %>%
  mutate(pctCor = n_cor/n_bins) %>%
  mutate(pctPhon = n_phon/n_bins) %>%
  mutate(pctSem = n_sem/n_bins) %>%
  mutate(pctUnrel = n_unrel/n_bins) %>%
  mutate(time = time.coded/50)

d3$Session = as.factor(d3$Session)
s1 = d3 %>%
  filter(Session == 1)
length(unique(s1$person))
s2 = d3 %>%
  filter(Session == 2)
length(unique(s1$person))
unique(d3$person)

#one observation per time point
final_df = s2 %>%
  distinct(person, item, .keep_all = TRUE)
zoib_correct = bf(pctCor ~ aud_syn + aud_rhyme + 
                     (1|person) + (1|item),
                     phi ~ aud_syn + aud_rhyme +  
                       (1|person) + (1|item),
                     zoi ~ aud_syn + aud_rhyme +  
                       (1|person) + (1|item),
                     coi ~ aud_syn + aud_rhyme +  
                       (1|person) + (1|item))
 
 zoib_semantic = bf(pctSem ~ aud_syn + aud_rhyme + 
                      (1|person) + (1|item),
                    phi ~ aud_syn + aud_rhyme +  
                      (1|person) + (1|item),
                    zoi ~ aud_syn + aud_rhyme +  
                      (1|person) + (1|item),
                    coi ~ aud_syn + aud_rhyme +  
                      (1|person) + (1|item))
 
 zoib_phonological= bf(pctPhon ~ aud_syn + aud_rhyme + 
                         (1|person) + (1|item),
                       phi ~ aud_syn + aud_rhyme +  
                         (1|person) + (1|item),
                       zoi ~ aud_syn + aud_rhyme +  
                         (1|person) + (1|item),
                       coi ~ aud_syn + aud_rhyme +  
                         (1|person) + (1|item))
 
 zoib_unrelated = bf(pctUnrel ~ aud_syn + aud_rhyme + 
                         (1|person) + (1|item),
                       phi ~ aud_syn + aud_rhyme +  
                         (1|person) + (1|item),
                       zoi ~ aud_syn + aud_rhyme +  
                         (1|person) + (1|item),
                       coi ~ aud_syn + aud_rhyme +  
                         (1|person) + (1|item))
 
#assign priors
 priors <- c(set_prior("normal(0, 2.5)",
                        class = "b",
                        resp = c("pctCor","pctPhon","pctUnrel", "pctSem")),
              set_prior("normal(0,10)",
                        class = "Intercept",
                        resp = c("pctCor","pctPhon","pctUnrel", "pctSem")),
              set_prior("normal(0,5)",
                        class = "sd",
                        resp = c("pctCor","pctPhon","pctUnrel", "pctSem")))
              
endtime = timestamp()            
mv_zoib <- brm(zoib_correct + zoib_phonological + zoib_semantic + zoib_unrelated,
                      family = zero_one_inflated_beta(),
                      data = final_df,
                      init = "0",
                      prior = priors,
                      cores = 4,
                      control = list(adapt_delta = 0.91,
                              max_treedepth = 11),
                      threads = threading(12),
                      iter = 2000,
                      chains = 12,
                      seed = 1,
                      backend = "cmdstanr")

save(mv_zoib, file = "mv_zoib.rda")
summary(mv_zoib)
endtime = timestamp()
 

df2 = df %>%
  rename(aoi1 = RIGHT_IA_1_SAMPLE_COUNT) %>%
  rename(aoi2 = RIGHT_IA_2_SAMPLE_COUNT) %>%
  rename(aoi3 = RIGHT_IA_3_SAMPLE_COUNT) %>%
  rename(aoi4 = RIGHT_IA_4_SAMPLE_COUNT)

#Following schmit et al, change all values below 5ms to 0 and above to 10 (pg 14, table expalnation.
df2$aoi1 = ifelse(df2$aoi1 < 5, 10, 0)
df2$aoi2 = ifelse(df2$aoi2 < 5, 10, 0)
df2$aoi3 = ifelse(df2$aoi3 < 5, 10, 0)
df2$aoi4 = ifelse(df2$aoi4  < 5, 10, 0)

#create single column showing what aoi participant was looking at
df2$aoi_all = ifelse(df2$aoi1 > 0, 1,
                     ifelse(df2$aoi2 > 0, 2, 
                            ifelse(df2$aoi3 > 0, 3,
                                   ifelse(df2$aoi4 > 0,4, 0))))

df2$y_5 = ifelse(df2$aoi_all == df2$unrelated_location, 2,
                 ifelse(df2$aoi_all == df2$phonemic_location, 4,
                        ifelse(df2$aoi_all == df2$semantic_location, 3,
                               ifelse(df2$aoi_all == df2$target_location, 1, 0)))) 
# yy.list is the hierachical structure of available steps in the tree model. 

library(tidyr)

df2 = df2 %>%
  mutate(y =  na_if(y_5, 0)) %>% 
  fill(y, .direction = "up")

df3 = data.frame(  
  trial = df2$TRIAL_INDEX,
  person = rep(2, nrow(df2)),
  time = df2$BIN_START_TIME,
  item = df2$targetword,
  y = df2$y
)



number.of.nodes <- 3
for (node in 1:number.of.nodes){
  data.copy <- df3
  data.copy$node <- rep(node, nrow(df3))
  if (node==1){data.node <- data.copy} else {data.node <- rbind(data.node,data.copy)}
}
#Sanity check make sure we did the missing data transformation correct
#does step 1 result in missing data in the form of numerical value 0? (yes)
unique(df2$aoi_all)
#Does step 2 result in missing data in the form of numerical value 0? (yes)
unique(df2$y_5)
#does step 3 remove na in the form of zero and replace with nedxt highest number in teh sequence? (yes)
NA_check = data.frame(df2$y_5, df3$y)

#Duplicate data for the number of nodes

number.of.nodes <- 3
for (node in 1:number.of.nodes){
  data.copy <- df3
  data.copy$node <- rep(node, nrow(df3))
  if (node==1){data.node <- data.copy} else {data.node <- rbind(data.node,data.copy)}
}

#phonological = 4
#semantic = 3
#unrelated = 2
#Correct = 1


data.node$yy = ifelse(data.node$node== 1 & data.node$y < 4, 1,  #node 1 and correct (sem, unrelated, correct) 
                      ifelse(data.node$node== 1 & data.node$y == 4, 0, #node 1 and phon distractor
                             ifelse(data.node$node== 2 & data.node$y == 4, NA, #node 2 and phonological comp
                             ifelse(data.node$node== 2 & data.node$y == 3, 0, #node 2 and phonological comp
                             ifelse(data.node$node== 2 & data.node$y < 3, 1,  #node 2 and unrelated or correct
                             ifelse(data.node$node== 3 & data.node$y > 2, NA, #node 3 and y = phonological or semantic competitor
                             ifelse(data.node$node== 3 & data.node$y == 2, 0, 1 #node 3 and unrelated competitor, if not unrelated then correct
                             )))))))
unique(data.node$yy)
#Remove y = 4 for node 2 as this value is not possible in the tree
if (length(which(data.node$node==2 & data.node$y==4))>0){
  data.node <- data.node[-which(data.node$node==2 & data.node$y==4),]
}
#Remove y = 3 or 4 for node 3
if (length(which(data.node$node==3 & data.node$y>2.1))>0){
  data.node <- data.node[-which(data.node$node==3 & data.node$y>2.1),]
}

#Test, node 2 has no y = 4, true
test_node_2 = data.node %>%
  filter(node == 2) %>%
  filter(y ==4)

#Test, node 3 has no y = 3 or 4
test_node_3 = data.node %>%
  filter(node == 2) %>%
  filter(y > 2.1)



data.node.original <- data.node <- data.node[order(data.node$node, data.node$person, data.node$trial, data.node$time),]
data.node <- data.node[order(data.node$node, data.node$person, data.node$trial, data.node$time),]

#create variables to use later
data.node$time.coded <-  data.node$time.coded.centered <- rep(0,nrow(data.node))



#At node 1, if the participant is looking at phonological comeptitor 0 anything else down the tree, 1
data.node$node.1 = ifelse(data.node$y == 4, 0, 1)
#At node 2, if the participant is looking at semantic competitor or phonological, 0 anything else 1
data.node$node.2 = ifelse(data.node$y > 3, 0, 1)
#At node 3, if the participant is looking at correct, 1 anything else 0
data.node$node.3 = ifelse(data.node$y == 2, 0, 1)


unique.person <- sort(unique(data.node$person))
unique.trial <- sort(unique(data.node$trial))
deviation.coding <- c(-1,1)

number.nodes = 3

  
#create variable t and c
#Not the most elegant way to do this,but it works. 
#Split data into 3 dataframes for node = 1, 2, and 3 then estimate values then combine data frames back together
node1_df = data.node %>%
  filter(node == 1)
node1_df$t = ifelse(node1_df$y != 4, 1,0)
node1_df$c = ifelse(node1_df$y !=1,1,0)

node2_df = data.node %>%
  filter(node == 2)
node2_df$t = ifelse(node2_df$y == !3, 1,0)
node2_df$c = ifelse(node2_df$y !=1,1,0)

node3_df = data.node %>%
  filter(node == 3)
node3_df$t = ifelse(node3_df$y == 1, 1,0)
node3_df$c = ifelse(node3_df$y !=1, 1,0)

data.node = rbind(node1_df, node2_df, node3_df)
unique(data.node$node)

#unique(data.node$yy)
#Create lag variables
data.node = data.node %>%
  arrange(node) %>%
  group_by(node, person, item) %>%
  mutate(t.lag = lag(t)) %>%
  mutate(c.lag = lag(c)) %>%
  mutate(yy.lag = lag(yy))%>%
  group_by() %>%
  mutate(time.coded.center = scale(time)) %>%
  filter(!is.na(t.lag))

summary(data.node)

unique(data.node$node)
df.na = data.node %>%
  filter(is.na(t.lag))



#unique(data.node$yy)
#Remove remove the initial values for time (of which the lag variables are undefined) for each combination of node, person, and trial, after adding our yy.lag variable
for (node in 1:number.nodes){
  for (person in 1:length(unique.person)){
    for (trial in 1:length(unique.trial)){
      match <- which(data.node$node==node & data.node$person==unique.person[person] 
                     & data.node$trial==unique.trial[trial])
      if (length(match)>0){
        time.data <- data.node$time[match]
        start.time <- min(time.data)
        start.time.index <- match[which(time.data==start.time)]
        data.node <- data.node[-start.time.index,]
      }}}}
#unique(data.node$yy)
#Add time.coded centered variable
for (node in 1:number.nodes){
  for (person in 1:length(unique.person)){
    for (trial in 1:length(unique.trial)){
      match <- which(data.node$node==node & data.node$person==unique.person[person] 
                     & data.node$trial==unique.trial[trial])
      if (length(match)>0){
        time.coded.data <- data.node$time.coded[match]
        data.node$time.coded.centered[match] <- time.coded.data - mean(time.coded.data)
      }}}}
unique(data.node$yy)

#create correct variable structures 
data.node$yy.lag <- as.numeric(data.node$yy.lag)
data.node$t.lag <- as.numeric(data.node$t.lag)
data.node$c.lag <- as.numeric(data.node$c.lag)
data.node$time.coded <- as.numeric(data.node$time.coded)
data.node$time.coded.centered <- as.numeric(data.node$time.coded.centered)
data.node$item <- as.factor(data.node$item)
data.node$person <- as.factor(data.node$person)
data.node$trial <- as.factor(data.node$trial)
data.node$node <- as.factor(data.node$node)
data.node$node.1 <- as.factor(data.node$node.1)
data.node$node.2 <- as.factor(data.node$node.2)
data.node$node.3 <- as.factor(data.node$node.3)
data.node$obs <- seq(1,nrow(data.node))


library(lme4)

model.glm = glm(yy ~ -1 + node *t.lag + node*c.lag + time.coded.centered*node,
family = binomial, 
data = data.node)
summary(model.glm)


test_sing = data.node %>%
  filter(node == 2)

Model.1 <- glmer(yy ~ -1 + node*t.lag + node*c.lag + time.coded.centered*node + (1|node), family = binomial, data = data.node)
library(brms)
BRM1 = brm(yy ~ -1 + node*t.lag + node*c.lag + time.coded.centered*node + (1|node),
           family = binomial, 
           data = data.node)

unique(data.node$time.coded.center)
summary(Model.1)

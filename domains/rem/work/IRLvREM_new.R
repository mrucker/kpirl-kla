# Two tales of one city: an IRL approach to REM
# Peter Wu
#install.packages("informR")
library(statnet)
library(informR)
library(relevent)
library(dplyr)

setwd("C:/Users/Peter/Downloads/PROJECT_IRLvREM_2018/try_rem_newtake")
load("../relevent_sunbelt_2014.Rdata") 

head(WTCPoliceCalls)
dim(WTCPoliceCalls)

max(WTCPoliceCalls$source)
max(WTCPoliceCalls$recipient) # 37 nodes in total
nrow(WTCPoliceCalls) # 481 events recorded

# sample a state 
max.length <- 40
state.length <- sample(1:max.length, 1)
state.sampled <- sample(1:37, 2)
for (i in 1:(state.length-1)) {
  state.sampled <- c(state.sampled, sample(1:37,2))  
}

# sample an action 
action.sampled <- sample(1:37, 2)

# transition_function(state, action)
transition_function <- function(s, a) {
  if((length(s) + length(action.sampled))/2 < max.length) { #length(action.sampled) is always 2
    s.prime <- c(s, a)
  }else{
    s.prime <- c(s[(length(s)-2*(max.length-1)+1):length(s)], a)
  }
  return(s.prime)
}

state.to <- transition_function(s = state.sampled, a = action.sampled)
state.to

# four features:
# transitivity (PSAB-BY)
# popularity (NTDegRec)
# reciprocity (PSAB-BA)
# inertia (FrPSndSnd)
get_reward_features <- function(s) {
  l <- length(s)
  transitivity <- ifelse(s[l-2] == s[l-1] & s[l] != s[l-3], 1, 0)
  popularity <- length(which(s[1:(l-2)] == s[l]))/(2*(l-2))
  reciprocity <- ifelse(s[l-2] == s[l-1] & s[l] == s[l-3], 1, 0)
  inertia <- ifelse(length(which(s[seq(1,(l-2),2)] == s[l-1])) > 0, 
             length(which(s[seq(2,(l-2),2)][which(s[seq(1,(l-2),2)] == s[l-1])] == s[l]))/
             length(which(s[seq(1,(l-2),2)] == s[l-1])),0)
  features <- c(transitivity, popularity, reciprocity, inertia)
  return(features)
}

get_reward_features(s = state.sampled)
get_reward_features(s = state.to)

# generate whole trajectory
whole.trajectory <- rep(NA, nrow(WTCPoliceCalls)*2)
whole.trajectory[seq(1, length(whole.trajectory), 2)] <- WTCPoliceCalls$source
whole.trajectory[seq(2, length(whole.trajectory), 2)] <- WTCPoliceCalls$recipient
whole.trajectory

trajectory.matrix <- matrix(rep("", nrow(WTCPoliceCalls)*nrow(WTCPoliceCalls)*2), 
                               nrow = nrow(WTCPoliceCalls)*2, 
                               ncol = nrow(WTCPoliceCalls))

for (i in 1:nrow(WTCPoliceCalls)) {
  trajectory.matrix[1:(i*2),i] <- whole.trajectory[1:(i*2)]  
}
write.csv(trajectory.matrix, "trajectory.matrix.csv", row.names = F)

# plug in real data
row <- sample(5:nrow(WTCPoliceCalls), 1)
max.length <- nrow(WTCPoliceCalls)

state.from <- as.numeric(unlist(WTCPoliceCalls[1:row,c("source","recipient")]))
#names(state.from) <- NULL
state.from <- state.from[max(1,length(state.from)-2*(max.length-1)+1):length(state.from)]
state.from

state.to <- transition_function(state.from, a = as.numeric(WTCPoliceCalls[row+1, c("source","recipient")]))
state.to

reward <- get_reward_features(state.to)
reward

# fit rem model
wtcfit<-rem.dyad(WTCPoliceCalls, n=37,
                  effects=c("PSAB-BY","NTDegRec", "PSAB-BA", "FrPSndSnd"),
                 #covar=list(CovInt=WTCPoliceIsICR),
                 hessian=TRUE)
summary(wtcfit)



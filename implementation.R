
{

options(warn=-1)
library(visNetwork)

library(DiagrammeR)
library(data.table)
library(dplyr)
library(caret)
library(stringr)

setwd("~/Alignment/util")
source('vTrees.R')
source('vForest.R')

setwd("~/Alignment/normaldata")
test =  read.csv("hospital_billing.csv",T)
head(test)
names(test)[2:3] = c('Case.ID', 'Activity') #for hospital_billing data
# names(test)[1:2] = c('Case.ID', 'Activity') #for Road_Traffic.csv data , B12

setwd("~/Alignment/preprocessed")
dat = read.csv("recon_hospital_billing.csv",T)


{# Preprocessing for clean traces

  names(dat)[which(names(dat)=="resource_anomaly_type")] ="label"
  dat = dat[order(dat$Case),]
  dat$order = ave(rep(1, nrow(dat)), by= dat$Case, FUN= cumsum)
  dat_sub = unique(dat[,c("Case","label", "loc", "len")])
  dat_sub_start = dat_sub
  dat_sub_end = dat_sub
  dat_sub_start$Activity = "Start"
  dat_sub_end$Activity = "End"
  
  dat_sub_start$Timestamp = aggregate(dat$Timestamp , by= list(dat$Case), FUN= function(x){x[1]})[,2]
  dat_sub_end$Timestamp = aggregate(dat$Timestamp , by= list(dat$Case), FUN= function(x){x[length(x)]})[,2]
  dat_sub_start$order = 0
  dat_sub_end$order = aggregate(dat$Activity , by= list(dat$Case), FUN= function(x){length(x)+1 })[,2]
  
  dat_sub_start = dat_sub_start[,names(dat)]
  dat_sub_end = dat_sub_end[,names(dat)]
  
  dat= rbind(dat, dat_sub_start , dat_sub_end)
  dat$order = dat$order +1
  dat = dat[order(dat$Case,dat$order),]
  dat= dat[,c("Case", "Activity", "order", "label")]
  dat$Case = as.factor(dat$Case)
  
  dat_save = dat
  dat = dat[which(dat$label=='normal'),]  
  
  trace_v2 = aggregate(dat$Activity, by=list(dat$Case), FUN=function(x){paste(x, collapse = '>')})

  variant_count = table(trace_v2[,2])
  variant_length=  str_count(names(variant_count), pattern = '>')+1
  
  v_id = paste( "v_", 1:length(variant_length) ,sep='')
  v_id = as.vector(rep(v_id, variant_length))
  trace_freq = as.numeric(rep(unlist(variant_count), variant_length))
  one = rep(1, length(v_id))
  cumone = ave(one, v_id , FUN=cumsum)
  variant_frame = data.frame(cbind(v_id,  Activity=unlist(strsplit(names(variant_count), split='>')), order=cumone ,trace_freq = as.numeric(trace_freq) ))
}


{# Preprocessing for anomalous traces
  anomaly = dat_save[which(is.element(dat_save$label, c("replace","moved","rework","insert","skip"))),]
  j1= (aggregate(anomaly$Activity, by=list(anomaly$Case), FUN=paste0))
  j2= (aggregate(dat$Activity, by=list(dat$Case), FUN=paste0))
  dupl = j1[which(is.element(j1[,2], j2[,2])),1]
  anomaly= anomaly[which(!is.element(anomaly$Case, dupl)),]
  anomaly.c = unique(anomaly$Case)
  
  anomaly2 = dat_save[which(is.element(dat_save$Case, anomaly.c)),]
  
  one = rep(1, nrow(anomaly2))
  cumone = ave(one, by= as.factor(anomaly2[,1]), FUN= cumsum)
  dat2 = data.frame(anomaly2[1:(nrow(anomaly2)-1),1],anomaly2[1:(nrow(anomaly2)-1),3],
                      anomaly2[1:(nrow(anomaly2)-1),2], anomaly2[2:nrow(anomaly2),2])
  del = cumone[1:(nrow(anomaly2)-1)] - cumone[2:nrow(anomaly2)]
  dat2 = dat2[which(del<0),]
  names(dat2) = c('Case', 'level', 'label', 'label2')
}


start = Sys.time()

print('Start to train vTrees')
{#Develop Tree in each activity perspective  
  vTrees = func.vTrees(dat)
  actset = vTrees[[1]]
  model.nodes = vTrees[[2]]
  model.edges = vTrees[[3]]
  base.list = vTrees[[4]]
}



print('Start to repair logs by vForest')
{#Implement Reconstruction
  input = anomaly[,1:3]
  input_trace = aggregate(input$Activity, by=list(input$Case), FUN=function(x){paste(x, collapse = '>')})
  non_dupli_case = input_trace$Group.1[which(!duplicated(input_trace$x))]
  dupli_case = input_trace$Group.1[which(duplicated(input_trace$x))]
  dupli_trace = input_trace$x[which(duplicated(input_trace$x))]
  
  match = input_trace$Group.1[sapply(dupli_trace,FUN= function(x){which(x == input_trace$x)[1]})]
  dupli.df = data.frame('anomaly' = dupli_case, 'Case' = match )
  input2 = input[which(is.element(input$Case, non_dupli_case)),]
  dat3 = dat2[which(is.element( dat2$Case, non_dupli_case)),]
  reconst2 = vForest(input2, dat, dat3, variant_frame)
}

reconst3 = reconst2
for(i in 1:nrow(dupli.df)){
  l = reconst2[[which(dupli.df[i,2]== non_dupli_case )]]
  l[[1]]$Case =dupli.df[i,1]
  reconst3 = append(list(l),reconst3 )
}


reconst_final = rbindlist(lapply(reconst3, '[[', 1) )

end = Sys.time()
print(end-start)


pred = unlist(lapply(reconst3, '[[', 2) )
pred.c =  unlist(lapply(lapply(reconst3, '[[',1), FUN= function(x){unique(as.character(x$Case)) } ))

ref = unique(anomaly[,c(1,4)])[,2]
ref.c = unique(anomaly[,c(1,4)])[,1]
pred = pred[order(pred.c, ref.c)]

if(is.element('normal', pred)){
  ref2= as.factor(ref)
  levels(ref2)[length(levels(ref2))+1] = 'normal'
  print(confusionMatrix( as.factor(pred), as.factor(ref2)))
}else{
  print(confusionMatrix( as.factor(pred), as.factor(ref)))
}



###########


repaired = reconst_final[-which(reconst_final$Activity=='Start' | reconst_final$Activity=='End'),]
test = test[which(is.element(test$Case.ID, repaired$Case)),]

x = aggregate(repaired$Activity , by= list(repaired$Case), FUN= function(x){paste(x, collapse = '-')})
y = aggregate(test$Activity , by= list(test$Case.ID), FUN= function(x){paste(x, collapse = '-')})

sum(as.character(x$Group.1)!=as.character(y$Group.1))

see3= unique(anomaly[,c(1,4)])
accuracy =1- sum(as.character(x$x)!=as.character(y$x))/nrow(x)
loc_skip = which(is.element(y$Group.1,see3[which(see3$label=='skip'),'Case'] ))
accuracy_skip =1- sum( (as.character(x$x)!=as.character(y$x))[loc_skip] )/length(loc_skip)
loc_insert = which(is.element(y$Group.1,see3[which(see3$label=='insert'),'Case'] ))
accuracy_insert =1- sum( (as.character(x$x)!=as.character(y$x))[loc_insert] )/length(loc_insert)
loc_moved = which(is.element(y$Group.1,see3[which(see3$label=='moved'),'Case'] ))
accuracy_moved =1- sum( (as.character(x$x)!=as.character(y$x))[loc_moved] )/length(loc_moved)
loc_rework = which(is.element(y$Group.1,see3[which(see3$label=='rework'),'Case'] ))
accuracy_rework =1- sum( (as.character(x$x)!=as.character(y$x))[loc_rework] )/length(loc_rework)
loc_replace = which(is.element(y$Group.1,see3[which(see3$label=='replace'),'Case'] ))
accuracy_replace =1- sum( (as.character(x$x)!=as.character(y$x))[loc_replace] )/length(loc_replace)


print(  paste("Reconstuction accuracy = ", ceiling(accuracy*10000)/10000, sep='') )
print(  paste("Reconstuction accuracy.skip = ", ceiling(accuracy_skip*10000)/10000, sep='') )
print(  paste("Reconstuction accuracy.insert = ", ceiling(accuracy_insert*10000)/10000, sep='') )
print(  paste("Reconstuction accuracy.moved = ", ceiling(accuracy_moved*10000)/10000, sep='') )
print(  paste("Reconstuction accuracy.rework = ", ceiling(accuracy_rework*10000)/10000, sep='') )
print(  paste("Reconstuction accuracy.replace = ", ceiling(accuracy_replace*10000)/10000, sep='') )




library(stringdist)
z = anomaly[-which(anomaly$Activity=='Start' | anomaly$Activity=='End'),]


x.act = repaired$Activity
y.act = test$Activity
z.act = z$Activity

act.list = unique( c(x.act,y.act,z.act) )
letter.list = c(letters, LETTERS, 1:9)

if(length(act.list) > length(letter.list)){
  print("Over size problem: act.length > letters ")
}


x.act = apply( data.frame(x.act), 1, FUN= function(x){ letter.list[which(act.list==x)]} )  
y.act = apply( data.frame(y.act), 1, FUN= function(x){ letter.list[which(act.list==x)]} )  
z.act = apply( data.frame(z.act), 1, FUN= function(x){ letter.list[which(act.list==x)]} )  


str.x = aggregate(x.act , by= list(repaired$Case), FUN= function(x){paste(x, collapse = '')})
str.y = aggregate(y.act , by= list(test$Case.ID), FUN= function(x){paste(x, collapse = '')})
str.z = aggregate(z.act , by= list(z$Case), FUN= function(x){paste(x, collapse = '')})


print( paste( "edit dist(before) = " ,mean(stringdist(str.z$x, str.y$x)) , collapse = '') ) # error by edit distant (Levenshtein dist)
print( paste( "edit dist(after) = " ,mean(stringdist(str.x$x, str.y$x)) , collapse = '') ) # error by edit distant (Levenshtein dist)


}

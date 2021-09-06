setwd("~/anomalydata")

dat =read.csv("Wide_with_anomalies.csv",T)


# dat = dat[,c("Case", "Event", "Activity", "Timestamp",
#              "Resource_Anomaly.Normal", "order", "resource_anomaly_type", "resource_parameter",
#              "is_trace_anomalous.resource.")]


dat = dat[,c("Case", "Event", "Activity", "Timestamp",
             "Resource_Anomaly.Normal", "order", "resource_anomaly_type", "resource_parameter",
             "is_trace_anomalous.resource.")]

ss = function(x){
  as.numeric(strsplit(strsplit(x , split=',')[[1]][1],
                      split='= ')[[1]][2])
}

ss2 = function(x){
  as.numeric(strsplit(strsplit(x , split=',')[[1]][2],
                      split='= ')[[1]][2]) 
}

dat_skip = dat[ which(dat$resource_anomaly_type=="skip"), ]
dat_skip$resource_parameter = as.character(dat_skip$resource_parameter)
dat_skip['loc'] = unlist(lapply(dat_skip$resource_parameter, FUN = ss))
dat_skip['len'] = unlist(lapply(dat_skip$resource_parameter, FUN = ss2))

dat_insert = dat[ which(dat$resource_anomaly_type=="insert"), ]
dat_insert$resource_parameter = as.character(dat_insert$resource_parameter)
dat_insert['loc'] = unlist(lapply(dat_insert$resource_parameter, FUN = ss))+1
dat_insert['len'] = unlist(lapply(dat_insert$resource_parameter, FUN = ss2))

dat_replace = dat[ which(dat$resource_anomaly_type=="replace"), ]
dat_replace$resource_parameter = as.character(dat_replace$resource_parameter)
dat_replace['loc'] = unlist(lapply(dat_replace$resource_parameter, FUN = ss))
dat_replace['len'] = unlist(lapply(dat_replace$resource_parameter, FUN = ss2))

dat_rework= dat[ which(dat$resource_anomaly_type=="rework"), ]
dat_rework$resource_parameter = as.character(dat_rework$resource_parameter)
dat_rework['loc'] = unlist(lapply(dat_rework$resource_parameter, FUN = ss))+1
dat_rework['len'] = unlist(lapply(dat_rework$resource_parameter, FUN = ss2))

dat_moved= dat[ which(dat$resource_anomaly_type=="moved"), ]
dat_moved$resource_parameter = as.character(dat_moved$resource_parameter)
dat_moved['loc'] = ave(dat_moved$Resource_Anomaly.Normal, by= as.character(dat_moved$Case), FUN=function(x){
  which(x==1)})

dat_moved2 = dat_moved 
du = as.numeric(unlist(lapply(dat_moved2[which(dat_moved2$Resource_Anomaly.Normal ==1),'resource_parameter'], FUN = ss2)))

dat_moved2$unixtime = as.numeric(as.POSIXct(dat_moved2[,'Timestamp']))

dat_moved2[which(dat_moved2$Resource_Anomaly.Normal ==1),'unixtime'] =
  dat_moved2[which(dat_moved2$Resource_Anomaly.Normal ==1),'unixtime'] - du
dat_moved2= dat_moved2[order(dat_moved2$Case, dat_moved2$unixtime),]
a= rep(1, nrow(dat_moved2))
dat_moved2['len'] = ave(dat_moved2$Resource_Anomaly.Normal, by= as.character(dat_moved2$Case), FUN=function(x){
  which(x==1)})
dat_moved2 = dat_moved2[,-which(names(dat_moved2) =='unixtime')]
dat_moved['len'] = dat_moved2['len']


dat_normal= dat[ which(dat$resource_anomaly_type=="normal"), ]
dat_normal['loc'] = rep(0,nrow(dat_normal))
dat_normal['len'] = rep(0,nrow(dat_normal))

dat2 = rbind(dat_skip, dat_insert, dat_replace, dat_rework, dat_moved)
dat2 = dat2[which(dat2$is_trace_anomalous.resource. == 1 ), ]

dat3= rbind(dat_normal, dat2)


dat3 = dat3[,c("Case", "Activity", "Timestamp","resource_anomaly_type", 'loc','len')]

write.csv(dat3, "recon_wide.csv",row.names=F)



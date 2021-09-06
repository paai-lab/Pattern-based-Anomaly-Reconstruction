


func.skip.r1 = function(x, start, end, variant_frame){
  repair = x
  if(length(unique(repair[((start:end)+1) ,'Activity']))==1){  #rework
    predict = 'rework'
    repair_save = repair
    repair = repair[-((start:(end+1))+1) ,]
  }else{ #skip
    predict = 'skip'
    actlist = repair$Activity
    
    filter2 = aggregate(variant_frame$Activity, by=list(variant_frame$v_id), FUN= function(x){  #check pre-sequence
      paste(x[1:start], collapse='-') == paste(actlist[1:start], collapse='-')
    })  
    filter3 = aggregate(variant_frame$Activity, by=list(variant_frame$v_id), FUN= function(x){  #check post-sequence  #seeyou
      paste(x[(end+1):(length(x))], collapse='-') == paste(actlist[end:length(actlist)], collapse='-')
    })  
    filter4 = aggregate(variant_frame$Activity, by=list(variant_frame$v_id), FUN= function(x){  #check length
      length(x)==(length(actlist)+1)
    })  
    
    if( sum(filter2[,2]==TRUE & filter3[,2]==TRUE & filter4[,2] == TRUE) ==0  ){
      print("Prediction change: skip pattern -> replace")
      #This may be by replace pattern, so implement replace reconstruction here
      filter2 = aggregate(variant_frame$Activity, by=list(variant_frame$v_id), FUN= function(x){  #check pre-sequence
        paste(x[1:(start-1)], collapse='-') == paste(actlist[1:(start-1)], collapse='-')
      })  
      filter3 = aggregate(variant_frame$Activity, by=list(variant_frame$v_id), FUN= function(x){  #check post-sequence  #seeyou
        paste(x[(end):(length(x))], collapse='-') == paste(actlist[end:length(actlist)], collapse='-')
      }) 
      filter4 = aggregate(variant_frame$Activity, by=list(variant_frame$v_id), FUN= function(x){  #check length
        length(x)==(length(actlist))
      }) 
      replace = as.character(filter2[which(filter2[,2]==TRUE & filter3[,2]==TRUE & filter4[,2] == TRUE),1])
      extract1 = variant_frame[which(is.element(variant_frame$v_id, replace)),]
      extract2 =  extract1[which( as.numeric(extract1$trace_freq) == max(as.numeric(extract1$trace_freq))), 'v_id'][1] #select most frequent one
      
      extract2 = extract1[which(extract1$v_id== extract2), 2:3]
      repair = data.frame(Case = rep(repair$Case[1], nrow(extract2)),  extract2 )
      predict= 'replace'
      # if(nrow(repair) ==0){  # future work
      #   predict = 'replace'
      #   repair = x
      # }

      
    }else{
      replace = as.character(filter2[which(filter2[,2]==TRUE & filter3[,2]==TRUE & filter4[,2] == TRUE),1])
      extract1 = variant_frame[which(is.element(variant_frame$v_id, replace)),]
      extract2 =  extract1[which( as.numeric(extract1$trace_freq) == max(as.numeric(extract1$trace_freq))), 'v_id'][1] #select most frequent one
      
      extract2 = extract1[which(extract1$v_id== extract2), 2:3]
      repair = data.frame(Case = rep(repair$Case[1], nrow(extract2)),  extract2 )
    }
  }
  return( list(repair,predict) )
}




func.vari1 = function(x, actset){
  case1= x
  case1.1 = case1[1:(nrow(case1)-1),]
  case1.2 = cbind(case1.1, case1[2:nrow(case1),'Activity'])
  names(case1.2)= c('Case','label','level','label2')
  case1.2 = case1.2[, c('Case','level','label','label2')]
  case1.2$level = as.numeric(case1.2$level)
  case1= case1.2
  case1$level = 1:nrow(case1)
  
  actlist = x$Activity
  vote = func.token(case1, actset, actlist) # verification
  return(vote)
}



func.InsRepRew.r1 = function(x,actset, start, end, variant_frame){
  repair = x
  if(length(unique(repair[((start:min(end+2,nrow(repair)))) ,'Activity']))==1 & 
     start != (end+2) & end+2 <= nrow(repair)  ){  #rework
    
    predict = 'rework'
    repair = repair[-((start:(end+1))+1) ,]
    vote = func.vari1(repair, actset)
    e2 = which(apply(vote,2,sum)>1)
    MIN = min(e2)
    MAX = max(e2)
    start = MIN
    end = MAX+1
    
    if(length(e2)!=0){
      predict = 'replace'   # rework -> replace
      actlist = repair$Activity

      filter2 = aggregate(variant_frame$Activity, by=list(variant_frame$v_id), FUN= function(x){  #check pre-sequence
        paste(x[1:start], collapse='-') == paste(actlist[1:start], collapse='-')
      })  
      filter3 = aggregate(variant_frame$Activity, by=list(variant_frame$v_id), FUN= function(x){  #check post-sequence  #seeyou
        paste(x[(end):(length(x))], collapse='-') == paste(actlist[end:length(actlist)], collapse='-')
      }) 
      filter4 = aggregate(variant_frame$Activity, by=list(variant_frame$v_id), FUN= function(x){  #check length
        length(x)==(length(actlist)+1)
      }) 
      
      if( sum(filter2[,2]==TRUE & filter3[,2]==TRUE) ==0 ){
        print("Reconstruction error on rework->replace pattern, maybe wrong prediction of the pattern")
        
      }else{
        replace = as.character(filter2[which(filter2[,2]==TRUE & filter3[,2]==TRUE & filter4[,2] == TRUE),1])
        extract1 = variant_frame[which(is.element(variant_frame$v_id, replace)),]
        extract2 =  extract1[which( as.numeric(extract1$trace_freq) == max(as.numeric(extract1$trace_freq))), 'v_id'][1] #select most frequent one
        extract2 = extract1[which(extract1$v_id== extract2), 2:3]
        repair = data.frame(Case = rep(repair$Case[1], nrow(extract2)),  extract2 )
      }
    }
    
  }else{
    predict='insert&replace'
    
    if(start+1 == end){ #check moved
      repair_move = repair[c( 1:start,   ((end+1):(start+1)) , (end+2):nrow(repair)), ]
      vote = func.vari1(repair_move, actset)
      e2 = which(apply(vote,2,sum)>1)
      MIN = min(e2)
      MAX = max(e2)
      if(length(e2)==0){
        predict = 'moved'   # moved
        repair = repair_move
      }else{
        repair = repair[-((start:(end))+1) ,]
        repair.list = func.RepIns.r1(repair, actset, variant_frame)
        repair= repair.list[[1]]
        predict = repair.list[[2]]
      }
    }else{
      repair = repair[-((start:(end))+1) ,]
      repair.list = func.RepIns.r1(repair, actset, variant_frame)
      repair= repair.list[[1]]
      predict = repair.list[[2]]
    }
  }
  return( list(repair,predict) )
}


func.moved.r1 = function(x, actset, start, end, sep1, sep2, variant_frame){
  
  if( (end+1-sep1) >= (sep2-start)){ #moved(lately)
    repair = x
    add =  repair[((sep1+2):(end+1)) ,]
    repair2 = repair[-((sep1+2):(end+1)) ,]
    repair = rbind(repair2[1:start,], add, repair2[(start+1):nrow(repair2),])
    
  }else{                                                                #moved(early)
    repair = x
    add =  repair[((start+1):(sep2-1)) ,]
    repair2 = repair[1:(end+1),]
    repair2 = repair2[-((start+1):(sep2-1)) ,]
    repair3 = repair[(end+2):nrow(repair),]
    repair = rbind(repair2, add, repair3)
  }
  
  vote = func.vari1(repair, actset)
  e2 = which(apply(vote,2,sum)>1)
  MIN = min(e2)
  MAX = max(e2)
  #start = MIN
  #end = MAX+1
  predict='moved'
  
  if(length(e2)!=0){
    predict = 'insert'   # rework -> replace
    repair = x
    repair = repair[-((start:(end))+1) ,]
  }
  return( list(repair, predict) )
}



func.RepIns.r1 = function(x, actset, variant_frame){
  repair = x
  vote = func.vari1(repair, actset)
  e2 = which(apply(vote,2,sum)>1)
  MIN = min(e2)
  MAX = max(e2)
  if(length(e2) !=0 ){ 
    predict= "replace"
    start = MIN
    end = MAX+1
    
    actlist = repair$Activity
    
    filter2 = aggregate(variant_frame$Activity, by=list(variant_frame$v_id), FUN= function(x){  #check pre-sequence
      paste(x[1:start], collapse='-') == paste(actlist[1:start], collapse='-')
    })  
    filter3 = aggregate(variant_frame$Activity, by=list(variant_frame$v_id), FUN= function(x){  #check post-sequence  #seeyou
      paste(x[(end+1):(length(x))], collapse='-') == paste(actlist[end:length(actlist)], collapse='-')
    }) 
    
    filter4 = aggregate(variant_frame$Activity, by=list(variant_frame$v_id), FUN= function(x){  #check length
      length(x)==(length(actlist)+1)
    })
    
    if( sum(filter2[,2]==TRUE & filter3[,2]==TRUE & filter4[,2] == TRUE) ==0  ){
      
      filter1 = aggregate(dat$Activity, by=list(dat$Case), FUN= function(x){sum(is.element(actlist, x))})   # input  = dat
      #if( sum(!is.element(actlist, unique(dat$Activity)))>0 ){ #exception:check new activity name not in activity sets of normal log
      if(length(actlist) > max(filter1[,2])){
        predict = "insert&replace"
        # repair = repair[-((start:(end-1))) ,]  #see you
        repair = repair[-((start:(end-1))) ,]
        repair.list = func.RepIns.r1(repair, actset, variant_frame)
        repair= repair.list[[1]]
        predict = repair.list[[2]]
        
      }
      
      
    }else{
      replace = as.character(filter2[which(filter2[,2]==TRUE & filter3[,2]==TRUE & filter4[,2]==TRUE),1])
      extract1 = variant_frame[which(is.element(variant_frame$v_id, replace)),]
      extract2 =  extract1[which( as.numeric(extract1$trace_freq) == max(as.numeric(extract1$trace_freq))), 'v_id'][1] #select most frequent one
      
      extract2 = extract1[which(extract1$v_id== extract2), 2:3]
      repair = data.frame(Case = rep(repair$Case[1], nrow(extract2)),  extract2 )
    }
  }else{
    predict= "insert"
  }
  
  return( list(repair,predict) )
}




vForest = function(input, dat, dat2, variant_frame){
  preprocess = aggregate(input, by= list(input$Case), FUN= function(x){x})
  total = nrow(preprocess)
  reconst_final = apply(preprocess,1,FUN= function(x){
    vForest_sub(x, dat, dat2, variant_frame)})
}

vForest_sub = function(x, dat, dat2, variant_frame){
  x = data.frame(Case=rep(x$Group.1, length(x$Case)), Activity = x$Activity, order= x$order  )
  case1 = dat2[which(is.element(dat2$Case, x$Case[1])),]  # input case1
  case1=case1[order(case1$level),]
  actlist = c( as.character(case1[,3]),'End')
  vote = func.token(case1, actset, actlist)
  e1 = which(apply(vote,1,sum)>1)
  e2 = which(apply(vote,2,sum)>1)
  MIN = min(e2)
  MAX = max(e2)
  if(length(e1) == 0 & length(e2)==1 ){ #skip: the additional condition "length(e1) == 0" gives more strictness, but less flexible.
    filter1 = aggregate(dat$Activity, by=list(dat$Case), FUN= function(x){sum(is.element(actlist, x))})   # input  = dat
    #if( sum(!is.element(actlist, unique(dat$Activity)))>0 ){ #exception:check new activity name not in activity sets of normal log
    if(length(actlist) > max(filter1[,2])){
      predict = "insert&replace"
      start = MIN
      end = MAX
      repair = x
      repair = repair[-((start:(end))) ,] #see you
      repair.list = func.RepIns.r1(repair, actset, variant_frame)
      repair= repair.list[[1]]
      predict = repair.list[[2]]
    }else{
      predict = "skip"
      start = MIN
      end = MAX+1
      repair = x
      repair.list = func.skip.r1(repair, start, end, variant_frame)
      repair= repair.list[[1]]
      predict = repair.list[[2]]
    }
  }else{
    if(length(e2)>1){
      if(max(diff(e2))>1){  #separated anomalies
        predict="moved"
        start = MIN
        end = MAX-1
        sep1 = e2[which(diff(e2)>1)+1]-1 #for recon
        sep2 = e2[which(diff(e2)>1)]+1 #for recon : divide a vote matrix into two.
        
        repair = x
        repair.list = func.moved.r1(repair, actset, start, end, sep1, sep2, variant_frame)
        repair= repair.list[[1]]
        predict = repair.list[[2]]
      }else{#other
        predict ="insert&replace&rework"
        start = MIN
        end = MAX-1
        
        repair = x
        repair.list = func.InsRepRew.r1(repair, actset, start, end, variant_frame)
        repair= repair.list[[1]]
        predict = repair.list[[2]]
      }
    }else{#other
      if(length(e2)==0){
        repair = x
        predict = 'normal'
        
      }else{
        predict="insert&replace&rework"
        start = MIN
        end = MAX-1
        
        repair = x
        repair.list = func.InsRepRew.r1(repair,actset, start, end, variant_frame)
        repair= repair.list[[1]]
        predict = repair.list[[2]] 
        
      }
    }
  }
  return(list(repair , predict))
}



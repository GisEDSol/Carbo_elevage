FPlot <- function(grille,
                  vNames,
                  data,
                  model,
                  nameModel,
                  neighbors = 0)
  # Description
    # Fonction permettant de tracer l'effet des 4 variables les plus importantes
    # avec le package ggplot2.
  
  # Input
    # grille: grille contenant les combinaisons des valeurs des 4 variables les plus importantes
    # vNames : liste contenant le nom des autres variables prédictives
    # data: base de données
    # model : modèle à utiliser pour la prédiction
    # nameModel : nom du modèle utilisé, gbm, rf ou cubist
    # neighbors : paramètre à renseigner pour la prédiction si le modèle utilisé est cubist, 0 par défaut 

  # Output
    # Trace sur une même page les graphiques représentant l'effet de 
    # variables sur la prédiction d'une certaine variable
{
   
  require(ggplot2)
  require(gbm)
  require(randomForest)
  require(Cubist)
  source("/home/jb/Bureau/pr/Pr_Violaine/FunctionFPlot/code_multiplot.R")
  
  
  # On rajoute à la grille les autres variables (vNames) en leur attribuant la valeur médiane:
  for (v in vNames){
    if (is.factor(d[,v])==TRUE){
      t = table(d[,v])
      ft = t[order(t,decreasing=T)]
      grille[,v] <- d[d[,v]==names(ft[1]),v][1]
    }else{
      grille[,v] <- median(d[,v])
    }
  }
 
  # Prédiction:
  if (nameModel == "gbm"){
    best.iter <- gbm.perf(model,method="cv")
    pred <- predict(model,grille,best.iter)
  }else if (nameModel == "rf"){
    pred <- predict(model,grille)
  }else if (nameModel == "cubist"){
    pred <- predict(model,grille,neighbors = neighbors)
  }
 
  # On ajoute à la grille les valeurs prédites.
  grille$pred <- pred
  
  # Calcul de la valeur médiane pour les prédictions:
    # 1
    print("p1")
    predVar1 <- aggregate(pred,by=list(grille[,1]),median)
    colnames(predVar1) <- c(names(grille)[1],"pred")

  
    if (is.factor(grille[,1])==TRUE){
      p1 <- ggplot(predVar1,aes(names(grille)[1],"pred")) + 
              geom_point() + geom_boxplot() + geom_smooth(aes(group=1)) + 
              theme(axis.text.x  = element_text(angle=90, vjust=1, size=12)) +
              xlab(names(predVar1)[1]) + ylab(paste("f(",names(predVar1)[1],")",sep=""))
      }else{
        p1 <- ggplot(predVar1,aes(names(grille)[1],"pred")) + 
                 geom_point() + geom_smooth() + 
                 xlab(names(predVar1)[1]) + ylab(paste("f(",names(predVar1)[1],")",sep=""))
      }
   # save(p1,file="p1.RData")
  
    # 2
    predVar2 <- aggregate(pred,by=list(grille[,2]),median)
    colnames(predVar2) <- c(names(grille)[2],"pred")
    print("p2")
    attach(predVar2)
    
    if (is.factor(grille[,2])==TRUE){
      p2 <- ggplot(predVar2,aes(names(grille)[2],"pred")) + 
              geom_point() + geom_boxplot() + geom_smooth(aes(group=1)) + 
              theme(axis.text.x  = element_text(angle=90, vjust=1, size=12)) +
              xlab(names(predVar2)[1]) + ylab(paste("f(",names(predVar2)[1],")",sep=""))
    }else{
      p2 <- ggplot(predVar2,aes(predVar2[,1],predVar2[,2])) + 
              geom_point() + geom_smooth() + 
              xlab(names(predVar2)[1]) + ylab(paste("f(",names(predVar2)[1],")",sep=""))
    }
  #save(p2,file="p2.RData")  
    # 3
    print("p3")
    predVar3 <- aggregate(pred,by=list(grille[,3]),median)
    colnames(predVar3) <- c(names(grille)[3],"pred")
    attach(predVar3)    
    if (is.factor(grille[,3])==TRUE){
      p3 <- ggplot(predVar3,aes(predVar3[,1],predVar3[,2])) + 
              geom_point() + geom_boxplot() + geom_smooth(aes(group=1)) + 
              theme(axis.text.x  = element_text(angle=90, vjust=1, size=12)) +
              xlab(names(predVar3)[1]) + ylab(paste("f(",names(predVar3)[1],")",sep=""))
    }else{
      p3 <- ggplot(predVar3,aes(predVar3[,1],predVar3[,2])) + 
              geom_point() + geom_smooth() + 
              xlab(names(predVar3)[1]) + ylab(paste("f(",names(predVar3)[1],")",sep=""))
    }
  #save(p3,file="p3.RData")
    # 4
    print("p4")
    
    predVar4 <- aggregate(pred,by=list(grille[,4]),median)
    colnames(predVar4) <- c(names(grille)[4],"pred")
    attach(predVar4)
    if (is.factor(grille[,4])==TRUE){
      p4 <- ggplot(predVar4,aes(predVar4[,1],predVar4[,2])) + 
              geom_point() + geom_boxplot() + geom_smooth(aes(group=1)) + 
              theme(axis.text.x  = element_text(angle=90, vjust=1, size=12)) +
              xlab(names(predVar4)[1]) + ylab(paste("f(",names(predVar4)[1],")",sep=""))
    }else{
      p4 <- ggplot(predVar4,aes(predVar4[,1],predVar4[,2])) + 
              geom_point() + geom_smooth() + 
              xlab(names(predVar4)[1]) + ylab(paste("f(",names(predVar4)[1],")",sep=""))
    }
     
  #save(p4,file="p4.RData")
  pdf("test2.pdf")
  multiplot(p1, p2, p3, p4, cols=2)
  dev.off()
  
}

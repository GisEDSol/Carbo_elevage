#' @title bootstrap_datamining
#'
#' @description Revoir...
#'
#' @param datax dataframe des covariables
#' @param datay dataframe de la variable à predire
#' @param nbr de répétition
#' @param proportion pour l'apprentissage du modèle (0-1)
#' @param model nom du model ("gbm")
#' @param tuneGrid Paramètres de modélisation
#' @param trControl Paramètres de modélisation
#' @param repsortie Répertoire de sortie (XX/XX/)

boot_caret <- function(
              datax,
              datay,
              nbr,
              prob,
              model,
              tuneGrid,
              trControl,
              repsortie
              )
{

# Paramètrage 
trainmodel <- train(x = datax, y = datay,model,tuneGrid = tuneGrid[[model]],trControl = trControl,verbose = F,keep.data = T)

# Définition de l'échantillon d'apprentissage
fold <- lapply(1:nbr,function(x){
  set.seed(412+x)
  sample(1:length(datay),size = round(length(datay)*prob,0),replace = T)
})

if (model == "cubist"){
  # Meilleur paramètre
  tuneGrid <- expand.grid(.committees = trainmodel$bestTune$committees,.neighbors = trainmodel$bestTune$neighbors)

  # Définition des clusters pour le calcul en parallèle
  clusterExport(cl,list("fold","datax","datay","tuneGrid"),envir=.GlobalEnv)

  # Modélisation Cubist (calcul parallèle)
  mdata_miningbst <- parLapply(cl,fold,function(x){
    require(Cubist)
    # Modélisation sur jeu de données d'apprentissage
    mdata_mining <- cubist(datax[x,],datay[x],
               committees=tuneGrid$.committees,neighbors=tuneGrid$.neighbors)
  
    # Prédiction sur le jeu de validation
    pred <- predict(mdata_mining,datax[-x,],committees=tuneGrid$.committees,neighbors=tuneGrid$.neighbors)

    # Calcul des indicateurs 
    R2 <- round(cor(pred,datay[-x],use="na.or.complete")^2,4)
    MSE <- mean((pred-datay[-x])^2,na.rm=TRUE)
    RMSE <- mean((pred-datay[-x])^2,na.rm=TRUE)^0.5  
    list(mdata_mining=mdata_mining,pred=pred,R2=R2,MSE=MSE,RMSE=RMSE)
  })

  }else if (model == "gbm"){

    clusterExport(cl,list("fold","datax","datay","tuneGrid"),envir=.GlobalEnv)

    # Modélisation gbm (calcul parallèle)
    mdata_miningbst <- parLapply(cl,fold,function(x){

      require(gbm)
      # Modélisation sur jeu de données d'apprentissage
      mdata_mining <- gbm(datax[x,],datay[x],
                committees=tuneGrid$.committees,neighbors=tuneGrid$.neighbors)
  
      # Prédiction sur le jeu de validation
      pred <- predict(mdata_mining,datax[-x,],committees=tuneGrid$.committees,neighbors=tuneGrid$.neighbors)

      # Calcul des indicateurs 
      R2 <- round(cor(pred,datay[-x],use="na.or.complete")^2,4)
      MSE <- mean((pred-datay[-x])^2,na.rm=TRUE)
      RMSE <- mean((pred-datay[-x])^2,na.rm=TRUE)^0.5  
      list(mdata_mining=mdata_mining,pred=pred,R2=R2,MSE=MSE,RMSE=RMSE)
      })
  }else{}

  # Calcul de la moyenne des indicateurs de qualité
  qualityindex <- as.data.frame(sapply(mdata_miningbst,function(x){
    R2 <- x$R2
    MSE <- x$MSE
    RMSE <- x$RMSE
    list(R2=R2,MSE=MSE,RMSE=RMSE)
  }))

  qualityindex <- as.data.frame(do.call(rbind,qualityindex)) 
  R2<- mean(unlist(qualityindex$R2))
  MSE <- mean(unlist(qualityindex$MSE))
  RMSE <- mean(unlist(qualityindex$RMSE))

  # Calcul de l'importance de la variable pour les différentes itérations
  Impvar <- lapply(mdata_miningbst,function(x) {
    vaript <- varImp(x$mdata_mining)
    vaript$var <- rownames(vaript)
    vaript <- vaript[order(vaript$var),]
  })

  # 
  varimp <- as.data.frame(Impvar)
  varimp <- varimp[grep("Overall",names(varimp))]
  MeanimportVar <- as.data.frame(apply(varimp, 1, function(x){mean(x,na.rm=TRUE)}))
  MeanimportVar$var <- rownames(MeanimportVar)
  colnames(MeanimportVar) <- c("importance","variable")
  MeanimportVar <- MeanimportVar[with(MeanimportVar, order(-importance)),]
  varimport <- MeanimportVar[1:15,]
  varimport$variable <- reorder(varimport$variable, varimport$importance)
  varimport$type <- gsub2(as.character(Rcovar),type,as.character(varimport$variable))

  p <- ggplot(varimport, aes(x = variable, y = importance,fill=type)) + 
  geom_bar(stat = "identity") + coord_flip()

return(list(varimport=varimport,rest=rest,p=p))

}#fin de la fonction



#' @title boot_caret
#'
#' @description Revoir...
#'
#' @param d nom de la dataframe
#' @param nbr de répétition
#' @param proportion pour l'apprentissage du modèle (0-1)
#' @param repsortie Répertoire de sortie (XX/XX/)
#' @param name nom du modèle en sortie
#' @param name allcomb(TRUE/FALSE) choix de l'option de tester toute les combinaisons (long)

boot_lm <- function(
              datax,
              datay,
              nbr,
              prob,
              repsortie,
              name,
              allcomb
              )
{

if(allcomb==TRUE){
  vNames <- names(d)

  # Création de l'ensemble des combinaisons
  allcomb <- unlist(lapply(seq(along=vNames[-1]), function(x) combn(vNames[-1], m=x, simplify=FALSE, FUN=paste, collapse="+")))
  allcomb <- as.factor(allcomb)
  print(paste("Nbr de combinaisons :",length(allcomb),sep=""))
  rest2 <- array(NA, dim = c(nbr, 5),list(loop = 1:nbr, mod = c("model","r2","MSE","RMSE","AIC"))) # Table de stockage des résultats

  p <- list()
  cpt <- 0
  for (i in 1:nbr){
    cpt <- cpt + 1
    print(i)
    set.seed(157+i)
    gc()  
    # Sélection aléatoire du masque
    masko <- createDataPartition(d[,1],p = prob, list = FALSE)
  
    donneeL <- d[masko,]
    donneeV <- d[-masko,]
    learningx <- datax[masko,]
    learningy <- datay[masko]
    indepx <- datax[-masko,]
    indepy <- datay[-masko]
  
    rest <- array(NA, dim = c(length(allcomb), 5),list(loop = 1:length(allcomb), mod = c("model","r2","MSE","RMSE","AIC"))) # Table de stockage des résultats

    compt <- 0
    for(l in allcomb){
      compt <- compt+1
      #print(paste(compt,i,sep="_"))
    
      formula <- as.formula(paste(vNames[1], " ~ ", paste(l,collapse=" + ")))
      mlm <- lm(formula,data=donneeL)
      rest[compt, "AIC"] <- AIC(lm(formula,data=donneeL))

      rest[compt, "model"] <- as.character(l)
    
      # Validation externe
      indep.pred <- predict.lm(mlm, indepx)
   
      rest[compt,"r2"] <- as.numeric(round(cor(indep.pred,indepy,use="na.or.complete")^2,4))
      rest[compt,"MSE"] <- mean((indep.pred-indepy)^2,na.rm=TRUE)
      rest[compt,"RMSE"] <- mean((indep.pred-indepy)^2,na.rm=TRUE)^0.5
      }

    # Sélection du meilleur modèle
    rest <- as.data.frame(rest)
    rest <- rest[with(rest, order(-r2,AIC)),]
    rest2[i,"model"] <- as.character(rest[1,"model"])
    rest2[i,"r2"] <- as.numeric(as.character(rest[1,"r2"]))
    rest2[i,"MSE"] <- as.numeric(as.character(rest[1,"MSE"]))
    rest2[i,"RMSE"] <- as.numeric(as.character(rest[1,"RMSE"]))
    rest2[i,"AIC"] <- as.numeric(as.character(rest[1,"AIC"]))
  }
  rest3 <- as.data.frame(rest2)
  rest3[,"model"] <- as.character(rest3[,"model"])
  rest3[,2:5] <- apply(rest3[,2:5],2,function(x){as.numeric(as.character(x))})

  # Sauvegarde
  assign(name,rest3[with(rest3, order(-r2,AIC)),])
  restml <- get(paste(name))
  save(restml,file=paste(repsortie,name,"_ml.RData",sep=""))
}else{}

if(stepwise==TRUE){


}

#return(list(varimport,rest,lastmodel))

}#fin de la fonction

#' @title lm_variatype
#'
#' @description Revoir...
#'
#' @param d nom de la dataframe
#' @param nbr de répétition
#' @param proportion pour l'apprentissage du modèle (0-1)
#' @param repsortie Répertoire de sortie (XX/XX/)
#' @param name nom du modèle en sortie
#' @param Rnaturel Vecteur des variables type naturel
#' @param Ranthrop Vecteur des variables type anthropique

lm_variatype <- function(
              d,
              Rnaturel,
              Ranthrop,
              Variay
              )
{

nmax <- max(length(Ranthrop),length(Rnaturel))
length(Rnaturel) <- nmax
length(Ranthrop) <- nmax
Rnames <- as.data.frame(cbind(Rnaturel,Ranthrop))
typevariable <- colnames(Rnames)

step <- list()
cpt <- 0
for(i in typevariable){
  cpt <- cpt + 1
  
  # Sélection du jeu de données à modéliser
  vNames <- c(Variay,as.character(Rnames[[i]]))
  vNames <- vNames[!is.na(vNames)]

  d1 <- dcast.bdat[complete.cases(dcast.bdat[vNames]),vNames]
  datax <- d1[, vNames[-1]]
  datay <- d1[, vNames[1]]

  formule <- as.formula(paste(vNames[1], " ~ ", paste(as.character(vNames[-1]),collapse=" + ")))
  step[[i]] <- stepAIC(lm(formule,data=d1),direction="both",data=d)
}

####
# Modèle complet #
####
bestmodelclimat <- names(step$Rnaturel$model)[-1]
bestmodelclimat <- paste(bestmodelclimat,collapse="+")
bestmodelanthrop <- names(step$Ranthrop$model)[-1]
bestmodelanthrop <- paste(bestmodelanthrop,collapse="+")

modelcplt <- paste(c(bestmodelclimat,bestmodelanthrop),collapse="+")
vNamescplt <- c(Variay,str_split(modelcplt,"\\+")[[1]])


# Revoir ici
d2 <- d[complete.cases(d[vNamescplt]),vNamescplt]

# Application du modèle sur les variables sélectionnées
formuleanthrop <- as.formula(paste(vNames[1], " ~ ", bestmodelanthrop,sep=""))
vNamesanthrop <- c(Variay,str_split(bestmodelanthrop,"\\+")[[1]])
lmanthrop <- lm(formuleanthrop,data=d2)

formulenaturel <- as.formula(paste(vNames[1], " ~ ", bestmodelclimat,sep=""))
vNamesnaturel <- c(Variay,str_split(bestmodelclimat,"\\+")[[1]])
lmnaturel <- lm(formulenaturel,data=d2)

# Construction d'un modèle complet (variables anthropiques + naturelles)

formulecplt <- as.formula(paste(vNamescplt[1], " ~ ", modelcplt,sep=""))
summary(lm(formulecplt,data=d))$r.squared

# Sortie
formule <- rbind(bestmodelanthrop,bestmodelclimat,modelcplt)
R2 <- rbind(summary(lmanthrop)$r.squared,summary(lmnaturel)$r.squared,summary(lm(formulecplt,data=d))$r.squared)
nom <- c("Anthropique","Naturelle","Complet")
df <- cbind.data.frame(nom,R2,formule[1:3])

return(list(df=df))

}#fin de la fonction
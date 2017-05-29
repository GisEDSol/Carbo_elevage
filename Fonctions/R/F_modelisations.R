#' @title cv_datamining
#'
#' @description Lancer gbm ou cubist en parallèle sur plusieurs itérations et différents jeux de données d'apprentissage.
#'
#' @param datax dataframe des covariables
#' @param datay dataframe de la variable à predire
#' @param nbr de répétition
#' @param prob proportion pour l'apprentissage du modèle (0-1)
#' @param model nom du model ("gbm","cubist")
#' @param tuneGrid Paramètres de modélisation
#' @param trControl Paramètres de modélisation
#' @param select Vecteur pour sélectionner le nombre de variables importante (1:10 par exmple)
#' @param yname Nom de la variable à prédire
#' @param repsortie Répertoire de sortie (XX/XX/)
#' @export En sortie, moyenne de l'importance des variables + graphique & statistiques de la qualité du modèle (validation croisée )

cv_datamining <- function(
                        datax,
                        datay,
                        nbr,
                        prob,
                        model,
                        tuneGrid,
                        trControl,
                        select,
                        yname,
                        repsortie,
                        type
                        )
{

if(model=="cubist" | model=="gbm"){
  # Paramètrage 
  trainmodel <- train(x = datax, y = datay,model,tuneGrid = tuneGrid[[model]],trControl = trControl,verbose = F,keep.data = T)
}else{}

# Définition de l'échantillon d'apprentissage
fold <- lapply(1:nbr,function(x){
  set.seed(412+x)
  sample(1:length(datay),size = round(length(datay)*prob,0),replace = T)
})

if (model == "cubist"){
  # Meilleur paramètre
  tuneGrid <- expand.grid(.committees = trainmodel$bestTune$committees,.neighbors = trainmodel$bestTune$neighbors)

  # Définition des clusters pour le calcul en parallèle (http://stackoverflow.com/questions/12023403/using-parlapply-and-clusterexport-inside-a-function)
  clusterExport(cl,list("fold","datax","datay","tuneGrid"),envir=environment())#.GlobalEnv)

  # Modélisation Cubist (calcul parallèle)
  mdata_miningbst <- parLapply(cl,fold,function(x){
  require(Cubist)
  # Modélisation sur jeu de données d'apprentissage
  mdata_mining <- cubist(datax[x,],datay[x],
               committees=tuneGrid$.committees,neighbors=tuneGrid$.neighbors)
  
  # Prédiction sur le jeu de validation
  #predtrain <- predict(mdata_mining,datax[x,],committees=tuneGrid$.committees,neighbors=tuneGrid$.neighbors)
  predind <- predict(mdata_mining,datax[-x,],committees=tuneGrid$.committees,neighbors=tuneGrid$.neighbors)

  # Calcul des indicateurs 
  R2 <- round(cor(predind,datay[-x],use="na.or.complete")^2,4)
  MSE <- mean((predind-datay[-x])^2,na.rm=TRUE)
  RMSE <- mean((predind-datay[-x])^2,na.rm=TRUE)^0.5  

  list(mdata_mining=mdata_mining,predind=predind,R2=R2,MSE=MSE,RMSE=RMSE)
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
  }else if (model == "lm"){
    print(model)
    vNames <- unique(c(yname,names(datax)))
    formula <- as.formula(paste(vNames[1], " ~ ", paste(vNames[-1],collapse=" + ")))
    dd <- cbind.data.frame(datay,datax)
    colnames(dd)[1] <- yname
  
    # Sélection du modèle
    lmdd <- lm(formula,data=dd)
    step <- stepAIC(lmdd,direction="both",data=dd)  
    
    # Meilleur modèle
    formulabstmodel <- as.formula(paste(names(step$model[1])," ~ ", paste(names(step$model[-1]),collapse=" + ")))
     
    # Définition des clusters pour le calcul en parallèle (http://stackoverflow.com/questions/12023403/using-parlapply-and-clusterexport-inside-a-function)
    clusterExport(cl,list("fold","datax","datay","yname","formula","dd"),envir=environment())#.GlobalEnv)

    # Validation croisée
    mdata_miningbst <- parLapply(cl,fold,function(x){
      lmdd <- lm(formula,data=dd[x,])
      # Modélisation sur jeu de données d'apprentissage      
      predind <- predict(lmdd,datax[-x,])

      # Calcul des indicateurs 
      R2 <- round(cor(predind,datay[-x],use="na.or.complete")^2,4)
      MSE <- mean((predind-datay[-x])^2,na.rm=TRUE)
      RMSE <- mean((predind-datay[-x])^2,na.rm=TRUE)^0.5  

    list(lmdd=lmdd,predind=predind,R2=R2,MSE=MSE,RMSE=RMSE)
    })
  }
  else{}

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
  meanqualityindex <- cbind(R2,MSE,RMSE)

  if(model=="cubist" | model=="gbm"){
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
    varimport <- MeanimportVar[select,]
    varimport$variable <- reorder(varimport$variable, varimport$importance)
    varimport$type <- gsub2(as.character(Rcovar),type,as.character(varimport$variable))

    return(list(varimp=varimp,meanvarimport=varimport,qualityindex=meanqualityindex,R2=qualityindex$R2,RMSE=qualityindex$RMSE,MSE=qualityindex$MSE))
  }else{
  return(list(formulabstmodel=formulabstmodel,qualityindex=meanqualityindex,R2=qualityindex$R2,RMSE=qualityindex$RMSE,MSE=qualityindex$MSE))  
  }

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

  require(MASS)
  formula <- as.formula(paste(vNames[1], " ~ ", paste(vNames[-1],collapse=" + ")))
  #Stepwise
  step <- stepAIC(lm(formula),direction="both",data=ptpedo)
  print(step$anova)
  print(names(step$model))

  #Selection des covariables en fonction du p.value <=0.05
  formulabstmodel <- as.formula(paste(names(step$model[1])," ~ ", paste(names(step$model[-1]),collapse=" + ")))
  multipleregression <- summary(lm(formulabstmodel))
  select <- names(which(multipleregression$coefficients[,4] <= 0.05))[-1]
  print(c(names(step$model[1]),select))
  return(bstmodel=c(names(step$model[1]),select))
}

#return(list(varimport,rest,lastmodel))

}#fin de la fonction

# Sélection des variables avec le vif (selon https://gist.github.com/fawda123/4717702#file-vif_fun-r)
vif_func<-function(in_frame,thresh=10,trace=T,...){

  require(fmsb)
  
  if(class(in_frame) != 'data.frame') in_frame<-data.frame(in_frame)
  
  #get initial vif value for all comparisons of variables
  vif_init<-NULL
  var_names <- names(in_frame)
  for(val in var_names){
      regressors <- var_names[-which(var_names == val)]
      form <- paste(regressors, collapse = '+')
      form_in <- formula(paste(val, '~', form))
      vif_init<-rbind(vif_init, c(val, VIF(lm(form_in, data = in_frame, ...))))
      }
  vif_max<-max(as.numeric(vif_init[,2]), na.rm = TRUE)

  if(vif_max < thresh){
    if(trace==T){ #print output of each iteration
        prmatrix(vif_init,collab=c('var','vif'),rowlab=rep('',nrow(vif_init)),quote=F)
        cat('\n')
        cat(paste('All variables have VIF < ', thresh,', max VIF ',round(vif_max,2), sep=''),'\n\n')
        }
    return(var_names)
    }
  else{

    in_dat<-in_frame

    #backwards selection of explanatory variables, stops when all VIF values are below 'thresh'
    while(vif_max >= thresh){
      
      vif_vals<-NULL
      var_names <- names(in_dat)
        
      for(val in var_names){
        regressors <- var_names[-which(var_names == val)]
        form <- paste(regressors, collapse = '+')
        form_in <- formula(paste(val, '~', form))
        vif_add<-VIF(lm(form_in, data = in_dat, ...))
        vif_vals<-rbind(vif_vals,c(val,vif_add))
        }
      max_row<-which(vif_vals[,2] == max(as.numeric(vif_vals[,2]), na.rm = TRUE))[1]

      vif_max<-as.numeric(vif_vals[max_row,2])

      if(vif_max<thresh) break
      
      if(trace==T){ #print output of each iteration
        prmatrix(vif_vals,collab=c('var','vif'),rowlab=rep('',nrow(vif_vals)),quote=F)
        cat('\n')
        cat('removed: ',vif_vals[max_row,1],vif_max,'\n\n')
        flush.console()
        }

      in_dat<-in_dat[,!names(in_dat) %in% vif_vals[max_row,1]]

      }

    return(names(in_dat))
    
    }
  
}

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

  d1 <- d[complete.cases(d[vNames]),vNames]
  datax <- d1[, vNames[-1]]
  datay <- d1[, vNames[1]]
  
  # test en cours
  keep.data <- vif_func(in_frame=datax,thresh=5,trace=T)

  formule <- as.formula(paste(vNames[1], " ~ ", paste(as.character(keep.data),collapse=" + ")))
  step[[i]] <- stepAIC(lm(formule,data=d1),direction="both",data=d1,verbose = FALSE)
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
lmcplt <- lm(formulecplt,data=d2)

# Sortie
formule <- rbind(bestmodelanthrop,bestmodelclimat,modelcplt)[1:3]
R2 <- rbind(summary(lmanthrop)$r.squared,summary(lmnaturel)$r.squared,summary(lmcplt)$r.squared)
dwtest <- rbind(durbinWatsonTest(lmanthrop)$p,durbinWatsonTest(lmnaturel)$p,durbinWatsonTest(lmcplt)$p)
nom <- c("Anthropique","Naturelle","Complet")
df <- cbind.data.frame(nom,R2,dwtest,formule)

return(list(df=df,lmcplt=lmcplt,d2=d2))

}#fin de la fonction

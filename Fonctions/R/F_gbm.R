#' @title 
#'
#' @description Construit une cartographie d'une variable d'un postgis vecteur
#'
#' @param d nom de la dataframe
#' @param nbr de répétition
#' @param proportion pour l'apprentissage du modèle proportion (0-1)
#' @param model nom du model ("gbm")
#' @param tuneGrid Paramètres de modélisation
#' @param trControl Paramètres de modélisation
#' @param repsortie Répertoire de sortie (XX/XX/)

boot_caret <- function(
              vNames,
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

rest <- array(NA, dim = c(nbr, 3),list(loop = 1:nbr, mod = c("r2","MSE","RMSE")))
importVar <- array(NA, dim = c(length(vNames)-1,nbr+1))
pvar <- list()

cpt <- 0
for (i in 1:nbr){
  cpt <- cpt + 1
  print(i)
  set.seed(157+i)
  gc()  
  # randomizes the mask 
  masko <- createDataPartition(datax[,1],p = prob, list = FALSE)
  
  #donneeL <- d[masko,]
  #donneeV <- d[-masko,]
  learningx <- datax[masko,]
  learningy <- datay[masko]
  indepx <- datax[-masko,]
  indepy <- datay[-masko]
  
  if (model == "cubist"){
            print(model)  
      
            mcubist <- train(x = learningx , y = learningy,model,tuneGrid = tuneGrid,trControl = trControl,verbose = F,keep.data = T)
            print(mcubist$usage)
      
            pvar[[i]] <- varImp(mcubist)
            vaript <- summary(mcubist,plotit=FALSE)
            vaript <- vaript[order(vaript$var),]
            importVar[,1] <- as.character(vaript$var)
            importVar[,cpt] <- as.numeric(vaript$rel.inf)

            f.predict <- predict(mgbm$finalModel, learningx , n.trees = mgbm$bestTune$n.trees)
  
            ### External validation on independent data ###   
            indep.pred <- predict(mcubist$finalModel,indepx,neighbors = mcubist$bestTune$.neighbors)
          }else if (model == "gbm"){
            print(model)
            mgbm <- train(x = learningx , y = learningy,model,tuneGrid = tuneGrid,trControl = trControl,verbose = F,keep.data = T)
         
            pvar[[i]] <- varImp(mgbm)
            vaript <- summary(mgbm,plotit=FALSE)
            vaript <- vaript[order(vaript$var),]
            importVar[,1] <- as.character(vaript$var)
            importVar[,cpt] <- as.numeric(vaript$rel.inf)

            ### External validation on independent data ###   
            indep.pred <- predict(mgbm$finalModel, indepx , n.trees=mgbm$bestTune$n.trees)
            }

  rest[i,"r2"] <- round(cor(indep.pred,indepy,use="na.or.complete")^2,4)
  rest[i,"MSE"] <- mean((indep.pred-indepy)^2,na.rm=TRUE)
  rest[i,"RMSE"] <- mean((indep.pred-indepy)^2,na.rm=TRUE)^0.5
}
# Conservation d'un exemple de modèle
lastmodel <- as.data.frame(cbind(indep.pred,indepy))

# Calcul de l'importance des variables
varimp <- as.data.frame(importVar[,-1])
varimp <- apply(varimp,2,function(x){as.numeric(x)})
MeanimportVar <- apply(varimp, 1, function(x){median(x,na.rm=TRUE)}) 
MeanimportVar <- cbind.data.frame(importVar[,1],MeanimportVar)
colnames(MeanimportVar) <- c("variable","importance")

MeanimportVar <- MeanimportVar[with(MeanimportVar, order(-importance)),]
varimport <- MeanimportVar[1:15,]
varimport$variable <- reorder(varimport$variable, varimport$importance)

varimport$type <- varimport$variable
varimport$type <- gsub2(as.character(Rcovar),type,as.character(varimport$variable))#Ajout du type de facteurs

pimp <- ggplot(varimport, aes(x = variable, y = importance,fill=type)) + 
  geom_bar(stat = "identity") + coord_flip()

ggsave(pimp,file = paste(repsortie,"pimp.jpg",sep=""), width = 8, height = 8)  

return(list(varimport,rest,lastmodel))
}#fin de la fonction
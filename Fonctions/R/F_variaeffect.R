#' @title variaeffect
#'
#' @description Fonction permettant de tracer l'effet des 4 variables les plus importantes de la sortie d'un modèle type Random forest, GBM ou Cubist
#' 
#' @param grille: grille contenant les combinaisons des valeurs des 4 variables les plus importantes
#' @param vNames : liste contenant le nom des autres variables prédictives
#' @param data: base de données
#' @param model : modèle à utiliser pour la prédiction
#' @param nameModel : nom du modèle utilisé, gbm, rf ou cubist
#' @param neighbors : paramètre à renseigner pour la prédiction si le modèle utilisé est cubist, 0 par défaut   
#' @param repsortie : Répertoire pour exporter la figure (XX/XX/)
#' @param nomsortie : Nom de la figure 
#'
#' @author Jean-Baptiste Paroissien
#' @output Trace sur une même page les graphiques représentant l'effet de variables sur la prédiction d'une certaine variable

variaeffect <- function(grille,
                        vNames,
                        data,
                        model,
                        nameModel,
                        neighbors=0)
{
   
  #require(ggplot2)
  #require(gbm)
  #require(randomForest)
  require(Cubist)
 
  lgrille <- length(grille)

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
  
  # Nom de figure en fonction de length(grille)
  p <- list()
  for(i in 1:lgrille){
    predVar <- aggregate(pred,by=list(grille[,i]),median)
    colnames(predVar) <- c(names(grille)[i],"pred")
    attach(predVar)
  
    if (is.factor(grille[,i])==TRUE){
      p[[i]] <- ggplot(predVar,aes_string(names(grille)[i],"pred")) + 
              geom_point() + geom_boxplot() + geom_smooth(aes(group=1)) + 
              theme(axis.text.x  = element_text(angle=90, vjust=1, size=12)) +
              xlab(names(predVar)[1]) + ylab(paste("f(",names(predVar)[1],")",sep="")) + theme_perso()
      }else{
        p[[i]] <- ggplot(predVar,aes_string(names(grille)[i],"pred")) + 
                 geom_point() + geom_smooth() + 
                 xlab(names(predVar)[1]) + ylab(paste("f(",names(predVar)[1],")",sep="")) + theme_perso()
      }
  }
return(list(pgrille=p))
}

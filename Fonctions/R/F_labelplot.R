#' @title generate_label_df
#'
#' @description Permet de créer les labels d'un test statistiques (ici wilcoxon, à adapter pour d'autre test) + nbr analyse par groupe
#' @param lev : nom des groupes dont on souhaite tester la différence significative
#' @param db : nom de la base de données
#' @param value : nom du champs contenant les valeurs à évaluer
#' @param letter : option pour les lettres (letters, LETTERS)

tri.to.squ<-function(x)
{
rn<-row.names(x)
cn<-colnames(x)
an<-unique(c(cn,rn))
myval<-x[!is.na(x)]
mymat<-matrix(1,nrow=length(an),ncol=length(an),dimnames=list(an,an))
for(ext in 1:length(cn))
{
    for(int in 1:length(rn))
    {
    if(is.na(x[row.names(x)==rn[int],colnames(x)==cn[ext]])) next
    mymat[row.names(mymat)==rn[int],colnames(mymat)==cn[ext]]<-x[row.names(x)==rn[int],colnames(x)==cn[ext]]
    mymat[row.names(mymat)==cn[ext],colnames(mymat)==rn[int]]<-x[row.names(x)==rn[int],colnames(x)==cn[ext]]
    }
 
}
return(mymat)
}

generate_label_df <- function(
                              db,
                              value,
                              lev,
                              letter,
                              position
                              )
{
  wilcotest <- pairwise.wilcox.test(db[,value], db[,lev])$p.value
  mymat <- tri.to.squ(wilcotest)
  myletters <- multcompLetters(mymat,compare="<=",threshold=0.05,Letters=letters)
  plot.labels <- names(myletters[['Letters']])
  
  #changement $value par [value]
  boxplot.df <- ddply(db, lev, function (x) quantile(x[value],position,na.rm=TRUE) + 0.2)
  colnames(boxplot.df) <- c("lev","V1")

  nbranalyse.df <- ddply(db, lev, function (x) nrow(x[value]))
  colnames(nbranalyse.df) <- c("lev","Nbr_analyse")
  
  # Create a data frame out of the factor levels and Tukey's homogenous group letters
  plot.levels <- data.frame(plot.labels, labels = myletters[['Letters']],
     stringsAsFactors = FALSE)

  # Jointure
  labels.df <- merge(plot.levels, boxplot.df, by.x = 'plot.labels', by.y = "lev", sort = FALSE)
  labels.df <- merge(labels.df, nbranalyse.df, by.x = 'plot.labels', by.y = "lev", sort = FALSE)

  return(labels.df)
}


# From http://stackoverflow.com/questions/13649473/add-a-common-legend-for-combined-ggplots
grid_arrange_shared_legend <- function(..., nrow = 1, ncol = length(list(...)), position = c("bottom", "right")) {

  plots <- list(...)
  position <- match.arg(position)
  g <- ggplotGrob(plots[[1]] + theme(legend.position = position))$grobs
  legend <- g[[which(sapply(g, function(x) x$name) == "guide-box")]]
  lheight <- sum(legend$height)
  lwidth <- sum(legend$width)
  gl <- lapply(plots, function(x) x + theme(legend.position = "none"))
  gl <- c(gl, nrow = nrow, ncol = ncol)

  combined <- switch(position,
                     "bottom" = arrangeGrob(do.call(arrangeGrob, gl),
                                            legend,
                                            ncol = 1,
                                            heights = unit.c(unit(1, "npc") - lheight, lheight)),
                     "right" = arrangeGrob(do.call(arrangeGrob, gl),
                                           legend,
                                           ncol = 2,
                                           widths = unit.c(unit(1, "npc") - lwidth, lwidth)))
  grid.newpage()
  grid.draw(combined)
  return(combined)
}

# Fonction pour ajouter un thème perso sur ggplot2
# Aide !http://ggplot2.tidyverse.org/reference/theme.html
theme_perso <- function(position="bottom",...){
theme_classic()+
theme(
      axis.text.x = element_text(size = 11, colour = "black"),#,face = "bold"),
      axis.text.y = element_text(size = 11, colour = "black"),#,face = "bold"),face = "bold"),
      axis.line.x = element_line(colour = "black", size = 0.7),
      axis.line.y = element_line(colour = "black", size = 0.7),
      plot.title = element_text(size = 14, face = "bold"), 
      text = element_text(size = 12),
      strip.background = element_rect(colour = "white", fill = "grey"),#pour facet_wrap
      strip.text.x = element_text(colour = "black", face = "bold"),#pour facet_wrap
      axis.title = element_text(face="bold"),
      legend.position = position)
}

# Pour afficher la droite de regression + l'équation et le R2
# from https://gist.github.com/ottadini/6882677
# Source: http://stackoverflow.com/q/7549694/857416
lm_eqn = function(m) {
  # Displays regression line equation and R^2 value on plot
  # Usage:
  # p + annotate("text", x=25, y=300, label=lm_eqn(lm(y ~ x, df)), parse=TRUE)
  
  l <- list(a = format(coef(m)[1], digits = 2),
            b = format(abs(coef(m)[2]), digits = 2),
            r2 = format(summary(m)$r.squared, digits = 3));
  
  if (coef(m)[2] >= 0)  {
    eq <- substitute(italic(y) == a + b %.% italic(x)*","~~italic(r)^2~"="~r2,l)
  } else {
    eq <- substitute(italic(y) == a - b %.% italic(x)*","~~italic(r)^2~"="~r2,l)    
  }
  
  as.character(as.expression(eq));                 
}

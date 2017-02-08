#' @title importparametres
#'
#' @description Fonction pour charger les libraries, et les variables du projet
#'
#' @param dsn Paramètre de connexion vers la base de données
#' @param repmaster Chemin vers la copie du dépôt GitHub en local (XX/XX/)
#' @param repdata Chemin vers les données à intégrer dans la base (XX/XX/)
#'
#' @author Jean-Baptiste Paroissien
#' @keywords 
#' @seealso 
#' @export
#' @examples
#' ## Ne fonctionne pas 
# importparametres(repmaster="/media/sf_GIS_ED/Dev/Scripts/master/",repdata="/media/sf_GIS_ED/Dev/",dsn="PG:dbname='sol_elevage' host='localhost' port='5432' user='jb'")


importparametres <- function(dsn,
						repmaster,
						repdata)
{

ipak <- function(pkg){
    new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
    if (length(new.pkg)) 
        install.packages(new.pkg, dependencies = TRUE)
    sapply(pkg, require, character.only = TRUE)
}

# Chargement des librairies
listpaquets <- c("RODBC","gdata","fields","stringr","ggplot2","rgdal","maptools","RColorBrewer","classInt","devtools","reshape2","Hmisc","gridExtra","mapproj","wesanderson","FactoMineR",
	"knitr","pander","GGally","factoextra","caret","plyr","doMC","sp","raster","RPostgreSQL","corrplot")
ipak(listpaquets)
#new.packages <- listpaquets[!(listpaquets %in% installed.packages()[,"Package"])]
#if(length(new.packages)) install.packages(new.packages)

knitr::opts_chunk$set(echo = TRUE)

# knit_hooks,fig : Fonctions pour générer la référence des figures et des tableaux (selon https://rstudio-pubs-static.s3.amazonaws.com/98310_b44bc54001af49d98a7b891d204652e2.html#five_to_one)
# A function for generating captions and cross-references
fig <- local({
    i <- 0
    list(
        cap=function(refName, text, center=FALSE, col="black", inline=FALSE) {
            i <<- i + 1
            ref[[refName]] <<- i
            css_ctr <- ""
            if (center) css_ctr <- "text-align:center; display:inline-block; width:100%;"
            cap_txt <- paste0("<span style=\"color:", col, "; ", css_ctr, "\">Figure ", i, ": ", text , "</span>")
            anchor <- paste0("<a name=\"", refName, "\"></a>")
            if (inline) {
                paste0(anchor, cap_txt)    
            } else {
                list(anchor=anchor, cap_txt=cap_txt)
            }
        },
        
        ref=function(refName, link=FALSE, checkRef=TRUE) {
            
            ## This function puts in a cross reference to a caption. You refer to the
            ## caption with the refName that was passed to fig$cap() (not the code chunk name).
            ## The cross reference can be hyperlinked.
            
            if (checkRef && !refName %in% names(ref)) stop(paste0("fig$ref() error: ", refName, " not found"))
            if (link) {
                paste0("<A HREF=\"#", refName, "\">", ref[[refName]], "</A>")
            } else {
                paste0(ref[[refName]])
            }
        },
        
        ref_all=function(){
            ## For debugging
            ref
        })
})
assign("fig",fig,.GlobalEnv)

library(knitr)
knit_hooks$set(plot = function(x, options) {
    sty <- ""
    if (options$fig.align == 'default') {
        sty <- ""
    } else {
        sty <- paste0(" style=\"text-align:", options$fig.align, ";\"")
    }
    
    if (is.list(options$fig.cap)) {
        ## options$fig.cap is a list returned by the function fig$cap()
        str_caption <- options$fig.cap$cap_txt
        str_anchr <- options$fig.cap$anchor
    } else {
        ## options$fig.cap is a character object (hard coded, no anchor)
        str_caption <- options$fig.cap
        str_anchr <- ""
    }
    
    paste('<figure', sty, '>', str_anchr, '<img src="',
        opts_knit$get('base.url'), paste(x, collapse = '.'),
        '"><figcaption>', str_caption, '</figcaption></figure>',
        sep = '')
    
})

# Définition des principaux répertoires de travail #####################################

##
assign("repmetadonnees",paste(repmaster,"Documentation/Metadonnees/",sep=""),.GlobalEnv)
assign("repfonctions",paste(repmaster,"Fonctions/",sep=""),.GlobalEnv)
#########################################

##
assign("repLucas",paste(repdata,"Sol/Lucas/",sep=""),.GlobalEnv)
assign("repCLC",paste(repdata,"Vegetation_Occup/CLC/",sep=""),.GlobalEnv)
assign("repBDAT",paste(repdata,"Sol/bdat/",sep=""),.GlobalEnv)
assign("repBase",paste(repdata,"Base/",sep=""),.GlobalEnv)
assign("repagreste",paste(repdata,"Vegetation_Occup/Agreste/Disar/",sep=""),.GlobalEnv)
#########################################

# 
assign("github_url",paste("https://github.com/Rosalien/GISEDSol/tree/master/",sep=""),.GlobalEnv) #url du dépôt github

# Mise en place de la connexion ODBC
assign("loc",odbcConnect("solelevage",case="postgresql", believeNRows=FALSE),.GlobalEnv)

# Paramètres de connexion de la BDD
assign("dsn",dsn,.GlobalEnv)

# Connexion avec RPostgreSQL
assign("m",dbDriver("PostgreSQL"),.GlobalEnv)
assign("con",dbConnect(m, dbname="sol_elevage"),.GlobalEnv)

# Chargement des fonctions
source(paste(repfonctions,"R/F_carto.R",sep=""))

# Fonction très pratique pour remplacer une suite de charact?res par une autre
gsub2 <- function(pattern, replacement, x, ...) {
  for(i in 1:length(pattern))
    x <- gsub(pattern[i], replacement[i], x, ...)
  x
}
assign("gsub2",gsub2,.GlobalEnv)

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

assign("grid_arrange_shared_legend",grid_arrange_shared_legend,.GlobalEnv)

#from https://gist.github.com/ottadini/6882677
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

assign("lm_eqn",lm_eqn,.GlobalEnv)

#return(list(grid_arrange_shared_legend,gsub2,fig=fig))
}#Fin fonction




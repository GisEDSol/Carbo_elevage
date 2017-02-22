Faic <- function(tablename,
		 vNames,
 		 transfParam,
		 allcomb,
		 stepwise,
		 regression
		 )
{
	
################################################################
pt <- sqlQuery(loc,paste("select * from ",tablename,sep=""))

if(transfParam=="log"){
	pt[vNames[1]] <- log(pt[vNames[1]])
}else{}
ptpedo <- pt[vNames][complete.cases(pt[vNames]),]
attach(ptpedo)
labels <- names(ptpedo[,2:ncol(ptpedo)])

if(allcomb==TRUE){
	
	#Combinaisons
	allcomb <- unlist(lapply(seq(along=labels), function(x) combn(labels, m=x, simplify=FALSE, FUN=paste, collapse="+")))
	allcomb <- as.factor(allcomb)

	#Stepwise
	co <- as.matrix(ptpedo[[1]])
	rest <- array(NA, dim = c(length(allcomb), 3), list(loop = 1:length(allcomb), mod = c("model","r2","AIC")))
	compt <- 0

	for(i in allcomb){
		compt <- compt+1
		print(paste(compt,i,sep="_"))
		rest[compt, "model"] <- i
		formula <- as.formula(paste(vNames[1], " ~ ", paste(i,collapse=" + ")))
		rest[compt, "r2"] <- summary(lm(formula))$r.squared
		rest[compt, "AIC"] <- AIC(lm(formula))
	}
	rest <- as.data.frame(rest)
	rest <- rest[with(rest, order(-r2,AIC)),]
	bstcovar <- rest["model"][1,]

	print(paste("Meilleur model : ",bstcovar,sep=""))
	write.csv(rest,paste(fold,tablename,".csv",sep=""))

	return(list(bstcovar=gsub("\\+", ",", paste(bstcovar,sep=""))))
	
}			
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

if(regression==TRUE){
	#Stepwise
	co <- as.matrix(ptpedo[[1]])
	rest <- array(NA, dim = c(length(vNames[-1]), 3), list(loop = 1:length(vNames[-1]), mod = c("model","r","pvalue")))
	cpt <- 0

	for(i in vNames[-1]){
		cpt <- cpt+1
		print(paste(cpt,i,sep="_"))
		rest[cpt, "model"] <- i
		formula <- as.formula(paste(vNames[1], " ~ ", i))
		print(formula)
		rest[cpt, "r"] <- summary(lm(formula))$r.squared
		rest[cpt,"pvalue"] <- summary(lm(formula))$coefficients[i,"Pr(>|t|)"]
	}

	rest <- data.frame(stringsAsFactors=FALSE,model=as.character(rest[,"model"]),r=as.numeric(rest[,"r"]),pvalue=as.numeric(rest[,"pvalue"]))
	return(list(rest=rest))
}


}






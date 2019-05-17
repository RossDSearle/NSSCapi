
source('C:/Users/sea084/Dropbox/RossRCode/Git/NSSCapi/TERNLandscapesAPI.R')

op = 'h_texture'
op = 'SEG_FORM'
op = 'RO_ABUN'
op = 'S_DESC_BY'
op = '3A1'

observedProperty = '3A1'
observedProperty = 'h_texture'
observedProperty = 'SEG_FORM'
observedProperty = 'RO_ABUN'
observedProperty = 'S_DESC_BY'

df <- getData_NSSC(provider='TasGovernment', observedProperty=op, observedPropertyGroup = NULL)
getData_NSSC(provider='QLDGovernment', observedProperty=op, observedPropertyGroup = NULL)

providers='TasGovernment'
observedPropertyGroup = NULL


rio::export(df, "c:/temp/dat.xml")

library(kulife)
write.xml(df, file="c:/temp/mydata.xml")


recs <- df[1,1:10]
f <- function(x){
  v <- '<record>'
  for (i in 1:length(names(x))) {
   v <- paste0(v, '<', names(x)[i], '>', x[i], '</', names(x)[i], '>')
  }  
  v <- paste0(v,'</record>')
  return(v)
}

fi <- function(y){
  v <- paste0(v, '<', names(y), '>', y, '</', names(y), '>')
}


f2 <- function(x){
  v <- '<record>'
 v <- lapply(x, fi)
  v <- paste0(v,'</record>')
  return(v)
}


apply()

o <- apply(df, 1, f)

s <- unlist(o)

library(stringi)
stri_join_list(s, sep = "", collapse = NULL)


xml <- paste(s, collapse = '')
str(s)
s[1,]


df <- getPropertiesList(Properties, observedPropertyGroup='PH', verbose=T)


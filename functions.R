


getPropertiesList <- function( Properties, ObserverdProperties=NULL, observedPropertyGroup=NULL){
  
  if(!is.null(observedPropertyGroup)){
    ps <- na.omit(Properties[str_to_upper(Properties$PropertyGroup)==str_to_upper(observedPropertyGroup), ]$Property )  
  }else{
    bits <- str_split(ObserverdProperties, ';')
    ps <- bits[[1]]
  }
  return(ps)
}

getProperties <- function( Properties, observedPropertyGroup=NULL, verbose=T){
  
  if(!is.null(observedPropertyGroup)){
   ps <- na.omit(Properties[str_to_upper(Properties$PropertyGroup)==str_to_upper(observedPropertyGroup), ] )  
  }else{
    ps <- Properties
  }
  
  if(verbose){
    return(ps)
  }else{
    return(ps$Property)
  }
}

doQuery <- function(conn, sql){
  
  q1 <-str_replace_all(sql, 'dbo_', '')
  q2 <-str_replace_all(sql, '"', "\'")
  qry <- dbSendQuery(conn, q1)
  res <- dbFetch(qry)
  dbClearResult(qry)
  return(res)
}

blankResponseDF <- function(){
  
  outDF <- na.omit(data.frame(Organisation=NULL, Observation_ID=character(), SampleID=character(), Date=character() ,
                              Longitude=numeric() , Latitude= numeric(),
                              UpperDepth=numeric() , LowerDepth=numeric() , PropertyType=character(), ObservedProperty=character(), Value=numeric() , Units= character()))
}

generateResponseDF <- function(provider, observation_ID, sampleID, date, longitude, latitude, upperDepth, lowerDepth, dataType, observedProp, value, units ){
  
  outDF <- na.omit(data.frame(Provider=provider, Observation_ID=observation_ID, SampleID=sampleID , Date=date ,
                              Longitude=longitude, Latitude=latitude ,
                              UpperDepth=upperDepth, LowerDepth=lowerDepth, PropertyType=dataType, ObservedProperty=observedProp, Value=value , Units= units))
  oOutDF <- outDF[order(outDF$Observation_ID, outDF$UpperDepth, outDF$SampleID),]
  return(oOutDF)
}







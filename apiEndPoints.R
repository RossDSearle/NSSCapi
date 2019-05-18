library(htmlTable)


machineName <- as.character(Sys.info()['nodename'])
if(machineName=='soils-discovery'){
  rootDir <<- '/srv/plumber/NSSCapi'
}else{
  rootDir <<- 'C:/Users/sea084/Dropbox/RossRCode/Git/NSSCapi'
}

source(paste0(rootDir, '/TERNLandscapesAPI.R'))
source(paste0(rootDir, '/functions.R'))


#* @apiTitle National Soil Site Collation Web API
#* @apiDescription These services allow <b>unified</b> and <b>standardised</b> access to a range of disparate soil database systems.<br><br> More detail about the Soils Federation Service can be found <a href='http://esoil.io/FederatedServices/FedeartedSesnsorsHelpPage.html' > here </a>




#' Log system time, request method and HTTP user agent of the incoming request
#' @filter logger
function(req){



  logentry <- paste0(as.character(Sys.time()), ",",
       machineName, ",",
       req$REQUEST_METHOD, req$PATH_INFO, ",",
       str_replace_all( req$HTTP_USER_AGENT, ",", ""), ",",
       req$QUERY_STRING, ",",
       req$REMOTE_ADDR
      )

  dt <- format(Sys.time(), "%d-%m-%Y")

  logDir <- paste0("Logs")
  if(!dir.exists(logDir)){
     dir.create(logDir, recursive = T)
    }

  logfile <- paste0("Logs/NSSC_API_logs_", dt, ".csv")
  if(file.exists(logfile)){
    cat(logentry, '\n', file=logfile, append=T)
  }else{
    hdr <- paste0('System_time,Server,Request_method,HTTP_user_agent,QUERY_STRING,REMOTE_ADDR\n')
    cat(hdr, file=logfile, append=F)
    cat(logentry, '\n', file=logfile, append=T)
  }

  plumber::forward()
}





#* ReturnsSoil Property data

#* @param format (Optional) format of the response to return. Either json, csv, or xml. Default = json
#* @param key (Optional) A key to allow access the restricted data sets.
#* @param observedPropertyGroup (Required) A code specifying the group of soil observed properties to query.
#* @param observedProperty (Required) The soil property code.
#* @param providers (Required) The Organisation code for the data you want to query.

#* @get /SoilDataAPI/SoilData
apiGetNSSCSoilData<- function(res, usr='Public', pwd='Public', providers=NULL, observedProperty=NULL, observedPropertyGroup=NULL, key=NULL, format='json'){

tryCatch({

  print(paste0('Providers = ', providers))
        DF <- getData_NSSC(providers, observedProperty, observedPropertyGroup, key)
         label <- 'SoilProperty'
         resp <- cerealize(DF, label, format, res)
         return(resp)
  }, error = function(res)
  {
    print(geterrmessage())
    res$status <- 400
    list(error=jsonlite::unbox(geterrmessage()))
  })
}




#* List of available organisations
#* @param format (Optional) format of the response to return. Either json, csv, or xml. Default = json

#* @get /SoilDataAPI/Providers
apiGetProviders <- function( res, format='json'){

  tryCatch({

    DF <-getNSSCProviders()
    label <- 'DataProvider'
    resp <- cerealize(DF, label, format, res)

    return(resp)

  }, error = function()
  {
    print(geterrmessage())
    res$status <- 400
    list(error=jsonlite::unbox(geterrmessage()))
  })
}






#* Returns a listing of the available properties


#* @param format (Optional) format of the response to return. Either json, csv, or xml. Default = json
#* @param verbose (Optional) return just the property codes or the full descriptions. Default = True
#* @param PropertyGroup (Optional) return just the properties for a given PropertGroup. Default = All


#* @get /SoilDataAPI/Properties
apiGetPropeties <- function( res, PropertyGroup=NULL, verbose=T, format='json'){

  tryCatch({

    DF <-getNSSCProperties(PropertyGroup, verbose)
    label <- 'Property'
    
    
    d1 <- str_replace_all(DF$Description, '<', 'Less than ')
    d2 <- str_replace_all(d1, '>', 'Greater than ')
    DF$Description <- d2
    resp <- cerealize(DF, label, format, res)
    
    return(resp)

  }, error = function(res)
  {
    print(geterrmessage())
    res$status <- 400
    list(error=jsonlite::unbox(geterrmessage()))
  })
}


#* Returns a listing of the available Property Groups

#* @param format (Optional) format of the response to return. Either json, csv, or xml. Default = json

#* @get /SoilDataAPI/PropertyGroups
apiGetPropetyGroups <- function( res, format='json'){

  tryCatch({

    DF <-getNSSCPropertyGroups()
   
    head(DF)
    label <- 'PropertyGroup'
    resp <- cerealize(DF, label, format, res)
    
    return(resp)
    

  }, error = function(res)
  {
    print(geterrmessage())
    res$status <- 400
    list(error=jsonlite::unbox(geterrmessage()))
  })
}






#######     Some utilities    ###########################



cerealize <- function(DF, label, format, res){
  
  
  if(format == 'xml'){
   
    res$setHeader("Content-Type", "application/xml; charset=utf-8")
    xmlT <- writexml(DF, label)
    res$body <- xmlT
    return(res)
    
  }else if(format == 'csv'){
    res$setHeader("content-disposition", paste0("attachment; filename=", label, ".csv"));
    res$setHeader("Content-Type", "application/csv; charset=utf-8")
    res$body <- writecsv(DF)
    return(res)
    
  }else if(format == 'html'){
    res$setHeader("Content-Type", "text/html ; charset=utf-8")
    res$body <- htmlTable(DF, align = "l", align.header = "l", caption = label)
    return(res)
    
  }else{
    return(DF)
  }
  
  
}



writecsv <- function(DF){

  tc <- textConnection("value_str2", open="w")
   write.table(DF, textConnection("value_str2", open="w"), sep=",", row.names=F, col.names=T)
   value_str2 <- paste0(get("value_str2"), collapse="\n")
   close(tc)
   return(value_str2)

}

writexml <- function(df, label){
  
  o <- apply(df, 1, DataFrameToXmlwriter, label)
  s <- unlist(o)
  xml <- paste( s, collapse = '')
  xml2 <- str_replace_all(paste0('<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>\n<', label, 'Records>\n', xml, '</', label, 'Records>'), '&', '')

  
  #cat(xml2, file='c:/temp/x.xml')
  return(xml2)
}

DataFrameToXmlwriter <- function(x, label){

  v <- paste0('<', label, 'Record>')
  for (i in 1:length(names(x))) {
    v <- paste0(v, '<', names(x)[i], '>', x[i], '</', names(x)[i], '> ')
  }  
  v <- paste0(v,'</', label, 'Record>\n')
  return(v)
}


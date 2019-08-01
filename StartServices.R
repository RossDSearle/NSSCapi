library(plumber)
library(htmltidy)

#deployDir <-'/srv/plumber/TERNLandscapes/NSSCapi'

machineName <- as.character(Sys.info()['nodename'])
if(machineName=='soils-discovery'){
  deployDir <<- '/srv/plumber/TERNLandscapes/SoilDataFederatoRDatabase'
  server <- 'http://esoil.io'
}else{
  deployDir <<- 'C:/Users/sea084/Dropbox/RossRCode/Git/TERNLandscapes/APIs/NSSCapi'
  server <- 'http://0.0.0.0'
}


#server <- 'http://esoil.io'
portNum <- 8075

r <- plumb(paste0(deployDir, "/apiEndPoints.R"))  
print(r)

options("plumber.host" = "0.0.0.0")
options("plumber.apiHost" = "0.0.0.0")
r$run(host= server, port=portNum, swagger=TRUE)

r$run(host=server, port=portNum, swagger=TRUE)








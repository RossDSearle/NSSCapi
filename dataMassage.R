library(stringr)
library(RSQLite)
library(DBI)


setwd('C:/Users/sea084/Dropbox/RossRCode/Git/TernLandscapes/APIs/SoilDataFederatoR')
# path below is - C:/R/R-3.6.0/library/SoilDataFederatoR/extdata/soilsFederator.sqlit
dbPathSoilsFed <- system.file("extdata", "soilsFederator.sqlite", package = "SoilDataFederatoR")
conn <- dbConnect(RSQLite::SQLite(), dbPathSoilsFed)






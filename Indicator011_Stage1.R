# Script for DDEC Indicator 011
# Author: Gamaliel Lamboy Rodríguez
# Version: 1.0
# Description:
# This script partially automatizes the obtainment of Indicator 010 from its 
# database. It assumes an incremental updating of the data, and that the most 
# recent year of database is being manipulated. This indicator contains the
# employment compensation data, which are a measure of the labor costs in the
# intangible assets economy.

# The data are organized in small groups of rows, each pertaining to a 
# particular NAICS sector. These NAICS groups contain:

# 1) Total Net Income -- unused
# 2) Employee Compensation -- 

# Preload additional packages to use.
library("openxlsx")

# Initial parameters for reading the file.
PARAMS <- list(
startrow=1,
sheet=1,
rowNames = FALSE,
colNames = FALSE,
cols = c(1:12,14)
)

attach(PARAMS)

# Read the original data.
dats1 <- do.call( read.xlsx, c( list( PARAMS, xlsxFile = 
"./Original_Data/Indicator 011 Database.xlsx")))

detach(PARAMS)

# Eliminate all rows not containing NAICS codes.
dats1_naics <- grep("(^[0-9]{4}$)|(^[0-9]{2}\\-[0-9]{2})|(^[0-9]{2}$)", 
dats1[,1])

# Locate the rows of the employee compensation data.
dats1_comp <- grep("Compensación a empleados", dats1[,2])
# Select the NAICS closest to the employee compensation data. This procedure is
# necessary since the data are 
dats1_dist <- sapply(dats1_naics, function(x) 
{
    min(dats1_comp[dats1_comp > x] - x)
})

dats1 <- data.frame( dats1[ dats1_naics,c(1,13)], dats1[ dats1_naics + dats1_dist, 3:12])

colnames(dats1) <- c( scan(what = "", sep = "\n", file = "./Stage1/Changed_Names"),
paste("year_", 2005:2014, sep = ""))

codelist_naics <- scan(what = "", sep = "\n", file = "./Stage2/Codelist_NAICS")
naics0 <- gsub( "0+$", "", dats1$naics_code)


naics <- sapply(codelist_naics, function(x)
{
    naics_sub <- substring(x, 1, 2:nchar(x))
    matchnaics <- naics0[ naics0 %in% naics_sub ]
    matchnaics[ which.max( sapply(matchnaics, nchar)) ]
})

dats3 <- dats1[ naics0 %in% naics, c(1:2, 9:12)]

write.csv( dats3, "./Stage3/results_indicator011_stage3.csv", row.names = F)
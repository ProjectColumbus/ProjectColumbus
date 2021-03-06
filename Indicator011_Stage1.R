# Script for DDEC Indicator 011
# Author: Gamaliel Lamboy Rodríguez
# Version: 1.0
# Description:
# This script partially automatizes the obtainment of Indicator 011 from its 
# database. It assumes an incremental updating of the data, and that the most 
# recent year of database is being manipulated. This indicator contains the
# employment compensation data, which are a measure of the labor costs in the
# intangible assets economy.

# The data are organized in small groups of rows, each pertaining to a 
# particular NAICS sector. These NAICS groups contain:

# 1) NAICS code -- appears in the first column as the row group header (used)
# 2) Total Net Income -- Sum of employee compensation and income derived 
# from property (unused)
# 3) Employee Compensation -- Payroll + benefits (used)
# 4) Income derived from property -- rent, patents, etc. (unused)

# Preload additional packages to use.
library("openxlsx")
library("reshape2")

# Initial parameters for reading the file.
PARAMS <- list(
startRow=1,
sheet=1,
rowNames = FALSE,
colNames = FALSE,
cols = c(1:12,14)
)

attach(PARAMS)

# Read the original data.
dats1 <- do.call( read.xlsx, c( PARAMS, list(xlsxFile = 
"./Original_Data/Indicator 011 Database.xlsx")))

detach(PARAMS)

# Eliminate all rows not containing NAICS codes.
dats1_naics <- grep("(^[0-9]{4}$)|(^[0-9]{2}\\-[0-9]{2})|(^[0-9]{2}$)", 
dats1[,1])

# Locate the rows of the employee compensation data.
dats1_comp <- grep("Compensación a empleados", dats1[,2])

# Select the NAICS closest to the employee compensation data. This procedure is
# necessary since the NAICS descriptions often span two (2) or more rows in the 
# original data. Thus, the row with the NAICS label does not have a regular 
# distance between itself and the data value ("compensación a empleados").
dats1_dist <- sapply(dats1_naics, function(x) 
{
# Only observations *after* the NAICS code "heading" are considered, obviously.
    min(dats1_comp[dats1_comp > x] - x)
})

# Create a data frame with the NAICS codes, NAICS descriptions, and the 
# employee compensation values.
dats1 <- data.frame( dats1[ dats1_naics,c(1,13)], dats1[ dats1_naics + 
dats1_dist, 3:12])

colnames(dats1) <- c( scan(what = "", sep = "\n", file = 
"./Stage1/Changed_Names"), paste("year_", 2005:2014, sep = ""))

# Retrieve the selected NAICS codes.
codelist_naics <- scan(what = "", sep = "\n", file = "./Stage2/Codelist_NAICS")

# Perform the usual stem-and-leaf search done in previous indicators. Maybe
# this should be outsourced as a separate file (e.g. "Master_Functions.R")?
naics0 <- gsub( "0+$", "", dats1$naics_code)

naics <- sapply(codelist_naics, function(x)
{
    naics_sub <- substring(x, 1, 2:nchar(x))
    matchnaics <- naics0[ naics0 %in% naics_sub ]
    matchnaics[ which.max( sapply(matchnaics, nchar)) ]
})

# Select the codes and results to be presented. Perhaps the colnames should
# be referenced instead of the column numbers here?
dats3 <- dats1[ naics0 %in% naics, c(1:2, 9:12)]

dats3$naics_code <- gsub("0+$", "", dats3$naics_code)
dats3[,3:ncol(dats3)] <- sapply( dats3[,3:ncol(dats3)], function(x) as.numeric(
gsub("^\\$([0-9]+)(\\,[0-9]+)*\\.([0-9]+)", "\\1\\2.\\3", x)) )


load("../Master_Scripts/SectorDescs.RData")
attach( DESCS)

dats3$naics_title_code <- naicslist$naics_desc[ match( dats3$naics_code,
naicslist$naics_code) ]

detach(DESCS)

dats3 <- dats3[ order(dats3$naics_code),]

dats3[ nrow(dats3) + 1,] <- c("", "Total", colSums(dats3[,-c(1:2)], na.rm =
TRUE))

dats3 <- melt(dats3, id.vars = c("naics_code", "naics_title_code"))

# Write the data.
write.csv( dats3, "./Stage3/results_indicator011_stage3y.csv", row.names = F)

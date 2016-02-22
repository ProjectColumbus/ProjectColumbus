# Script for DDEC Indicators 004 to 007
# Author: Gamaliel Lamboy Rodríguez
# Version: 1.0
# Description:
# This script partially automatizes the obtainment of Indicators 004-007 from
# their database. It assumes an incremental updating of the data, and that the
# recent year of database is being manipulated. For time trends, the user must
# supply the database year, which is then assigned as the main variable name.
# The resulting file can afterwards be joined with the cumulative
# (time-series) dataset.

library("openxlsx")

wb <- createWorkbook()

dats1 <- data.frame( concept = c("Total", "Private (Services)", 
"Public and Nonprofit"), total_amount = rep(NA,3))

dats1c1 <- data.frame( NAICS = rep("", 10), amount = rep("", 10), pct_manuf = 
rep( 1, 10), pct_services = paste("(1 - ", "C", 1:10+1L, sep = ""), 
stringsAsFactors = F)

class( dats1c1$pct_services) <- c( class( dats1c1$pct_services), "formula")

formtot <- paste("SUMPRODUCT( \'private_sector\'!C", ,
"\'private_sector\'!E",

addWorksheet(wb, "private_sector")
addWorksheet(wb, "total_amount")

addStyle(wb, sheet = 1, style = createStyle( numFmt = "#,##0.0%"), 
rows = 1:10 + 1L, cols = 3)
addStyle(wb, sheet = 1, style = createStyle( numFmt = "#,##0.0%"), 
rows = 1:10 + 1L, cols = 4)

writeData(wb, sheet = 1, x = dats1c1)
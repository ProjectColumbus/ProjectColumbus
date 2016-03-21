# Script for DDEC Indicator 026
# Author: Gamaliel Lamboy Rodríguez
# Version: 1.0
# Description:
# This script partially automatizes the obtainment of Indicator 026 from its 
# database. It assumes an incremental updating of the data, and that the most 
# recent year of database is being manipulated. This indicator measures the
# number of institutions with completions awarded in the CIP codes of the EAI.

filters = matrix( c("R Data Files", ".RData"), 1, 2, byrow = TRUE)

# The data is obtained directly from the results in Indicator 012.
load(tcltk::tk_choose.files(multi = FALSE, filters = filters))

# # Select the appropriate columns, and write file.

dats3 <- aggregate( dats3[,5], by = list( cip_code = dats3[,1], 
cip_description = dats3[,2], year = dats3[,4]), FUN = sum, na.rm = TRUE)

colnames(dats3)[4] <- "N"

write.csv(dats3, "./Stage3/results_indicator026_stage3y.csv",
row.names = FALSE)

# Script for DDEC Indicator 013
# Author: Gamaliel Lamboy Rodríguez
# Version: 1.0
# Description:
# This script partially automatizes the obtainment of Indicator 013 from its 
# database. It assumes an incremental updating of the data, and that the most 
# recent year of database is being manipulated. This indicator re-expresses the
# information from Indicator 009 and calculates the shares of ICT employment in
# the Intangible Assets Economy.
filters = matrix( c("R Data Files", ".RData"), byrow = TRUE, nrow = 1, ncol = 2)

# Data used is feeded and subsetted directly from the Indicator 009 results.
load( tcltk::tk_choose.files(multi = FALSE, filters = filters))

# Simplify the results.
dats1 <- dats3
dats3 <- dats1[, c("naics_code", "naics_title")]

# Create the indicator.
dats3$ICT_share <- sprintf("%1.1f%%", dats1$ICT_employees / 
dats1$total_employees * 100)

load("../Master_Scripts/SectorDescs.RData")
attach(DESCS)

dats3$naics_title <- naicslist$naics_desc[ match(dats3$naics_code,
naicslist$naics_code)]

detach(DESCS)

# Write the final results.
write.csv(dats3, "./Stage3/results_indicator013_stage3.csv", row.names = F)

# Script for DDEC Indicator 003
# Author: Gamaliel Lamboy Rodríguez
# Version: 1.0
# Description:
# This script partially automatizes the obtainment of Indicator 003 from its 
# database. It assumes an incremental updating of the data, and that the most 
# recent year of database is being manipulated. This indicator displays the
# total amount of jobs in EAI-related occupations across all industries in the
# economy.

# Preload additional packages to use.
library(openxlsx)

# Parameters used to read the data.
PARAMS <- list(
startRow = 1,
sheet = 1,
colNames = TRUE,
rowNames = FALSE
)

attach(PARAMS)

# Read the original data.
dats1 <- do.call(read.xlsx, c( PARAMS, list( xlsxFile = 
tcltk::tk_choose.files(multi = FALSE))) )

detach(PARAMS)

# Rename the variables to correspond with the Data Dictionary.
colnames(dats1) <- scan( file = "./Stage1/Changed_Names", sep = "\n", 
what = "")

# Stage 1 output -- for verification purposes only. Can be omitted.
# write.csv( dats1, "./Stage1/database_indicator001_stage1.csv", row.names = F)

dats2 <- dats1;

# Read the code list.
codelist_occ <- scan( file = "./Stage2/Codelist_SOC", sep = "\n", quote = "\"",
what = "")

# Subset the data.
dats3 <- dats2[ dats2$state_code == "PR" & dats2$occupational_code %in% 
codelist_occ,c("occupational_code", "occupational_code_title", 
"total_employment", "annual_mean_wage")]

# Format it properly (will produce NA's if not numeric or blank).
dats3$total_employment <- as.numeric(dats3$total_employment)

# Write the final results.
write.csv( dats3, "./Stage3/results_indicator003_stage3.csv", row.names = F)

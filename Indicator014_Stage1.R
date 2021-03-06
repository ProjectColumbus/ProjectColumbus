# Script for DDEC Indicator 014
# Author: Gamaliel Lamboy Rodríguez
# Version: 1.0
# Description:
# This script partially automatizes the obtainment of Indicator 014 from its 
# database. It assumes an incremental updating of the data, and that the most 
# recent year of database is being manipulated. This indicator is the
# percentage of households with/without a high-speed internet connection.

# Preload additional packages to use.
library("openxlsx")

# Parameters used to read the original data.
PARAMS <- list(
sheet = 1,
startRow = 8,
rows = 1:29,
cols = 4,
detectDates = FALSE,
rowNames = FALSE,
colNames = TRUE
)

attach(PARAMS)

# Read the original data.
dats1 <- do.call(read.xlsx, c( PARAMS, list( xlsxFile = tcltk::tk_choose.files(
multi = FALSE) )))

detach(PARAMS)

# The changed names are inputted as row names to ease further calculations.
# dats2 changes type from data.frame to vector.
rownames(dats1) <- scan(what = "", sep = "\n", file = "./Stage1/Changed_Names")

# Convert the data to numeric type in R.
dats2 <- as.numeric(gsub("\\,","",dats1[,1]))
names(dats2) <- rownames(dats1)

# Select the variables to be used.
dats3 <- dats2[ c("total_households", "households_with_internet",
"connect_dialup", "nosubscription", "households_without_internet")]

# Calculate the indicators and join them with other relevant data.
hholds_pct_hispeed <- unname((dats2[ 2] - dats2[3]) / dats2[2] * 100)

dats3 <- c(dats3[1:2], hholds_pct_hispeed = hholds_pct_hispeed,
hholds_pct_nohispeed = 100 - hholds_pct_hispeed, dats3[4:length(dats3)])

names(dats3) <- c("Total Households", paste("Households with an Internet",
" Subscription", sep = ""), "% with High-Speed Internet", 
"% with Low-Speed Internet",
"Households with Internet Access, but No Subscription",
"Households without an Internet Connection")

dats3 <- data.frame( concept = names(dats3), value = unname(dats3))

# Write the final results.
write.csv( dats3, "./Stage3/results_indicator014_stage3y.csv", 
row.names = FALSE)

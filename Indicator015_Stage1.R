# Script for DDEC Indicator 015
# Author: Gamaliel Lamboy Rodríguez
# Version: 1.0
# Description:
# This script partially automatizes the obtainment of Indicator 015 from its 
# database. It assumes an incremental updating of the data, and that the most 
# recent year of database is being manipulated. This indicator is the
# distribution of households with/without a computer.

# Preload additional packages to use.
library("openxlsx")

# Parameters used to read the original data.
PARAMS <- list(
sheet = 1,
startRow = 8,
rows = 1:17,
cols = 4,
detectDates = FALSE,
rowNames = FALSE,
colNames = TRUE
)

attach(PARAMS)

# Read the original data.
dats1 <- do.call(read.xlsx, c( PARAMS, list(
xlsxFile = tcltk::tk_choose.files( multi = FALSE) )))

detach(PARAMS)

# The changed names are inputted as row names to ease further calculations.
# dats2 changes type from data.frame to vector.
rownames(dats1) <- scan(what = "", sep = "\n", file = "./Stage1/Changed_Names")

# Select the appropriate rows for the table. The row names were used instead
# of the original values as key fields, because the original fields relied
# on a multi-level outline and did not include all the relevant information
# for a particular data point ( they are understandable only through context
# and indentation).
dats2 <- dats1[ c("total_households",
"households_with_computer", "computer_desktoplaptop",
"computer_handheld", "computer_other", "households_without_computer"),1]

dats3 <- as.numeric( gsub("\\,", "", dats2))

# Calculate additional indicators.
dats3 <- c( dats3, pct_with_desktoplaptop = dats3[2] / dats3[1] * 100,
pct_without_computer = dats3[5] / dats3[1] * 100)
names(dats3)[1:6]  <- rownames(dats1)[c(1:3,5,7,9)]

dats3 <- dats3[ c(1,2,3, 7, 4:6, 8) ]

names(dats3) <- c("Total Households", "    Households with Computers",
"       With a Desktop/Laptop", "            As % of Total Households",
"       With a Handheld Computer", "        With Other Computer Types",
"    Households without Computers", "        As % of Total Households")

dats3 <- data.frame(concept = names(dats3), value = unname(dats3))


# Write the final results.
write.csv(dats3, "./Stage3/results_indicator015_stage3y.csv", 
row.names = FALSE)


 

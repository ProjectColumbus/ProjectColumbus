# Script for DDEC Indicator 017
# Author: Gamaliel Lamboy Rodríguez
# Version: 1.0
# Description:
# This script partially automatizes the obtainment of Indicator 017 from its 
# database. It assumes an incremental updating of the data, and that the most 
# recent year of database is being manipulated. This indicator shows the
# patent distribution by type of patent and the total count for a particular
# year.

# Preload additional packages to use.
library("openxlsx")

# Parameters used to read the original data.
PARAMS <- list(
sheet = 1,
startRow = 1,
cols = 1:9,
detectDates = FALSE,
rowNames = FALSE,
colNames = TRUE,
xlsxFile = tcltk::tk_choose.files(multi = FALSE)
)

attach(PARAMS)

# Read the original data.
dats1 <- do.call(read.xlsx, PARAMS)

detach(PARAMS)

dats3 <- dats1

# Create column with grand total, which includes both patents and statutory
# intervention registrations (SIRs).
dats3[,max(PARAMS$cols) + 1] <- rowSums( sapply(dats1[,c(7:8)], as.numeric),
na.rm = TRUE)

# Names were only changed in the dataset with created columns.
colnames(dats3) <- scan(what = "", sep = "\n", file = "./Stage1/Changed_Names")

# Select and subset the data.
dats3 <- unlist(dats3[ dats3$code == "PR",grep("patents|total|sirs",
colnames(dats3)), drop = TRUE])

names( dats3) <- c("Utility", "Design", "Plant", "Reissue",
"Total (less SIRs)", "SIRs", "Grand Total")

dats3 <- data.frame( concept = names(dats3), value = unname(dats3))

# Write the final results.
write.csv( dats3, "./Stage3/results_indicator017_stage3y.csv",
row.names = FALSE)


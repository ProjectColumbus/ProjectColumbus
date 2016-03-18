# Script for DDEC Indicator 025
# Author: Gamaliel Lamboy Rodríguez
# Version: 1.0
# Description:
# This script partially automatizes the obtainment of Indicator 025 from its 
# database. It assumes an incremental updating of the data, and that the most 
# recent year of database is being manipulated. This indicator measures the
# fall enrollment for science, engineering, technology and mathematics.

# Preload additional packages to use.
library("openxlsx")

# Parameters used to read the original data.
PARAMS <- list(
sheet = 1,
startRow = 1,
rows = 1:5,
cols = 1:3,
xlsxFile = tcltk::tk_choose.files( multi = FALSE)
)

attach(PARAMS)

# Read the original data.
dats1 <- do.call( read.xlsx, PARAMS)

detach(PARAMS)

head(dats1)

# The original file has a composite index called "Variable", which
# needs to be split into different categories. This variable is a regex string
# which decomposes the index into each its components for referencing later.
# These are the components:
# 1. (Grand total) -- none (unused)
# 2. ([0-9]{2}\\.0000) -- CIP_code (used)
# 3. (.+)\\, -- CIP_desc (used)
# 4. (All students total) -- educ_level (used)
# 5. \\(([0-9]{2})\\) -- year (used)
var_split <- paste("^(Grand total) \\- ([0-9]{2}\\.0000)\\-(.+)\\, (All ",
"students total) \\- \\(([0-9]{2})\\)$", sep = "")

# Components 2 through 5 are extracted to make the index columns (see above 
# comment).
var <- lapply( c(4,2,3,5), function(y)
{
    gsub( var_split, paste( "\\", y, sep = ""), dats1[,1])
})

# Binding of the information to the index columns.
dats1 <- cbind( do.call(cbind, var), dats1[,-1])

# Renaming the columns
colnames(dats1) <- scan(what = "", sep = "\n", file = "./Stage1/Changed_Names")

dats2 <- dats1

# A naive assumption was made to convert 2-digit years into four-digit ones: a 
# year number below 30 must refer to years from 2000 onwards, and to the 19**'s
# otherwise. This can be refined later.
dats2$year <- ifelse( as.numeric(gsub("\\(|\\)", "", dats2$year)) < 30, 
gsub("([0-9]{2})", "20\\1", dats2$year), gsub("([0-9]{2})", "19\\1", 
dats2$year))

# Select the columns to use.
dats3 <- dats2[,c(-1,-6)]
dats3$CIP_code <- gsub("\\.0000$", "", as.character(dats3$CIP_code))

load("../Master_Scripts/SectorDescs.RData")
attach(DESCS)

dats3$CIP_desc <- ciplist$cip_desc[ match( dats3$CIP_code, ciplist$cip_code) ]

detach(DESCS)
Write the final results.
write.csv(dats3, "./Stage3/results_indicator025_stage3y.csv",row.names = FALSE)


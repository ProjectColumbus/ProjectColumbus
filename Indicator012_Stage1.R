# Script for DDEC Indicator 012
# Author: Gamaliel Lamboy Rodríguez
# Version: 1.0
# Description:
# This script partially automatizes the obtainment of Indicator 012 from its 
# database. It assumes an incremental updating of the data, and that the most 
# recent year of database is being manipulated. This indicator is the number
# of completions by type.

# Preload additional packages to use.
library("openxlsx")

# Parameters used to read the original data.
PARAMS <- list(
sheet = 1:5,
startRow = 1,
cols = 1:4,
xlsxFile = tcltk::tk_choose.files(multi = FALSE)
)

attach(PARAMS)

# Read the original data.
dats1 <- lapply( sheet, function(x) 
{
    tmp <- do.call(read.xlsx, c(PARAMS[-1], list(sheet = x)))
    tmp$Variable <- gsub("^ +| +$", "", tmp$Variable)
    tmp
})

detach(PARAMS)

dats1 <- do.call(rbind, dats1)

head(dats1)

# The original file has a composite index called "Variable", which
# needs to be split into different categories. This variable is a regex string
# which decomposes the index into each its components for referencing later.
# These are the components:
# 1. (Grand total) -- none (unused)
# 2. (First major) -- first_second_major (used)
# 3. (.+)\\, -- cip_description (used)
# 4. A combination of groups 5 and 6 (see below) (unused)
# 5. (Bachelor|Master|Doctor) -- level (used)
# 6. (.*) -- additional characterization of doctor's degrees (unused)
# 7. (\\([0-9]{2}\\)) -- the year (used)
var_split <- paste("(Grand total) \\- (First major)\\, (.+)\\, ",
"((Bachelor|Master|Doctor)(.*)) \\- (\\([0-9]{2}\\))", sep = "")

# Components 2,3,5, and 7 are extracted to make the columns (see above
# comment).
var <- lapply( c(2:3,5,7), function(y)
{
    gsub( var_split, paste( "\\", y, sep = ""), dats1$Variable)
})

# Reordering of the columns and binding of the information to the index.
dats1 <- cbind( do.call(cbind, var)[,c(3,1,2,4)], dats1[,-1])

# Renaming the columns.
colnames(dats1) <- scan(what = "", sep = "\n", file = "./Stage1/Changed_Names")

dats2 <- dats1

# A naive assumption was made to convert two-digit years into 4-digits: any
# year number below 30 must refer to years from 2000 onwards, and is from the
# 19**'s otherwise. Can be refined later.
dats2$year <- ifelse( as.numeric(gsub("\\(|\\)", "", dats2$year)) < 30,
gsub("\\(([0-9]{2})\\)", "20\\1", dats2$year), gsub("\\(([0-9]{2})\\)",
"19\\1", dats2$year))

dats3 <- dats2

# The doctor's degrees were originally divided in various types: research,
# professional practice and other. We do not require this level of
# segmentation, and thus must aggregate all these levels according to the
# index components.
dats3 <- split(dats3, dats3$level)

# A "cheat" is made to the aggregate() function, in order to disallow it from
# removing the index columns. We use all the index columns, even though only
# the cip_description is the only column that counts.
dats3$Doctor <- aggregate(dats3$Doctor[,-c(1:4)], by =
dats3$Doctor[,1:4], FUN = sum, na.rm = T, sort = F)

# Create the final dataset.
dats3 <- do.call(rbind, dats3)
rownames(dats3) <- NULL

load("../Master_Scripts/SectorDescs.RData")
attach(DESCS)

dats3$cip_description <- ciplist$cip_desc[ match(tolower(
dats3$cip_description), tolower(ciplist$cip_desc))]

dats3 <- data.frame( cip_code = ciplist$cip_code[  match(tolower(
dats3$cip_description), tolower(ciplist$cip_desc)) ], dats3, stringsAsFactors =
FALSE)

detach(DESCS)

dats3 <- dats3[ ,c(1,4,2,5:ncol(dats3))]
dats3[ is.na(dats3) ] <- 0

# Save as .RData, as this will be used in other indicators.
save(dats3, file = "./Stage3/database_indicator012_stage3y.RData")

# Write the final results.
write.csv( dats3[,-c(5,7)], "./Stage3/results_indicator012_stage3y.csv",
row.names = F)

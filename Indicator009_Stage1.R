# Script for DDEC Indicator 009
# Author: Gamaliel Lamboy Rodríguez
# Version: 1.0
# Description:
# This script partially automatizes the obtainment of Indicator 009 from its 
# database. It assumes an incremental updating of the data, and that the most 
# recent year of database is being manipulated. This indicator cross-tabulates
# two (2) important employment classifications, the NAICS code and the Major
# Occupational Group (SOC codes).

# Preload additional packages to use.
library("openxlsx")

# Parameters used to read the data.
PARAMS <- list(
sheet = 1:3,
startRow = 1,
colNames = TRUE,
rowNames = FALSE,
xlsxFile = tcltk::tk_choose.files( multi = FALSE)
)

attach(PARAMS)

# Read the list of sheets using the "sheet" parameter. All files are simply
# a splice of a larger file, and thus share the same structure.
dats1 <- lapply(PARAMS$sheet, function(x) do.call( read.xlsx, c( list( 
sheet = x), PARAMS[-1] )) )

cnames <- Reduce(function(x, y) intersect(x,y), lapply(dats1, colnames))
dats1 <- lapply(dats1, function(x) x[,cnames])

detach(PARAMS)

dats1 <- do.call(rbind, dats1)

# Rename the variables to correspond with the Data Dictionary.
colnames(dats1) <- scan( file = "./Stage1/Changed_Names", sep = "\n", 
what = "")

# Stage 1 output -- for verification purposes only. Can be omitted.
# write.csv( dats1, "./Stage1/database_indicator009_stage1.csv", row.names = F)

# Read the code lists.
codelist_naics <- scan( file = "./Stage2/Codelist_NAICS", sep = "\n", 
what = "")
codelist_occ <- scan( file = "./Stage2/Codelist_SOC", sep = "\n", what = "")

dats2 <- dats1[ dats1$area_code == "72",]

# Non-numeric codes are assumed either non-disclosed or 0 employees; both are
# irrelevant to further calculations, and thus are assigned NA's.
dats2$total_employees[ grep("[^0-9]", dats2$total_employees)] <- NA
dats2$annual_mean_wage[ grep("[^0-9]", dats2$annual_mean_wage)] <- NA

dats2$total_employees <- as.numeric(dats2$total_employees)

# NAICS codes must be trimmed of trailing zeroes for stem-searching to
# work.
naics0 <- gsub("0+$", "", dats2$naics_code)

# Stem-and-leaf search of selected_naics codes. 
naics <- sapply( codelist_naics, function(x)
{
    naics_sub <- substring(x, 1, 2:nchar(x))
    matchnaics <- naics0[ naics0 %in% naics_sub]
    matchnaics[ which.max( nchar(matchnaics)) ]
})

# Filter for the relevant data and columns. Sector totals are also included as
# SOC code "00-0000".
dats3 <- dats2[ dats2$area_code == "72" & naics0 %in% naics &
dats2$occupational_code %in% c(codelist_occ,"00-0000"), c("naics_code", 
"naics_title", "occupational_code", "occupational_title", "total_employees", 
"annual_mean_wage")]

# Create an instance for storing the total amount of employees.
dats3i1 <- dats3[ dats3$occupational_code == "00-0000", c("naics_code",
"naics_title", "total_employees")]

# Trailing spaces must be removed from the codes in the final instance, as the
# data in dats2 was never modified (only a copy, naics0)
dats3i1$naics_code <- gsub("0+$", "", dats3i1$naics_code)

# Aggregate ICT occupations (includes the totals for now).
dats3i2 <- tapply( dats3$total_employees, gsub("0+$", "", 
dats3$naics_code), sum, na.rm = T)

# Subtract the totals from the previous aggregation, to leave only the
# ICT occupations.
dats3i2 <- dats3i2[ match( dats3i1$naics_code, names(dats3i2))] - 
dats3i1$total_employees

# Combine the ICT employees and total employees into the stage 3 output.
dats3 <- cbind( dats3i1, ICT_employees = dats3i2)

dats3$ICT_employees_pct_share <- prop.table(dats3$ICT_employees)

load("../Master_Scripts/SectorDescs.RData")

attach(DESCS)

dats3$naics_title <- naicslist$naics_desc[ match( dats3$naics_code,
naicslist$naics_code) ]

detach(DESCS)

dats3 <- dats3[ order(dats3$naics_code),]

# Save data (for use in other indicators).
save(dats3, file = "./Stage3/database_indicator009_stage3y.RData")

# Write the final results.
write.csv( dats3, "./Stage3/results_indicator009_stage3y.csv", row.names = F)

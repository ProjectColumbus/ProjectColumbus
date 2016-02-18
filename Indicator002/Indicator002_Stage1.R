# Script for DDEC Indicator 002 -- Stage 1
# Author: Gamaliel Lamboy Rodríguez
# Version: 1.0
# Description:
# This script partially automatizes the obtainment of Indicator 002 from its 
# database. It assumes an incremental updating of the data, and that the most 
# recent year of database is being manipulated. Time trends are handled by a
# master script. However, the resulting files are created so that they can
# afterwards be merged in a cumulative (time-series) dataset.

# The following script produces the Stage 1 output for the series. It ends with
# a call to the Stage 2 Script. However, this call is not yet functional until
# the DATADIR and SCRIPTDIR variables have been set in the master script. For
# now, they have to be hard-coded into the Stage 1 dataset.
DATADIR <- "~/Documents/Cuentas Satélite/Scripts File/DATA"
SCRIPTDIR <- "~/Documents/Cuentas Satélite/Scripts File/prep_scripts"
# DATADIR -- directory from Master Script
setwd( paste(DATADIR, "/Indicator002", sep = ""))

#+ List of database parameters to be considered when importing the Excel
#+ Workbook:
#+
#+ startrow -- the starting row from which to read the worksheet.
#+ sheet -- a numeric value, specifying the worksheet index from which to
#+ retrieve the data.
#+ colnames -- should the first row be treated as a header? Since the header
#+ row will be automatically generated from the Changed_Names list, this is set
#+ to FALSE.
#+ rownames -- should the first column be treated as row names? No rownames are
#+ needed for this file, hence it is set to FALSE. In any case, rownames in R
#+ are best treated as an additional variable.
#+ rows -- an array specifying the rows to be imported.
#+ cols -- an array specifying the columns to be imported.
#+ detectdates -- should R attempt to detect dates automatically? Dates were
#+ not used for this file, hence this functionality is set to FALSE.
#+ year -- optional numeric value for the year of the dataset used.
PARAMS <- list(
startrow = 3, 
sheet = 1, 
colnames = TRUE,
rownames = FALSE,
cols = 1:4,
detectdates = FALSE,
year = 2015,
quarter = 1
)

# Required packages for the R-code: openxlsx and tcltk. openxlsx serves to
# open .xlsx files, and tcltk gives access to basic graphical capabilities in R.
library("openxlsx")
library("tcltk")

# Attach the database parameters
attach(PARAMS)

# Read the variable listing in  Original_Data/Variable List.xlsx, using PARAMS
var_list <- read.xlsx( "./Original_Data/Variable List.xlsx", sheet = sheet, 
startRow = startrow, colNames = colnames, rowNames = rownames, detectDates = 
detectdates, cols = cols )

# PARAMS no longer needed
detach(PARAMS)

# Read the original data from the ES-202 bytestream. The fileEncoding was
# chosen based upon a program which outputted this as input format, but should be
# chosen on a case-by-case basis.
dats1 <- scan(file = "./Original_Data/Indicator 002 Database", what = "",    
sep = "\n", nlines = 100000, fileEncoding = "latin-9")

# Begin a loop throughout the list of variables, and allocate space for the
# operation in the object 'dats1'. NOTE: This replaces the previous object
# named 'dats1' with a new one, to save memory space.
dats1 <- lapply( 1:nrow(var_list), function(x)
{
#+ Each variable needs to be retrieved from the bytestream by "cutting off" the
#+ variable at the specified beginning and ending character values. Luckily,
#+ the substring() function is already vectorized, meaning that the entire
#+ column can be selected in one command, without poring over each observation.
    substring(dats1, var_list[x,2], var_list[x,3] )
})

# Create a data frame from these variables, and add the changed names from
# var_list.
dats1 <- do.call(cbind, dats1)
dats1 <- as.data.frame(dats1, stringsAsFactors = FALSE)
colnames(dats1) <- var_list$varname

# Convert every column of employment to numeric.
dats1[, grep("^emp_m[1-3]$|^tot_wages$", colnames(dats1)) ] <- sapply( grep(
"^emp_m[1-3]$|^tot_wages$", colnames(dats1) ), function(x)
as.numeric(dats1[,x]) )

# Output the file as a csv, for raw-data backup and (perhaps) manual validation
# purposes.
write.csv(dats1, "./Stage1/database_indicator002_stage1.csv", row.names = FALSE)

DATS1 <- new.env()
with(DATS1,
{
    dats1 = dats1;
    DATADIR = DATADIR;
    SCRIPTDIR = SCRIPTDIR;
    var_list = var_list
})

rm(dats1, DATADIR, SCRIPTDIR, var_list); attach(DATS1);
# Proceed with Stage 2.
# source( paste(SCRIPTDIR, "/Indicator002/Indicator002_Stage2.R", sep = ""))

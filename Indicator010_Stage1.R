# Script for DDEC Indicator 010
# Author: Gamaliel Lamboy Rodríguez
# Version: 1.0
# Description:
# This script partially automatizes the obtainment of Indicator 010 from its 
# database. It assumes an incremental updating of the data, and that the most 
# recent year of database is being manipulated. This indicator shows the
# educational attainment by age cohorts, as obtained from the Census data in
# .xls(x) files.

# Preload additional packages to use.
library("openxlsx")

# Parameters used to read the data.
PARAMS <- list(
startRow = 10,
sheet = 1,
colNames = FALSE,
rowNames = FALSE,
rows = c(1:14,16:23,28:30,32:34,36:38,40:42,45:48,51:56),
cols = c(1,4)
)

attach(PARAMS)

# Read the original data.
dats1 <- do.call( read.xlsx, c( list( xlsxFile = 
"./Original_Data/Indicator 010 Database.xlsx"), PARAMS))

detach(PARAMS)

# The variables had changed names with specific monemes, which were used to
# group the particular variables. The variable 'id' is simply a vector with
# said monemes.
id <- c("18t24","25mt", "25t34", "35t44", "45t64", "65mt", "poverty_rate",
"median_wage")

# Construct the final labels for the row variable groups.
labels <- paste("Educational Attainment -- ", gsub("([0-9]{2})t([0-9]{2})",
"\\1 to \\2 years old", id[1:6]), sep = "")
labels <- gsub("([0-9]{2})mt", "\\1 years old or more", labels)
labels <- c(labels, "Poverty Rate for the Population 25 and over",
"Median Earnings")

# Rename the variables.
change_names <- scan( what = "", sep = "\n", file = "./Stage1/Changed_Names")

# Creation of the final data frame. A title is placed before each group of
# variables.
component_list <- lapply( 1:length(id), function(x)
{

# For age groups, find the rows with "pct_" in their name.
    if( x <= 6)
    {
        tmp1 <- dats1[ grep( paste( "pct_", id[x], sep = ""), 
        change_names),]
# Non-age groups had the full name specified, not a moneme. Find them
# directly in the dataset.
    } else
    {
        tmp1 <- dats1[ grep( id[x], change_names), ]
    }
    
    rbind( c(X1 = labels[x], X2 = ""), tmp1)
})

# Create final data frame, relabel, and write to .csv.
dats3 <- do.call(rbind, component_list)
colnames(dats3) <- c("Cohort", "Percentage of Respective Population")

write.csv( dats3, "./Stage3/results_indicator010_stage3.csv", row.names = F)

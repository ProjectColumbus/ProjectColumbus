# Script for DDEC Indicator 018
# Author: Gamaliel Lamboy Rodríguez
# Version: 1.0
# Description:
# This script partially automatizes the obtainment of Indicator 018 from its 
# database. It assumes an incremental updating of the data, and that the most 
# recent year of database is being manipulated. This indicator measures the
# academic and science output per 100,000 inhabitants, as obtained from the
# Current Population Survey and the National Science Foundation.

# Preload additional packages to use.
library("openxlsx")

# This indicator has multiple sources, therefore PARAMS is a nested list,
# with each component having its respective parameters.
PARAMS <- list(
    dats1c1 = list(
        startRow = 5,
        rows = 1:5,
        cols = c(4,9:12),
        sheet = 1,
        rowNames = FALSE,
        colNames = FALSE
    ),
# Commented out, as it is no longer needed. See lines 67-71.
#     dats1c2 = list(
#         startRow = 4,
#         rows = c(4,58),
#         cols = 1:13,
#         sheet = 2,
#         rowNames = TRUE,
#         colNames = TRUE
#     ),
    dats1c3 = list(
        startRow = 4,
        rows = c(4,58),
        cols = 1:10,
        sheet = 3,
        rowNames = TRUE,
        colNames = TRUE
    )
)

# Read the original data.
dats1 <- lapply( PARAMS, function(x) 
{
    do.call( read.xlsx, c(x, list( 
    xlsxFile = "./Original_Data/Indicator 018 Database.xlsx")) )
})

# The first source was not retrieved by name, due to an incongruent
# naming convention with the names. Therefore, they were constructed
# manually.
colnames(dats1[[1]]) <- seq( 2010, 2010 + ncol( dats1[[1]] ) - 1, 1)

dats2 <- dats1

# Convert data to numeric type in R.
dats2[[1]][,1:ncol(dats2[[1]])] <- sapply( 1:ncol(dats2[[1]]), function(x)
{
    as.numeric( gsub( "\\,", "", dats2[[1]][,x]))
})

# Select only the years for which all sources have data values.
dats_yrs <- Reduce(function(x,y) intersect(x,y), sapply( dats1, colnames))

# Originally, it was thought that the data for component 3 only came in
# the form of a ratio of articles to 1,000 doctorate degree holders. 
# Therefore, component 2 was created to approximate the number of academic
# output, and then calculate the indicator. However, this is not the case,
# and the code now uses the academic output directly from the data.
dats3 <- as.matrix( dats2[[3]][,dats_yrs] / dats2[[1]][,dats_yrs] * 1e5 )
rownames(dats3) <- dats_yrs
colnames(dats3) <- gsub("\n", "", "Academic Science and Engineering Output per 
100,000 Inhabitants")

# Write the final results.
write.csv(as.matrix(dats3), "./Stage3/results_indicator018_stage3.csv")

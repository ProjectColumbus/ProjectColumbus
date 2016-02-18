# Script for DDEC Indicator 002 -- Stage 3
# Author: Gamaliel Lamboy Rodríguez
# Version: 1.0
# Description:
# This script partially automatizes the obtainment of Indicator 002 from its
# database. It assumes an incremental updating of the data, and that the most
# recent year of database is being manipulated. Time trends are handled by a
# master script. However, the resulting files are created so that they can
# afterwards be merged in a cumulative (time-series) dataset.
# The following script produces the Stage 3 output for the series, building
# from the Stage 2 output.

# Introduction to Stage 3 Output
# The Stage 3 results arise from combining three (3) different types of
# observational instances: Firms with Mother Company (County Code 900),
# Entrepreneurs and Single-Establishment Firms. Each one is treated in a
# separate data.frame, which can be written as .csv for validation purposes.
# The output file (dats3_final) consists of the sum of these three (3) instances.

if( !"DATS2" %in% search() ) 
{
    attach(DATS2)
}
# Subset the data frame for the stage 2 NAICS codes.
dats3 <- dats2[ dats2$NAICS %in% naics$naics_recode & dats2$ownership_code == 
"5", ]
# Validation 1: Each NAICS included *must* consist of digits, not letters, etc.
dats3 <- dats3[ grep("[0-9]", dats3$NAICS), ]

# Instance 1 Created: Firms with a Mother Company (County Code 900). The
# aggregate data is used for these firms, as it is deemed more reliable than
# manually adding up their establishments.
dats3_900corps <- dats3[ dats3$county_code == "900", ]

# Create list of entrepreneurs, which are defined as the EINs with more than 1
# establishment and which do not have a County Code 900.
entrepr_list <- table( dats3$EIN[ !dats3$EIN %in% dats3_900corps$EIN ] )
entrepr_list <- names(entrepr_list[ entrepr_list > 1 ])

# Instance 2 Created: Entrepreneurs (Count of EINs > 1)
dats3_entrepr <- dats3[ dats3$EIN %in% entrepr_list, ]

# Instance 3 Created: Single-Establishment Firms.
dats3_one_estab <- dats3[ !dats3$EIN %in% union( dats3_900corps$EIN,
dats3_entrepr$EIN), ]

# Instance List

instance_list <- list( "900corps" = dats3_900corps, entrepr = 
dats3_entrepr, single_estab = dats3_one_estab)

# Aggregation

result_list <- lapply(instance_list, function(x) 
{
    tmp <- x
    tmp$NAICS <- naics$naics_orig_from_list[ match( tmp$NAICS,
    naics$naics_recode)]
    
    tmp <- aggregate( tmp[, c( grep( "^emp_m[1-3]$", colnames(tmp), 
    value = T), "tot_wages")], by = list( NAICS = tmp$NAICS), FUN = sum, 
    na.rm = T)
    
    tmp
})

# R Image of Instances Made for Future Indicator Calculations

save( dats3, instance_list, result_list, DATS2, file = gsub("\n", "", "./Stage3/
database_indicator002_stage3.RData"))

# Calculate Output of 3 Results

dats3 <- do.call(rbind, result_list)
dats3 <- aggregate( dats3[, -grep("NAICS", colnames(dats3))], by = list(
NAICS = dats3$NAICS), FUN = sum, na.rm = T)

write.csv(dats3, "./Stage3/results_indicator002_stage3.csv", row.names = F)

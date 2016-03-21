# Script for DDEC Indicator 002 -- Stage 2
# Author: Gamaliel Lamboy Rodríguez
# Version: 1.0
# Description:
# This script partially automatizes the obtainment of Indicator 002 from its
# database. It assumes an incremental updating of the data, and that the most
# recent year of database is being manipulated. Time trends are handled by a
# master script. However, the resulting files are created so that they can
# afterwards be merged in a cumulative (time-series) dataset.
# The following script produces the Stage 2 output for the series, building
# from the Stage 1 output.


# Copy the object to avoid destructive editing.
dats2 <- dats1

# Read the selected NAICS codes from a text file.
codelist_naics <- scan(file = "./Stage2/Codelist_NAICS", what = "", sep = "\n")

# Create a list of 6-digit NAICS codes whose "stems" are the selected NAICS
# codes. This is done via a loop, which is described below.
# Initialized variables in for loop:
# naics -- list of all matched NAICS codes.
# naics_stem -- placeholder for the "stems" of NAICS codes, of length nchar(x)
# tmp -- a placeholder for the NAICS code being matched.
naics <- list()
naics_stem <- character()
tmp <- character()

# Loop through all the selected NAICS codes:
for( x in 1:length(codelist_naics))
{
#+ Select the NAICS code to match.
    tmp <- codelist_naics[x]
#+ 1) Substring the NAICS codes in dats2 from the first character, up to the
#+ number of characters in x.
    naics_stem <- substring( dats2$NAICS, 1, nchar(tmp))
#+ 2) Select the NAICS whose naics_stem matches x.
    naics[[x]] <- unique(dats2$NAICS[ naics_stem == tmp])
#+ 3) label each value in naics[[x]] with x, the matched naics code.
    names(naics[[x]]) <- rep(tmp, length(naics[[x]]))
}

# Remove the placeholders from the previous loop.
rm(tmp, naics_stem)

# Create a data.frame object with two (2) columns, holding the matched NAICS
# code and the matching codes from dats2$NAICS.
naics <- data.frame( naics_orig_from_list = names(unlist(naics)), 
naics_recode = unlist(naics), stringsAsFactors = FALSE)

DATS2 <- new.env()
with(DATS2,
{
    dats2 = dats2;
    naics = naics;
    codelist_naics = codelist_naics;
})

rm(naics, codelist_naics, dats2,x); attach(DATS2)

# Output the list for validation purposes.
write.csv( naics, "./Stage2/naics_codes_used.csv", row.names = FALSE)

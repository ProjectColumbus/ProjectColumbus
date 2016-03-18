# Script for DDEC Indicator 001
# Author: Gamaliel Lamboy Rodríguez
# Version: 1.0
# Description:
# This script partially automatizes the obtainment of Indicator 001 from its 
# database. It assumes an incremental updating of the data, and that the most 
# recent year of database is being manipulated. For time trends, the user must 
# supply the database year, which is then assigned as the main variable name. 
# The resulting file can afterwards be joined with the cumulative 
# (time-series) dataset.

#+ Set the working directory to Indicator001
DATADIR <- tcltk::tk_choose.dir()
setwd( paste( DATADIR, "/Indicator001", sep = ""))

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
year = NULL,
startRow = 6, 
sheet = 3,
colNames = FALSE,
rowNames = FALSE,
rows = 1:405,
cols = 1:19,
detectDates = FALSE
)

#+ An R package called "openxlsx" was made use of, in order to import Excel 
#+ spreadsheets.
library("openxlsx")

#+ The parameters are attached to the R search path, in order to facilitate 
#+ their call when reading the file. By being attached, one need not directly 
#+ reference the parent object when calling their values. The maintainability 
#+ and the ease of use of the code are deemed more important than the risk 
#+ involved with indirect referencing in this situation.
attach(PARAMS)

#+ Using the read.xlsx() function, the original Excel Workbook was transformed 
#+ into a data.frame object in R, using the parameters given in PARAMS.
dats1 <- do.call( read.xlsx, c( list( xlsxFile = 
tcltk::tk_choose.files(multi = FALSE)), PARAMS[-1]))
#+ Detach PARAMS from the R search path for the rest of the procedure.
detach(PARAMS)

#+ Apply the changed names to each field. Consult the Data Dictionary.
colnames(dats1) <- scan( file = "./Stage1/Changed_Names", sep = "\n", what = "")

#+ Stage 1 Complete -- Write Stage 1 dataset as intermediate output.
write.csv( dats1, "./Stage1/database_indicator001_stage1.csv", row.names = F)

#+ A copy of dats1 is made, to ensure non-destructive manipulations.
dats2 <- dats1;

#+ The list of selected NAICS codes is read as a plain text file.
codelist_naics <- scan( file = "./Stage2/Codelist_NAICS", sep = "\n", what = "")

#+ Remove trailing zeroes from the codes: see the Data Dictionary for variable
#+ 'NAICS Code'.
naics0 <- gsub( "0+$", "", dats2$naics_code)

#+ A stem-and-leaf recoding of the selected NAICS codes was performed to bridge 
#+ between the level of detail supplied in the dataset and the level of detail 
#+ required in codelist_naics. It was programmed using the 
#+ following algorithm:

#++ 1) Create a vector object named naics1. 
#+++ Vector objects are the basic type 
#+++ of object in R. Even scalars are treated as length-1 vectors in R. Every 
#+++ vector object in R has a length attribute, a type attribute and an index 
#+++ attribute, akin to a basic array in C++. However, R imposes much stricter 
#+++ controls on memory and indices, similar to other object-oriented languages.
#++ 2) Loop through each of the selected NAICS codes, with placeholder 'x'.
naics1 <- sapply( codelist_naics, function(x) 
{

#++ 3) Create a list object named 'matchnaics'. List objects are higher-level 
#++ vectors which do not require a type attribute, and thus can carry any type
#++ of object as an element. They can also carry multiple different object
#++ types.
#++ 4) Loop placeholder 'y' through the sequence from 2 to the total number of 
#++ characters in x.
    matchnaics <- lapply( 2:nchar(x), function(y)
    {
    
#++ 5) Generate a substring of x from the first digit to the y-eth digit. This 
#++ substring is named 'naics_sub'.
        naics_sub <- substring( x, 1, y )
        
#++ 6) Find naics_sub in the dataset. If found, return naics_sub; if not, 
#++ return NULL.
        naics0[ naics0 == naics_sub ]
    })
    
#++ 7) Fill matchnaics with the results from step 6. NULL values are 
#++ automatically removed by R in this process.
#++ 8) Transform the dynamic array into a vector object for easier subsetting 
#++ operations.
    matchnaics <- unlist(matchnaics)
    
#++ 9) Return the longest character string in matchnaics, or the longest "stem" 
#++ between the selected NAICS code x and the available NAICS codes in dats2.
    matchnaics[ which.max( sapply(matchnaics, nchar))]
})
#++ 10) Fill naics1 with the results from step 9.

#+ Stage 2 Complete -- Write naics1 as intermediate output.
write.csv( data.frame( naics_orig_from_list = names(naics1), 
naics_recode = naics1, stringsAsFactors = F), "./Stage2/naics_codes_used.csv", 
row.names = F)

#+ Some selected NAICS codes refer to the same "stem" in naics1; hence, 
#+ deduplication is necessary to avoid double counting.
naics1 <- unique(naics1)

save(naics1, dats2, codelist_naics, file = 
"./Stage2/database_indicator001_stage2.RData")

#+ Create Stage 3 dataset -- select the information using the recoded keys in 
#+ naics1, then join the columns "naics_desc" and "gross_prod" (from dats2) 
#+ based upon this key. This new working dataset is called dats3.
dats3 <- data.frame( naics_code = naics1, naics_desc = dats2[ match( naics1, 
naics0), "naics_desc"], gross_prod_nominal = dats2[ match( naics1, naics0), 
"gross_prod"] )

dats3$gross_prod_share <- prop.table(dats3$gross_prod_nominal)
dats3 <- dats3[ order( dats3$naics_code),]

#+ If a year was specified, replace the column_name "gross_prod_nominal" with 
#+ said year.
if( !is.null(PARAMS$year) ) colnames(dats3)[3] <- as.character( PARAMS$year)

load("../Master_Scripts/SectorDescs.RData")
attach( DESCS)

dats3$naics_desc <- DESCS[[2]]$naics_desc[ match(dats3$naics_code,
DESCS[[2]]$naics_code)]

detach(DESCS)

dats3 <- dats3[ order(dats3$naics_code),]
#+ Stage 3 Complete -- Write dats3 as final output
write.csv( dats3, "./Stage3/results_indicator001_stage3y.csv", row.names = F)

#+ Back Up All Procedures in an R Workspace File
save.image("Indicator001.RData")

library("openxlsx")

PARAMS <- list(
startrow = 1,
sheet = 1:3,
colnames = TRUE,
rownames = FALSE,
year = NULL
)

attach(PARAMS)

dats1 <- lapply(sheet, function(x) read.xlsx( "./Original_Data/Indicator 009 Database.xlsx", 
startRow = startrow, sheet = x, colNames = colnames, rowNames = rownames) )

detach(PARAMS)

dats1 <- do.call(rbind, dats1)
colnames(dats1) <- scan( file = "./Stage1/Changed_Names", sep = "\n", what = "")

write.csv( dats1, "./Stage1/database_indicator009_stage1.csv", row.names = F)

codelist_naics <- scan( file = "./Stage2/Codelist_NAICS", sep = "\n", what = "")
codelist_occ <- scan( file = "./Stage2/Codelist_SOC", sep = "\n", what = "")

dats2 <- dats1
 
dats2$total_employees[ grep("[^0-9]", dats2$total_employees)] <- NA
dats2$annual_mean_wage[ grep("[^0-9]", dats2$annual_mean_wage)] <- NA

naics0 <- gsub("0+$", "", dats2$naics_code)

naics <- sapply( codelist_naics, function(x)
{
    naics_sub <- substring( x, 1, 2:nchar(x))
    matchnaics <- naics0[ naics0 %in% naics_sub ]
    matchnaics[ which.max( sapply(matchnaics, nchar))]
})



dats3 <- dats2[ dats2$area_code == "72" & naics0 %in% naics &
dats2$occupational_code %in% codelist_occ, c("naics_code", "naics_title", 
"occupational_code", "occupational_title", "total_employees", 
"annual_mean_wage")]

dats3$naics_code <- gsub("0+$", "", dats3$naics_code)

write.csv( dats3, "./Stage3/results_indicator009_stage3.csv", row.names = F)

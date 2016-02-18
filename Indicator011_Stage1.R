library("openxlsx")

PARAMS <- list(
startrow=1,
sheet=1,
rownames = FALSE,
colnames = FALSE,
cols = c(1:12,14)

)

attach(PARAMS)

dats1 <- read.xlsx( "./Original_Data/Indicator 011 Database.xlsx", startRow =
startrow, sheet = sheet, rowNames = rownames, colNames = colnames, cols = cols)

detach(PARAMS)

head(dats1)

dats1_naics <- grep("(^[0-9]{4}$)|(^[0-9]{2}\\-[0-9]{2})|(^[0-9]{2}$)", 
dats1[,1])
dats1_comp <- grep("Compensación a empleados", dats1[,2])
dats1_dist <- sapply(dats1_naics, function(x) 
{
    min(dats1_comp[dats1_comp > x] - x)
})

dats1 <- data.frame( dats1[ dats1_naics,c(1,13)], dats1[ dats1_naics + dats1_dist, 3:12])

colnames(dats1) <- c( scan(what = "", sep = "\n", file = "./Stage1/Changed_Names"),
paste("year_", 2005:2014, sep = ""))

codelist_naics <- scan(what = "", sep = "\n", file = "./Stage2/Codelist_NAICS")
naics0 <- gsub( "0+$", "", dats1$naics_code)


naics <- sapply(codelist_naics, function(x)
{
    naics_sub <- substring(x, 1, 2:nchar(x))
    matchnaics <- naics0[ naics0 %in% naics_sub ]
    matchnaics[ which.max( sapply(matchnaics, nchar)) ]
})

dats3 <- dats1[ naics0 %in% naics, c(1:2, 9:12)]

write.csv( dats3, "./Stage3/results_indicator011_stage3.csv", row.names = F)
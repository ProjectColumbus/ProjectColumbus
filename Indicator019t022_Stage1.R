library("foreign")

dats1 <- read.spss( "./Original_Data/Indicator 019t022 Database.sav", 
to.data.frame = TRUE, use.value.labels = FALSE)

changed_names <- scan(what = "", sep = "\n", file = "./Stage1/Changed_Names")

colnames(dats1) <- changed_names[ 1:ncol(dats1)]

dats2 <- dats1[, c( "total_gross_receipts", "ict_investment0", "NAICS")]

dats2$NAICS <- gsub("[^0-9]", "", dats2$NAICS)

dats2$type_ICT <- ifelse( substring(dats2$NAICS, 1, 3) %in% c("517"), 
"Communications Equipment", ifelse( substring(dats2$NAICS, 1, 4) %in% 
c("5415", "6114"), "Software", "General Equipment"))

dats3 <- prop.table(tapply( dats2$ict_investment0, dats2$type_ICT, sum, 
na.rm = T))

dats3 <- c( sum(dats2$ict_investment0, na.rm = T) / sum( na.rm = T,
dats2$total_gross_receipts), dats3)

names(dats3)[1] <- "ICT Investment (% of Total Gross Receipts)"

write.csv( dats3, "./Stage3/results_indicator019t022_stage3.csv")

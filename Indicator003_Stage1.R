library(openxlsx)

PARAMS <- list(
startrow = 1,
sheet = 1,
colnames = TRUE,
rownames = FALSE,
year = NULL
)

attach(PARAMS)

dats1 <- read.xlsx( "./Original_Data/Indicator 003 Database.xlsx", startRow =
startrow, colNames = colnames, rowNames = rownames)

detach(PARAMS)

colnames(dats1) <- scan( file = "./Stage1/Changed_Names", sep = "\n", 
what = "")

write.csv( dats1, "./Stage1/database_indicator001_stage1.csv", row.names = F)

dats2 <- dats1;

codelist_occ <- scan( file = "./Stage2/Codelist_SOC", sep = "\n", quote = "\"",
what = "")

dats3 <- dats2[ dats2$state_code == "PR" & dats2$occupational_code %in% 
codelist_occ,c("occupational_code", "occupational_code_title", 
"total_employment", "annual_mean_wage")]

dats3$total_employment <- as.numeric(dats3$total_employment)

write.csv( dats3, "./Stage3/database_indicator001_stage3.csv", row.names = F)
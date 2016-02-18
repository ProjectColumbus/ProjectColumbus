library("openxlsx")

PARAMS <- list(
sheet = 1,
startRow = 8,
rows = 1:29,
cols = 4,
detectDates = FALSE,
rowNames = FALSE,
colNames = TRUE
)

attach(PARAMS)

dats1 <- do.call(read.xlsx, c( PARAMS, list(
xlsxFile = "./Original_Data/Indicator 014 Database.xlsx")))

detach(PARAMS)

rownames(dats1) <- scan(what = "", sep = "\n", file = "./Stage1/Changed_Names")


dats2 <- as.numeric(gsub("\\,","",dats1[,1]))
names(dats2) <- rownames(dats1)

dats3 <- dats2[ c("total_households", "households_with_internet", 
"connect_dialup", "noconnect", "households_without_internet")]

hholds_pct_hispeed <- unname((dats2[ 2] - dats2[3]) / dats2[1] * 100)

dats3 <- c(dats3, hholds_pct_hispeed = hholds_pct_hispeed, 
hholds_pct_nohispeed = 100 - hholds_pct_hispeed)

write.csv( dats3, "./Stage3/results_indicator014_stage3.csv")

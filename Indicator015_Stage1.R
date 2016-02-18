library("openxlsx")

PARAMS <- list(
sheet = 1,
startRow = 8,
rows = 1:17,
cols = 4,
detectDates = FALSE,
rowNames = FALSE,
colNames = TRUE
)

attach(PARAMS)

dats1 <- do.call(read.xlsx, c( PARAMS, list(
xlsxFile = "./Original_Data/Indicator 015 Database.xlsx")))

detach(PARAMS)

rownames(dats1) <- scan(what = "", sep = "\n", file = "./Stage1/Changed_Names")

dats3 <- dats1[ c(1,3,5,7,9),1]
names(dats3)  <- rownames(dats1)[c(1,3,5,7,9)]

dats3 <- c( dats3, pct_with_computer = unname(dats2[2] / dats3[1] * 100))

dats3 <- c( dats3, pct_without_computer = unname(100 - 
dats3["pct_with_computer"]))

write.csv(dats3, "./Stage3/results_indicator015_stage3.csv")


 

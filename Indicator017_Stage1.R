library("openxlsx")

PARAMS <- list(
sheet = 1,
startRow = 1,
cols = 1:9,
detectDates = FALSE,
rowNames = FALSE,
colNames = TRUE
)

attach(PARAMS)

dats1 <- do.call(read.xlsx, c( PARAMS, list(
xlsxFile = "./Original_Data/Indicator 017 Database.xlsx")))

detach(PARAMS)

dats1[,10] <- rowSums( sapply(dats1[,c(4:9)], as.numeric), na.rm = T)

colnames(dats1) <- scan(what = "", sep = "\n", file = "./Stage1/Changed_Names")

dats3 <- unlist(dats1[ dats1$code == "PR",grep("patents|total|sirs", 
colnames(dats1))])

write.csv( dats3, "./Stage3/results_indicator017_stage3.csv", row.names = F)


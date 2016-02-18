library("openxlsx")

PARAMS <- list(
sheet = 1,
startRow = 1,
rows = 1:5,
cols = 1:3
)

attach(PARAMS)

dats1 <- do.call( read.xlsx, c( PARAMS, list(xlsxFile = 
"./Original_Data/Indicator 025 Database.xlsx")) )

detach(PARAMS)

head(dats1)

var_split <- paste("^(Grand total) \\- ([0-9]{2}\\.0000)\\-(.+)\\, (All ",
"students total) \\- \\(([0-9]{2})\\)$", sep = "")
    
var <- lapply( c(4,2,3,5), function(y)
{
    gsub( var_split, paste( "\\", y, sep = ""), dats1[,1])
})

dats1 <- cbind( do.call(cbind, var), dats1[,-1])

colnames(dats1) <- scan(what = "", sep = "\n", file = "./Stage1/Changed_Names")
# 
# dats2 <- dats1
# 
# dats2$year <- ifelse( as.numeric(gsub("\\(|\\)", "", dats2$year)) < 30, 
# gsub("\\(([0-9]{2})\\)", "20\\1", dats2$year), gsub("\\(([0-9]{2})\\)", 
# "19\\1", dats2$year))
# 
# dats3 <- dats2 
# 
# dats3 <- split(dats3, dats3$level)
# 
# dats3$Doctor <- aggregate(dats3$Doctor[,-1:-4], by = dats3$Doctor[,1:4], 
# FUN = sum, na.rm = T, sort = F)
# 
# dats3$Doctor$mean <- ifelse( dats3$Doctor$number == 0, 0, 
# dats3$Doctor$sum / dats3$Doctor$number)
# dats3 <- do.call(rbind, dats3)
# rownames(dats3) <- NULL
# 
# write.csv( dats3, "./Stage3/results_indicator012_stage3.csv", row.names = F)
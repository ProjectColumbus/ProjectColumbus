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

dats2 <- dats1

dats2$year <- ifelse( as.numeric(gsub("\\(|\\)", "", dats2$year)) < 30, 
gsub("([0-9]{2})", "20\\1", dats2$year), gsub("([0-9]{2})", "19\\1", 
dats2$year))

dats3 <- dats2[,c(-1,-6)]

write.csv(dats3, "./Stage3/results_indicator025_stage3.csv",row.names = FALSE)


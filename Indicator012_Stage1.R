library("openxlsx")

PARAMS <- list(
sheet = 1:4,
startrow = 1,
cols = 1:4
)

attach(PARAMS)

dats1 <- lapply( sheet, function(x) 
{
    tmp <- read.xlsx( "./Original_Data/Indicator 012 Database.xlsx", sheet = x,
    startRow = startrow, cols = cols)
    tmp$Variable <- gsub("^ +| +$", "", tmp$Variable)
    tmp
})

detach(PARAMS)

dats1 <- do.call(rbind, dats1)

head(dats1)

var_split <- paste("(Grand total) \\- (First major)\\, (.+)\\, ",
"((Bachelor|Master|Doctor)(.*)) \\- (\\([0-9]{2}\\))", sep = "")
    
var <- lapply( c(2:3,5,7), function(y)
{
    gsub( var_split, paste( "\\", y, sep = ""), dats1$Variable)
})

dats1 <- cbind( do.call(cbind, var)[,c(3,1,2,4)], dats1[,-1])

colnames(dats1) <- scan(what = "", sep = "\n", file = "./Stage1/Changed_Names")

dats2 <- dats1

dats2$year <- ifelse( as.numeric(gsub("\\(|\\)", "", dats2$year)) < 30, 
gsub("\\(([0-9]{2})\\)", "20\\1", dats2$year), gsub("\\(([0-9]{2})\\)", 
"19\\1", dats2$year))

dats3 <- dats2 

dats3 <- split(dats3, dats3$level)

dats3$Doctor <- aggregate(dats3$Doctor[,-1:-4], by = dats3$Doctor[,1:4], 
FUN = sum, na.rm = T, sort = F)

dats3$Doctor$mean <- ifelse( dats3$Doctor$number == 0, 0, 
dats3$Doctor$sum / dats3$Doctor$number)
dats3 <- do.call(rbind, dats3)
rownames(dats3) <- NULL

write.csv( dats3, "./Stage3/results_indicator012_stage3.csv", row.names = F)
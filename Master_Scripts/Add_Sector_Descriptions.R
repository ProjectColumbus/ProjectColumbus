library("openxlsx")

DATADIR <- "~/User/Cuentas Satélite/Scripts File/ProjectColumbus/DATA"

if( file.exists( paste(DATADIR, "/Master_Scripts/SectorDescs.RData",
sep = "")))
{
    load( paste(DATADIR,"/Master_Scripts/SectorDescs.RData", sep = ""))
} else
{
    PARAMS <- list(
        soclist = list(
            startRow = 14,
            cols = 1:5,
            colNames = FALSE,
            rowNames = FALSE,
            xlsxFile = paste(DATADIR, "/Master_Scripts/soc2010.xlsx", sep = "")
        ),
        naicslist = list(
            startRow = 3,
            cols = 2:3,
            colNames = FALSE,
            rowNames = FALSE,
            xlsxFile = paste(DATADIR, "/Master_Scripts/naics2012.xlsx",
            sep = "")
        ),
        ciplist = list(
            cols = c(2,5),
            colNames = TRUE,
            rowNames = FALSE,
            xlsxFile = paste( DATADIR,"/Master_Scripts/cip2010.xlsx", sep = "")
        )
    )
    DESCS <- lapply( PARAMS, function(x) do.call( read.xlsx, x))

    DESCS[[1]][is.na( DESCS[[1]])] <- ""
    DESCS[[1]] <- data.frame( soc_code = do.call(paste, DESCS[[1]][,1:4]),
    soc_desc = DESCS[[1]][,5], stringsAsFactors = FALSE)
    DESCS[[1]][,1] <- gsub( "^ +| +$", "", DESCS[[1]][,1])

    colnames(DESCS[[2]]) <- c("naics_code", "naics_desc")

    colnames(DESCS[[3]]) <- c("cip_code", "cip_desc")
    DESCS[[3]][,1] <- gsub("\"", "", DESCS[[3]][,1])
    DESCS[[3]][,2] <- gsub("\\.$", "", DESCS[[3]][,2])
    DESCS[[3]][ DESCS[[3]]$cip_desc == toupper( DESCS[[3]]$cip_desc), ] <-
    read.csv("uppercase_fix.csv", stringsAsFactors = FALSE, header =
    TRUE)[,c(1,3)]

    save( DESCS, file = paste(DATADIR, "/Master_Scripts/SectorDescs.RData",
    sep = ""))

}

i_naics <- sprintf( "Indicator%03d", c(1,2,9,11,13,23), replace = TRUE)
i_soc <- sprintf("Indicator%03d", 3, replace = TRUE)
i_cip <- sprintf("Indicator%03d", c(12,25,26), replace = TRUE)

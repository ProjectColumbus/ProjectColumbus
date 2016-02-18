library("openxlsx")
PARAMS <- list(
    dats1c1 = list(
        startRow = 5,
        rows = 1:5,
        cols = c(4,9:12),
        sheet = 1,
        rowNames = FALSE,
        colNames = FALSE
    ),
    dats1c2 = list(
        startRow = 4,
        rows = c(4,58),
        cols = 1:13,
        sheet = 2,
        rowNames = TRUE,
        colNames = TRUE
    ),
    dats1c3 = list(
        startRow = 4,
        rows = c(4,58),
        cols = 1:10,
        sheet = 3,
        rowNames = TRUE,
        colNames = TRUE
    )
)

dats1 <- lapply( PARAMS, function(x) 
{
    do.call( read.xlsx, c(x, list( 
    xlsxFile = "./Original_Data/Indicator 018 Database.xlsx")) )
})

colnames(dats1[[1]]) <- seq( 2010, 2010 + ncol( dats1[[1]] ) - 1, 1)

dats2 <- dats1

dats2[[1]][,1:ncol(dats2[[1]])] <- sapply( 1:ncol(dats2[[1]]), function(x)
{
    as.numeric( gsub( "\\,", "", dats2[[1]][,x]))
})


dats_yrs <- Reduce(function(x,y) intersect(x,y), sapply( dats1, colnames))

dats3 <- as.matrix( dats2[[3]][,dats_yrs] / dats2[[1]][,dats_yrs] * 1e6 )
rownames(dats3) <- dats_yrs
colnames(dats3) <- gsub("\n", "", "Academic Science and Engineering Output per 
Million Inhabitants")

write.csv(as.matrix(dats3), "./Stage3/results_indicator018_stage3.csv")
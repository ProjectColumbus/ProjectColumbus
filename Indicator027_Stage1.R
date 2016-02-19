library("openxlsx")
library("tcltk")

YEAR <- 2015
PARAMS <- list(
    dats1c1 = list(
        sheet = 1,
        startRow = 1,
        rows = c(9,11:34),
        cols = c(1,19),
        rowNames = FALSE,
        colNames = TRUE
        ),
    dats1c2 = list(
        sheet = 2,
        startRow = 11,
        rows = 1:25,
        cols = c(1,15),
        rowNames = FALSE,
        colNames = FALSE
        ),
    dats1c4 = list(
        sheet = 4,
        colNames = TRUE,
        rowNames = FALSE
        )
    )
    
dats1 <- lapply( PARAMS, function(x)
{
    tmp <- c( xlsxFile = "./Original_Data/Indicator 027 Database.xlsx",
    x)
    
    do.call( read.xlsx, tmp)
})


getInfo <- function()
{
    slot <- list( program_expenses1 = tclVar(0), 
    program_expenses2 = tclVar(0))
    tt <- tktoplevel()

    tt_f1 <- tkframe(tt)
    tkpack(tt_f1, side = "top")
    tkpack( tklabel(tt_f1, text = gsub("\n|{2,}", " ", "Actual/Assigned 
    Expenses for the PR Department of Education (in $000\'s): ")), side = 
    "left")
    tkpack( tkentry(tt_f1, textvariable = slot[[1]]), side = "left")

    tt_f2 <- tkframe(tt)
    tkpack(tt_f2, side = "top")
    tkpack(tklabel(tt_f2, text = gsub("\n| {2,}", " ", "Actual/Assigned 
    Expenses for the PR Conservatory of Music (in $000\'s): ")), side = 
    "left")
    tkpack( tkentry(tt_f2, textvariable = slot[[2]]), side = "left")

    tkpack(tkbutton(tt, text = "Exit", command = function() tkdestroy(tt)),
    side = "right", anchor = "s")

    tkwait.window(tt)
    return( sapply(slot, function(y) as.numeric(tclvalue(y))))
}

dats1$dats1c3 <- getInfo()

dats1$dats1c1[,1] <- tolower(gsub("^ +|\\-| +$", "", dats1$dats1c1[,1]))
dats1$dats1c1 <- dats1$dats1c1[-grep(
"preescolar|elemental|secundari[oa]|total|grado1", dats1$dats1c1[,1]),] 

dats1$dats1c2[,1] <- tolower(gsub("^ +| +$", "", dats1[[2]][,1]))

dats3 <- crossprod( dats1$dats1c1[,2], dats1$dats1c2[,2]) + 
sum(dats1$dats1c3) * 1000 + sum(dats1$dats1c4[,"Sum"], na.rm = T)

rownames(dats3) <- YEAR; colnames(dats3) <- "Education Expenses in Puerto Rico"

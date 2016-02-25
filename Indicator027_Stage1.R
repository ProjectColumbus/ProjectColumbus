# Script for DDEC Indicator 027
# Author: Gamaliel Lamboy Rodríguez
# Version: 1.0
# Description:
# This script partially automatizes the obtainment of Indicator 027 from its 
# database. It assumes an incremental updating of the data, and that the most 
# recent year of the database is being manipulated. This indicator tries to be
# a comprehensive aggregate of municipal, state and private education 
# expenditures.

# Preload additional packages to use.
library("openxlsx")
library("tcltk")

# Parameters used to read the data. This indicator has multiple sources,
# therefore PARAMS is a nested list, with each component having its respective
# parameters.
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
# Year of the data must be supplied externally for the GUI.
YEAR <- 2015

# Read the original data. Component 3 is retrieved via GUI, and hence has no
# parameters.
dats1 <- lapply( PARAMS, function(x)
{
    tmp <- c( xlsxFile = "./Original_Data/Indicator 027 Database.xlsx",
    x)
    
    do.call( read.xlsx, tmp)
})

# This function creates a basic GUI to retrieve the necessary data for
# Component 3. It receives nothing as argument, but will return the
# captured data from the tcltk widgets.
getComp3 <- function()
{

    slot <- lapply(1:2, function(x) tclVar(0))
    tt <- tktoplevel()
    ttfont <- tkfont.create( family = "Oxygen-Sans", size = 10, weight = 
    "bold")
    ttfont2 <- tkfont.create( family = "URW Gothic L", size = 10)
    tktitle(tt) <- paste("Puerto Rico Budget Information -- K-12 Education (",
    YEAR, ")", sep = "")
    
    tt$env$f1 <- tklabel(tt, text = paste("Actual/Assigned Expenses for the ",
    "PR Department of Education (in $000\'s): ", sep = ""), font = ttfont,
    pady = 5)
    tt$env$f1e <- tkentry(tt, textvariable = slot[[1]], font = ttfont)
    
    tkgrid( tt$env$f1, tt$env$f1e)
    tkgrid.configure( tt$env$f1, sticky = "w")
    tkgrid.configure( tt$env$f1e, sticky = "e")
    
    tt$env$f2 <- tklabel(tt, text = paste("Actual/Assigned Expenses for the ",
    "PR Conservatory of Music (in $000\'s): ", sep = ""), font = ttfont,
    pady = 5)
    tt$env$f2e <- tkentry(tt, textvariable = slot[[2]], font = ttfont)
    
    tkgrid( tt$env$f2, tt$env$f2e)
    tkgrid.configure( tt$env$f2, sticky = "w")
    tkgrid.configure( tt$env$f2e, sticky = "e")
    
    tt$env$exit <- tkbutton(tt, text = "Exit", command = function() 
    tkdestroy(tt), font = ttfont)
    tkgrid(tt$env$exit, sticky = "e", columnspan = 2)
    
    tkwait.window(tt)
    
    slot <- as.numeric(sapply(slot, function(x) tclvalue(x)))
    names(slot) <-  c("dept_of_educ", "conserv_music")
    return(slot)
}

# Store Component 3 in dats1.
dats1$dats1c3 <- getComp3()

# Reconciliation of incompatible labeling between components 1 and 2.
dats1$dats1c1[,1] <- tolower(gsub("^ +|\\-| +$", "", dats1$dats1c1[,1]))
dats1$dats1c1 <- dats1$dats1c1[-grep(
"preescolar|elemental|secundari[oa]|total|grado1", dats1$dats1c1[,1]),] 

dats1$dats1c2[,1] <- tolower(gsub("^ +| +$", "", dats1$dats1c2[,1]))

# Calculate the indicator
dats3 <- crossprod( dats1$dats1c1[,2], dats1$dats1c2[,2]) * 12 + 
sum(dats1$dats1c3) * 1000 + sum(dats1$dats1c4[,"Sum"], na.rm = T)

# Format the results in dollar format.
dats3 <- round(dats3 / 1e6,2)
dats3 <- paste( "$", format( dats3, big.mark = ",", nsmall = 2, scientific = 
FALSE), sep = "")

dats3 <- as.matrix(dats3)

# Add proper labels to the data.
rownames(dats3) <- YEAR
colnames(dats3) <- "Education Expenses in Puerto Rico ($ millions)"

# Write the final results.
write.csv( dats3, "./Stage3/results_indicator027_stage3.csv")

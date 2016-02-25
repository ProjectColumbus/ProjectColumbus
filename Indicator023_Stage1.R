# Script for DDEC Indicator 023
# Author: Gamaliel Lamboy Rodríguez
# Version: 1.0
# Description:
# This script partially automatizes the obtainment of Indicator 023 from its
# database. It assumes an incremental updating of the data, and that the most
# recent year of database is being manipulated. Time trends are handled by a
# master script. However, the resulting files are created so that they can
# afterwards be merged in a cumulative (time-series) dataset.
# The following script retrieves the number of economic firms currently
# operating in the economy.

# Preload additional packages to use.
library("tcltk")

# Data is obtained directly from the Indicator 002 Results, for obvious
# reasons.
load("../Indicator002/Stage3/database_indicator002_stage3.RData")

# Beginning of Name Validation
# Some corps_900 firms split their structure into several Employer 
# Identification Numbers. However, for measurement purposes, they must
# be considered a single entity. In this part, a name validation procedure was
# implemented in order to aggregate the split entities by name into a single
# unit for measurement purposes. This procedure involves manual input, thus use
# of VERY simple GUI for information is done using the "tcltk" package in order
# to warn the user of these needed changes. This can be refined later.

# Create a data.frame with the following columns:
# fix - the firm names to be replaced by user input. Unchanged values are set
# as NA.
# legal_corporate_name - the original name of the firm.
# trade_name - trade names or "Doing Business as"
# EIN - the Employment Identification Number of each firm.
# NAICS - the 6-digit NAICS of each firm.
# emp_m[1-3] - the monthly employment level of each firm.
# tot_wages - the quarterly payroll of each firm.
x <- instance_list[[1]]

name_list900 <- data.frame( fix = rep(NA, nrow(x)), x[, c( "trade_name_DBA",
"legal_corporate_name", "EIN", "NAICS", grep("^emp_m[1-3]", colnames(x), 
value = T), "tot_wages")])

# Sort the rows by name of firm to ease the deduplication process.
name_list900 <- name_list900[ order( name_list900$legal_corporate_name),]

# Outputting to Stage2 folder, awaiting input from user.
write.csv( name_list900, "./Stage2/name_list900_cleanup.csv", 
row.names = FALSE)

# Warning message, explaining the reasons and the expected output. Since
# multi-line strings are not supported in R, a "gsub" routine was developed to
# mark the newline characters which needed to be eliminated with the symbol
# 'a\n'.
edit_done <- tk_messageBox(caption = "Waiting for User Input", message =
paste( gsub("a\n", " ", "Large firms often create multiple legal structures toa
organize their establishments. However, for economic purposes they should bea
considered a single entity. Please replace the NAs in \"fix\" of thea
legal/corporate names that will be considered as a single firm with a uniquea
identifier. For example:

fix   legal_corporate_name  trade_name
ATT   ATT Puerto Rico       AT&T Puerto Rico
ATT   ATT Mobility          AT&T Mobility Puerto Rico
ATT   W$a2                  AT&T Guaynabo

Sometimes the legal/corporate names are unusable from the original data. Ina
this case, a similar process must be done relative to the trade name ora
\"Doing Business As\" of a firm, as is shown in the third line.

Click OK when both legal/corporate names and trade names have been reviseda
in:\n"), paste( getwd(), "/Stage2/name_list900_cleanup.csv", sep = ""), 
type = "ok", icon = "info"))

# Read the output files from the user
fix_names <- read.csv( "./Stage2/name_list900_cleanup.csv", 
stringsAsFactors = FALSE, row.names = NULL, colClasses = c( "character",
sapply(name_list900, class)[-1]) )

# Check for consistency in the data frames. Consistent data frames are those
# which have numerical equality in the non-modifiable data, and have the same
# attributes as the original data frames. Inputs must be placed in ./Stage2
# in order to be read.
checkStr <- function( data1, data2)
{
    checklist <- list( 
    names = identical( names(data1), names(data2)),
    classes = identical( sapply(data1[,-1], class), sapply(data2[,-1], class)),
    values = all.equal( data1[,-1], data2[,-1], check.attributes = FALSE,
    check.names = FALSE, tol = 0)
    )
    checklist
}

check_str <- checkStr( name_list900, fix_names)

# File Structure Validation
# Its sole purpose is to display a warning message in case there is a 
# structural issue with the user-changed data.frames.
while( any(check_str == FALSE))
{
#+ Create a basic GUI to display the warning message.
    warning <- tktoplevel()
    tkwm.title(warning, "File Structure Error")
    tklabel(warning, textvariable = tclVar(paste( "Error: file structure not ",
    "equal. Please Check: ", paste( names( check_str[ which( check_str == 
    TRUE ) ] ), collapse = " and "), sep = "" ))) -> warning$env$label
    tkgrid( warning$env$label, padx = 20, pady = 15)
    warning
#+ 'done' captures the tcl states, and assigns them to specific "codes", which
#+ were then used to create conditionals.
    done <- tclVar("L")
#+ In addition to the message, a convenience button to recheck the files was
#+ added. This button allows to refresh the inputted data after corrections.
    recheck <- tkbutton(warning, text = "Re-Check the Files", command =
    function() { tclvalue(done) <- "A" })
    tkgrid(recheck)
    tkbind( warning, "<Destroy>", function() tclvalue(done) <- "C" )
    tkfocus( warning )
    tkwait.variable( done )
#+ Capture the value of 'done'
    tcv <- tclvalue(done)
    tkdestroy(warning)

    if(tcv == "A")
    {
#++ Reread the files with discrepant structure.
        fix_names <- read.csv("./Stage2/name_list900_cleanup.csv", 
        stringsAsFactors = FALSE, colClasses = c("character", sapply(
        name_list900, class)[-1] ))
    }
# #+ Recheck the structure for consistency. If the attributes are equal, then
# #+ proceed to the next steps.
    check_str <- checkStr( name_list900, fix_names)
}

# Verify if there were changes in the inputted files.
nochange <- identical(name_list900$fix, fix_names$fix)

# Display a warning message if there were no changes in the files.
if(any(nochange == TRUE))
{
    tk_messageBox(caption = "Warning", message = paste("No changes made.",
    " Using originals.", sep = ""), type = "ok", icon = "info")
}

Apply the changed names (if any) to legal_corporate_name.
x$legal_corporate_name[ match( fix_names$legal_corporate_name[ !is.na( 
fix_names$fix) ], x$legal_corporate_name) ] <- fix_names$fix[ !is.na(
fix_names$fix) ]

# Final Results Calculation
instance_list[[1]] <- x

dats3 <- do.call(rbind, instance_list)
rownames(dats3) <- NULL

# The Key for corps_900 is the legal/corporate name, whereas for the other
# three instances it is the EIN.
dats3$key <- c( instance_list[[1]]$legal_corporate_name, 
instance_list[[2]]$EIN, instance_list[[3]]$EIN)

# Use the selected NAICS codes for visualization, instead of the 6-digit ones.
dats3$NAICS <- with(DATS2, naics$naics_orig_from_list[ match( dats3$NAICS, 
naics$naics_recode)] )
# Only unique keys are considered firms, obviously. 
dats3 <- tapply( dats3$key[ !duplicated(dats3$key) ], dats3$NAICS[ 
!duplicated(dats3$key) ], FUN = length)

# Write the final results.
write.csv( dats3, "./Stage3/results_indicator023_stage3.csv")

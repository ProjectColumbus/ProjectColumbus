# Script for DDEC Indicators 004 to 008
# Author: Gamaliel Lamboy Rodríguez
# Version: 1.0
# Description:
# This script partially automatizes the obtainment of Indicators 004-007 from
# their database. It assumes an incremental updating of the data, and that the
# recent year of database is being manipulated. This indicator is the 
# Gross Expenditure in R&D (GERD), obtained from the survey and manually
# inputted (it comes from a results .pdf file).

# Load the required packages.
library("openxlsx")

# Create a Workbook object to be edited by the user. The user must supply
# paticular information, which is explained in the .xlsx file to be created.
wb <- createWorkbook()

# Create the input data frame,with the concepts to be considered.
dats1 <- data.frame( concept = c("Private (Total)", 
"Private (% in Manufacturing)", "Public & Nonprofit", 
"Total GERD in Services", "", "Subtotal -- Public & Nonprofit", 
"Universities and other postsecondary institutions", 
"Government and Nonprofit"), 
amount = rep(NA, 8), stringsAsFactors = FALSE)

# Create formulas to obtain the total GERD.
dats1[ dats1$concept == "Total GERD in Services", "amount"] <- 
"B3 * (1 - B4) + B5"
dats1[ dats1$concept == "Public & Nonprofit", "amount"] <- "SUM(B9:B10)"

class( dats1$amount) <- c( class(dats1$amount), "formula")

# Create the worksheet and add the formulas and formatting.

addWorksheet(wb, "GERD")

addStyle(wb, sheet = "GERD", style = createStyle( wrapText = TRUE, valign = 
"center"), rows = 1:10, cols = 1:4, gridExpand = TRUE)

addStyle(wb, sheet = "GERD", style = createStyle( wrapText = TRUE, valign = 
"center", halign = "left", indent = 1), rows = c(1,3:6,9,10), cols = 1, 
gridExpand = TRUE)

addStyle(wb, sheet = "GERD", style = createStyle( numFmt = "#,##0.0%", fgFill =
"#FFF4BD"), rows = 4, cols = 2)
addStyle(wb, sheet = 1, style = createStyle( numFmt = "#,##0.0", fgFill = 
"#FFF4BD"), rows = c(3,9,10), cols = 2)
addStyle(wb, sheet = 1, style = createStyle( numFmt = "#,##0.0"), 
rows = c(5,6), cols = 2)

writeData(wb, sheet = "GERD", startRow = 2, x = dats1)

mergeCells(wb, sheet = "GERD", rows = 1, cols = 1:4)
setRowHeights( wb, sheet = "GERD", rows = 1, heights = 150)
setRowHeights( wb, sheet = "GERD", rows = 2:10, heights = c(rep(20,7),35,20))

setColWidths( wb, sheet = "GERD", cols = 1:4, widths = c(35, rep(20,3)))

# Make a message to explain the user what information is required from them.

writeData( wb, sheet = "GERD", startRow = 1, x = gsub("A\n", "", "Please A
input the following values to generate the GERD estimate:

Private (Total): the total GERD by the private sector.

Private (% in Manufacturing): The percentage of private GERD produced by A
manufacturing firms. Only GERD produced by service firms is considered a A
part of the estimate.

Universities and other postsecondary institutions: The amount of GERD
produced by postsecondary educational institutions, whether private or public.

Government and Nonprofit: the amount of GERD produced by the Government and
non-educational nonprofit institutions."))

saveWorkbook(wb, "./Stage2/Input_User.xlsx", overwrite = TRUE)

tcltk::tk_messageBox( type = "ok", message = paste( "The following file",
" must be edited: ", DATADIR, "/Stage2/Input_User.xlsx", ".\nPlease press OK", 
" when the file has been edited and closed.\n", sep = ""))

# Read back the data and create the final results file.

dats3 <- read.xlsx("./Stage2/Input_User.xlsx", rows=2:6, cols = 1:2)
colnames(dats3) <- c("Main Sector", "Amount (in $ millions)")

dats3[ nrow(dats3) + 1,] <- c("Total GERD (Manufacturing & Services", sum( 
as.numeric( dats3[ c(1,3),2 ] )) )

dats3[1,1] <- "Private (Services)"; dats3[1,2] <- as.numeric(dats3[1,2]) * 
as.numeric( dats3[2,2])

dats3 <- dats3[-2,]

write.csv(dats3, "./Stage3/results_indicator004t008_stage3.csv", 
row.names= FALSE)

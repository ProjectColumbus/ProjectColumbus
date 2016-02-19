# Script for DDEC Indicators 004 to 007
# Author: Gamaliel Lamboy Rodríguez
# Version: 1.0
# Description:
# This script partially automatizes the obtainment of Indicators 004-007 from
# their database. It assumes an incremental updating of the data, and that the
# recent year of database is being manipulated. For time trends, the user must
# supply the database year, which is then assigned as the main variable name.
# The resulting file can afterwards be joined with the cumulative
# (time-series) dataset.

require(tcltk)mydialog <- function(){
xvar <- tclVar("")
yvar <- tclVar("")
zvar <- tclVar("")
tt <- tktoplevel()
tkwm.title(tt,"MYTEST")
x.entry <- tkentry(tt, textvariable=xvar)
y.entry <- tkentry(tt, textvariable=yvar)
z.entry <- tkentry(tt, textvariable=zvar)
reset <- function() {
tclvalue(xvar)<-""
tclvalue(yvar)<-""
tclvalue(zvar)<-""
}
reset.but <- tkbutton(tt, text="Reset", command=reset)
submit <- function() {
x <- as.numeric(tclvalue(xvar))
y <- as.numeric(tclvalue(yvar))
z <- as.numeric(tclvalue(zvar))
tkmessageBox(message=paste("x + y + z = ", x+y+z, ""))
}
submit.but <- tkbutton(tt, text="submit", command=submit)
quit.but <- tkbutton(tt, text = "Close Session",
command = function() {
q(save = "no")
tkdestroy(tt)
}
)
tkgrid(tklabel(tt,text="Put your variables.."),columnspan=3, pady = 10)
tkgrid(tklabel(tt,text="x variable"), x.entry, pady= 10, padx= 10)
tkgrid(tklabel(tt,text="y variable"), y.entry, pady= 10, padx= 10)
tkgrid(tklabel(tt,text="z variable"), z.entry, pady= 10, padx= 10)
tkgrid(submit.but, reset.but, quit.but, pady= 10, padx= 10)
}mydialog()
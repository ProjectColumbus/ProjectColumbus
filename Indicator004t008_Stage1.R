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

require(tcltk)<br>mydialog <- function(){<br><br>       xvar <- tclVar("")<br>       yvar <- tclVar("")<br>       zvar <- tclVar("")<br><br>       tt <- tktoplevel()<br>       tkwm.title(tt,"MYTEST")<br>       x.entry <- tkentry(tt, textvariable=xvar)<br>       y.entry <- tkentry(tt, textvariable=yvar)<br>       z.entry <- tkentry(tt, textvariable=zvar)<br><br>       reset <- function() {<br>         tclvalue(xvar)<-""<br>         tclvalue(yvar)<-""<br>         tclvalue(zvar)<-""<br>        }<br><br>       reset.but <- tkbutton(tt, text="Reset", command=reset)<br><br>       submit <- function() {<br>         x <- as.numeric(tclvalue(xvar))<br>         y <- as.numeric(tclvalue(yvar))<br>         z <- as.numeric(tclvalue(zvar))<br>         tkmessageBox(message=paste("x + y + z = ", x+y+z, ""))<br>       }<br>       submit.but <- tkbutton(tt, text="submit", command=submit)<br>       <br>       quit.but <- tkbutton(tt, text = "Close Session", <br>           command = function() {<br>           q(save = "no")<br>           tkdestroy(tt)<br>           }<br>        )<br><br>       tkgrid(tklabel(tt,text="Put your variables.."),columnspan=3, pady = 10)<br>       tkgrid(tklabel(tt,text="x variable"), x.entry, pady= 10, padx= 10)<br>       tkgrid(tklabel(tt,text="y variable"), y.entry, pady= 10, padx= 10)<br>       tkgrid(tklabel(tt,text="z variable"), z.entry, pady= 10, padx= 10)<br>       tkgrid(submit.but, reset.but, quit.but, pady= 10, padx= 10)<br><br>    }<br><br>mydialog()<br>
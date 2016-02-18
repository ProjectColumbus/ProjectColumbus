library("openxlsx")

PARAMS <- list(
startrow = 10,
sheet = 1,
colnames = FALSE,
rownames = FALSE,
rows = c(1:14,16:23,28:30,32:34,36:38,40:42,45:48,51:56),
cols = c(1,4)
)

attach(PARAMS)

dats1 <- read.xlsx( "./Original_Data/Indicator 010 Database.xlsx", sheet = 
sheet, startRow = startrow, colNames = colnames, rowNames = rownames, rows = 
rows, cols = cols)

detach(PARAMS)

id <- c("18t24","25mt", "25t34", "35t44", "45t64", "65mt", "poverty_rate",
"median_wage")
labels <- paste("Educational Attainment -- ", gsub("([0-9]{2})t([0-9]{2})",
"\\1 to \\2 years old", id[1:6]), sep = "")
labels <- gsub("([0-9]{2})mt", "\\1 years old or more", labels)
labels <- c(labels, "Poverty Rate for the Population 25 and over",
"Median Earnings")

change_names <- scan( what = "", sep = "\n", file = "./Stage1/Changed_Names")

component_list <- lapply( 1:length(id), function(x)
{
    if( x <= 6)
    {
        tmp1 <- dats1[ grep( paste( "pct_", id[x], sep = ""), 
        change_names),]
    } else
    {
        tmp1 <- dats1[ grep( id[x], change_names), ]
    }
    
    rbind( c(X1 = labels[x], X2 = ""), tmp1)
})

component_list <- do.call(rbind, component_list)
colnames(component_list) <- c("Cohort", 
"Percentage of Respective Population")

write.csv( component_list, "./Stage3/results_indicator010_stage3.csv",
row.names = F)
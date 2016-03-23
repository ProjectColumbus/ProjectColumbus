library("reshape2")

ID_vars <- list(
Indicator001 = c("naics_code", "naics_desc"),
Indicator002 = c("naics_code", "naics_desc"),
Indicator003 = c("occupational_code", "occupational_code_title"),
Indicator009 = c("naics_code", "naics_title"),
Indicator010 = c("Cohort", "Concept"),
Indicator011 = c("naics_code", "naics_title_code"),
Indicator012 = c("cip_code", "cip_description"),
Indicator013 = c("naics_code", "naics_title"),
Indicator014 = c("concept"),
Indicator015 = c("concept"),
Indicator017 = c("concept"),
Indicator018 = c("year"),
Indicator023 = c("naics_code", "naics_desc"),
Indicator025 = c("CIP_code", "CIP_desc"),
Indicator026 = c("cip_code", "cip_description"),
Indicator027 = c("concept")
)

file_melt <- function(rev = TRUE )
{
    dir = tcltk::tk_choose.dir( caption = paste("Please",
    "select the directory for the indicator to be melted"))
    
    dir_old <- getwd()
    setwd(dir)
    
    pattern <- ".*(indicator([0-9]{3})).*y_([0-9]{4}(Q[1-4])*)\\.csv$"
    if( rev == FALSE)
    {
        pattern <- gsub( "y", "", pattern)
    }
    fmelt <- lapply( list.files( "./Stage3", pattern = pattern, 
    full.names = TRUE), function(x)
    {
        tmp <- read.csv( x, stringsAsFactors = FALSE)
        c1 <- ID_vars[[ paste("Indicator", gsub(pattern, 
        "\\2", x),sep = "") ]]
        
        if( length(intersect( c("variable", "year"), colnames(tmp))) == 0)
        {
            tmp <- cbind( year = gsub(pattern, "\\3", x), tmp)
            c1 <- c( "year", c1)
        }
        
        melt( tmp, id.vars = c1 )
    })
    
    write.csv( do.call(rbind, fmelt), paste("./Stage3/results_indicator", 
    tolower( gsub(".*Indicator([0-9]{3}).*", "\\1", dir)), "_stage3y_melt.csv",
    sep = ""), row.names = FALSE)
    
    setwd(dir_old)
    
}

file_bind <- function( rev = TRUE, horiz = FALSE )
{
    dir = tcltk::tk_choose.dir( caption = paste("Please",
    "select the directory for the indicator to be binded"))
    
    dir_old <- getwd()
    setwd(dir)
    
    pattern <- "^results_(indicator([0-9]{3})).*y_([0-9]{4}(Q[1-4])*)\\.csv$"
    
    fbind <- lapply( list.files( "./Stage3", pattern = pattern,
    full.names = TRUE), function(x)
    {
        read.csv( x, stringsAsFactors = FALSE)
    })
    
    names( fbind) <- sapply( list.files( "./Stage3", pattern = pattern,
    full.names = TRUE), function(x) gsub( pattern, "\\3", x) )
    
    if( horiz == TRUE)
    {
        fbind <- do.call(rbind, fbind)
        
    } else
    {
        fbind <- Reduce(function(x,y) merge(x,y, all.x = TRUE), fbind)
    }
    
    write.csv(fbind, paste("./Stage3/results_", tolower( gsub(
    ".*(Indicator[0-9]{3}).*", "\\1", dir_old)), "_stage3y_bind.csv", 
    sep = ""), row.names = FALSE)
}

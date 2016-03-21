

exec_script <- function( indic_code = "012")
{
    dir_old <- getwd()
    dir <- tcltk::tk_choose.dir( caption = paste("Please select the",
    "Indicator to be revised"))
    setwd(dir)
    
    file_list <- list.files( "./Original_Data", pattern = "[0-9]{4}\\.xlsx$", 
    full.names = TRUE)
    
    if( indic_code == "019t022")
    {
        file_list <- list.files("./Original_Data", pattern = "[0-9]{4}\\.sav",
        full.names = TRUE)
    } else if( indic_code == "004t008" )
    {
        file_list <- list.files("./Stage2", pattern = "\\.xlsx$", 
        full.names = TRUE)
        
    } else if( indic_code == "002")
    {
        file_list <- list.files("./Original_Data", pattern = 
        "Indicator 002 Database.*", full.names = TRUE)
    } else if( indic_code == "023")
    {
        file_list <- list.files("../Indicator002/Stage3", pattern = 
        "database_indicator002_stage3y_[0-9]{4}Q[1-4]{1}\\.RData", 
        full.names = TRUE)
    } else if( indic_code == "026")
    {
        file_list <- list.files("../Indicator012/Stage3", pattern = 
        "database_indicator012_stage3y_[0-9]{4}.RData")
    }
    
    file_suf <- paste( "./Stage3/", c("results", "database"), "_indicator", 
    indic_code, "_stage3y.", c("csv", "RData"), sep = "")
    file_year <- gsub(".*([0-9]{4}(Q[1-4])*).*$", "\\1", file_list)
    lapply( 1:length(file_list), function(x) 
    {
        if( indic_code == "002")
        {
            source("../../Indicator002/Indicator002_Stage1.R")
            source("../../Indicator002/Indicator002_Stage2.R")
            source("../../Indicator002/Indicator002_Stage3.R")
            
        } else
        {
            source( paste("../../Indicator", indic_code, "_Stage1.R", 
            sep = ""))
        }
        
        if( indic_code == "004t008")
        {
            return()
        }
        
        file.rename( file_suf[1], gsub("_stage3y", paste("_stage3y", 
        file_year[x], sep = "_"), file_suf[1] ))
        
        if( file.exists( file_suf[2]))
        {
            file.rename( file_suf[2], gsub("_stage3y", paste(
            "_stage3y", file_year[x], sep = "_"), file_suf[2] ))
        }
    })
    setwd(dir_old)
}

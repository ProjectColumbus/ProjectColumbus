 
dats1 <- read.csv("../Indicator009/Stage3/results_indicator009_stage3.csv", 
stringsAsFactors = FALSE)

dats1 <- dats1[,c("naics_code", "naics_title", "occupational_code",
"occupational_title", "total_employees")]

total_nfarm <- read.csv("../Indicator009/Stage1/database_indicator009_stage1.csv",
stringsAsFactors = FALSE, header = TRUE)

total_nfarm <- total_nfarm[ total_nfarm$area_code == 72 & 
total_nfarm$occupational_code == "00-0000", c("naics_code", "naics_title", 
"occupational_code", "occupational_title", "total_employees")]

total_nfarm$naics_code <- gsub("0+$","", total_nfarm$naics_code)

total_nfarm <- total_nfarm[ total_nfarm$naics_code %in% dats1$naics_code,]

emp_tots <- rep(total_nfarm$total_employees, table( dats1$naics_code))

dats3 <- dats1

dats3$total_employees <- ifelse( dats3$total_employees == 0 | 
is.na(dats3$total_employees), 0, dats3$total_employees / as.numeric(emp_tots))

write.csv(dats3, "./Stage3/results_indicator003_stage3.csv")
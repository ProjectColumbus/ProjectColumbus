load("../Indicator012/Stage3/database_indicator012_stage3.RData")

write.csv(dats3[,-c(6,7)], "./Stage3/results_indicator026_stage3.csv")
#this is the centralized document for the COPA-specific scripts

#importing and cleaning:
#if something around the datasets requires investigation/alteration, dive through
#these scripts to see the base data, but otherwise you can skip to COPA_Tidy_Datasets.Rmd
# source("Code/import_copa.R")
# source("Code/generate_copa_roster.R")
# source("Code/link_crews.R")
#this script is even more optional, just a record of some of the investigatory 
#techniques used to find non-automatic links between COPA and II
# source("Code/crew_link_investigation.R")
# save(copa_roster, copa_crews, copa_full, file = "copa_datasets.Rds")
load("copa_datasets.Rds")

#still very much under construction 
source("Code/COPA_Tidy_Datasets.Rmd")

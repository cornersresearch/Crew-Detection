install.packages("pacman")
library(pacman)
p_load(tidyverse, lubridate)


#bring in the copa data:
#maybe in the future we just import a finalized file, but still cleaning that 
#may need to change in future
copa_path <- "/Users/milanrivas/Documents/GitHub/copa_data/"
source(paste0(copa_path, "copa_cleaning.R"))

#range of copa data: essentially 2000- mid 2022
min(copa_full$incident_datetime, na.rm = TRUE)
max(copa_full$incident_datetime, na.rm = TRUE)
hist(copa_full$incident_datetime, breaks = 30)

#EACH COMPLAINT CAN HAVE MULTIPLE ROWS FOR DIFFERENT TYPES OF MISCONDUCT

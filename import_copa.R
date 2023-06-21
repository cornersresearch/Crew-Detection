install.packages("pacman")
library(pacman)
p_load(tidyverse, bigrquery, lubridate, wk, sf)
bq_auth()
copa_clear_q  <- "SELECT * FROM `n3-main.copa_anon.misconduct_clear`"
copa_clear <- bq_project_query("n3-main", copa_clear_q) %>% bq_table_download()

copa_cms_q <- "SELECT * FROM `n3-main.copa_anon.misconduct_cms`"
copa_cms <- bq_project_query("n3-main", copa_cms_q) %>% bq_table_download()

#we are more heavily modifying clear because generally speaking, the naming 
#conventions in cms data are more concise
#still need to do a deep dive to make sure all variables are compatible
copa_clear_cleaned <- copa_clear %>%
  rename(inv_star = investigator_star_no, 
         current_finding = final_finding, 
         inv_race = investigator_race, 
         inv_gender = investigator_gender, 
         closed_date = investigation_end_date,
         status = investigation_status, 
         initial_finding = recommended_finding,
         initial_penalty = recommended_discipline, 
         current_penalty = final_discipline, 
         district = district_of_incident, 
         beat = beat_of_incident, 
         accused_sex = accused_gender, 
         reporting_category = allegation_category_desc, 
         zip_postal_code = zip_cd, 
         accused_assigned_unit = accused_unit_at_complaint,
         accused_apt_date = accused_appointed_date, 
         accused_star = accused_star_no, 
         accused_position_rank = accused_position, 
         inv_rank = investigator_position, 
         allegation_code = allegation_category_cd, 
         street = street_name
  ) %>%
  mutate(investigator = paste(investigator_first_name, investigator_last_name, sep = " "), 
         cpdmember_complaint = ifelse(complainant_type == "CPD EMPLOYEE", TRUE, FALSE), 
         address_type = NA, 
         allegation_description = NA, 
         accused_assignment = NA, 
         data_group = "Not Provided: CLEAR", 
         accused_detailed_unit = NA, 
         closed_date = as_date(closed_date), 
         data_source = "COPA CLEAR",
         accused_apt_date = as_date(accused_apt_date), 
         complaint_date = as_date(complaint_date), 
         direction = ifelse(street_direction == "?", NA, substring(street_direction, 1, 1))) %>%
  select(-c(street_direction, city, state, complainant_type, apt_no, 
            investigator_first_name, investigator_last_name))

copa_cms_cleaned <- copa_cms %>%
  rename(allegation_code = code, allegation_description = allegation, 
         street_number = address) %>%
  mutate(accused_middle_initial = NA, 
         closed_date = mdy(closed_date), 
         accused_apt_date = as_date(accused_apt_date), 
         complaint_date = as_date(complaint_date),
         data_source = "COPA CMS")

copa_full <- rbind(copa_clear_cleaned, copa_cms_cleaned) %>%
  mutate(accused_sex = case_when(
    accused_sex == "F" ~ "FEMALE", 
    accused_sex == "M" ~ "MALE", 
    TRUE ~ accused_sex
  )) %>%
  mutate(accused_race = case_when(
    accused_race == "Asian" ~ "API",
    accused_race == "White" ~ "WHI",
    accused_race == "Hispanic, Latino, or Spanish Origin" ~ "WWH",
    accused_race == "Hispanic, Latino, or Spanish origin" ~ "WWH",
    accused_race == "Black or African American" ~ "BLK",
    accused_race == "American Indian or Alaska Native" ~ "I",
    accused_race == "S" ~ "WWH",
    accused_race == "Unknown" ~ "U",
    accused_race == "Not listed" ~ "U",
    accused_race == "" ~ "U",
    TRUE ~ accused_race
  )) %>%
  mutate(inv_race = case_when(
    inv_race == "" ~ "U", 
    inv_race == "S" ~ "WWH",
    TRUE ~ inv_race
  )) %>%
  #rank is going to take way more cleaning for standardization purposes
  mutate(accused_position_rank = str_to_upper(accused_position_rank)) %>%
  mutate(accused_on_duty = case_when(
    accused_on_duty == "Yes" ~ "On Duty", 
    accused_on_duty == "No" ~ "Off Duty",
    accused_on_duty == "" ~ "Unknown",
    TRUE ~ accused_on_duty
  )) %>%
  mutate(incident_datetime = as.character(incident_datetime))%>%
  mutate(across(-c(geometry) & where(is.character), ~ na_if(.x,"")))


write.csv(copa_full,"datasets/COPA/copa_full.csv")






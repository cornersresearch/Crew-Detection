#figure out ids of previous crews 

#query ii data
ii_roster_q <- "SELECT * FROM `n3-main.invis_inst.roster`"
ii_roster <- bq_project_query("n3-main", ii_roster_q) %>% bq_table_download() %>%
  mutate(full_name = str_to_upper(full_name))

#link uids of crews 
FinneganCrew = c(3456, 23841, 27778, 20038, 12074, 22282, 1868, 29612, 8562, 17042, 25206, 12825, 25306, 22235, 3454)
wattsOfficers = c(7780, 24399, 2334, 3564, 10361, 13777, 15883, 16181, 19331, 20481, 23933, 26902, 27101, 27871, 30215, 31456, 3584)
skullCap = c(25503, 25732, 25962, 27439, 32384)
austinSeven = c(5722, 13082, 19484, 23417, 26243, 28927, 31438)

#get officers that aren't automatically matched
ii_roster %>%
  filter(link_uid %in% FinneganCrew) %>%
  left_join(copa_named, by = c("first_name" = "accused_first_name", 
                               "last_name" = "accused_last_name")) %>%
  distinct(first_name, last_name, .keep_all = TRUE) %>%
  filter(is.na(full_name.y)) %>%
  #everything is matched here- need to check accuracy of match
  View()

#4/17 not matched
ii_roster %>%
  filter(link_uid %in% wattsOfficers) %>%
  left_join(copa_named, by = c("first_name" = "accused_first_name", 
                               "last_name" = "accused_last_name")) %>%
  distinct(first_name, last_name, .keep_all = TRUE) %>%
  filter(is.na(full_name.y)) %>%
  View()

#we lose one of the skullcap crew by not matching link_uid? linkuid: 32384
ii_roster %>%
  filter(link_uid %in% skullCap)%>%
  left_join(copa_named, by = c("first_name" = "accused_first_name", 
                               "last_name" = "accused_last_name")) %>%
  distinct(first_name, last_name, .keep_all = TRUE) %>%
  filter(is.na(full_name.y)) %>%
  View()

#we lose a lot of officers in link here: older crew?
ii_roster %>%
  filter(link_uid %in% austinSeven)%>%
  left_join(copa_named, by = c("first_name" = "accused_first_name", 
                               "last_name" = "accused_last_name")) %>%
  distinct(first_name, last_name, .keep_all = TRUE) %>%
  filter(is.na(full_name.y)) %>%
  View()

#a manual list of crew members who weren't matched:
unmatched_uid <- c(19484, 28927, 5722, 23417, 26243, 13082, 23933, 26902, 27871, 
                   20481)

unmatched_ii <- ii_roster %>% filter(link_uid %in% unmatched_uid)

#some creative matching strategies:
unmatched_ii %>% 
  left_join(copa_named, by = c("last_name" = "accused_last_name", "birth_year" = "accused_birth_year")) %>%
  distinct(full_name.y, .keep_all = TRUE) %>%
  View()


#here are 4 good matches
star_match <- unmatched_ii %>%
  left_join(copa_named, by = c("star1" = "accused_star")) %>%
  distinct(full_name.y, .keep_all = TRUE) %>%
  #filtering out the incorrect matches
  filter(full_name.y != "JUSTIN CONNER")

unmatched_ii <- unmatched_ii%>% anti_join(star_match)

#more investigative journalism

#find the UoF allegation
copa_full %>% 
  filter(complaint_date == ymd("1996-10-14"))

#what does the span of outcomes look like
ggplot(data = copa_full ) + geom_b

table(copa_full$initial_finding, copa_full$incident_datetime)

copa_full %>% 
  drop_na(initial_finding) %>%
  group_by(year(incident_datetime)) %>%
  summarise(count = n()) %>%
  View()

copa_full %>%
  group_by(year(incident_datetime), is.na(initial_finding)) %>%
  summarise(count = n()) %>%
  View()

ii_comp_q <-  "SELECT * FROM `n3-main.invis_inst.complaint_officers`"
complaints_ii <- bq_project_query("n3-main", ii_comp_q) %>% bq_table_download() %>%
  mutate(full_name = str_to_upper(full_name))



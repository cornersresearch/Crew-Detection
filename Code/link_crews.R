#link uids of crews 
#fine time range, around 2004
FinneganCrew = c(3456, 23841, 27778, 20038, 12074, 22282, 1868, 29612, 8562, 
                 17042, 25206, 12825, 25306, 22235, 3454)
#good time range, around 2010
wattsOfficers = c(7780, 24399, 2334, 3564, 10361, 13777, 15883, 16181, 19331, 
                  20481, 23933, 26902, 27101, 27871, 30215, 31456, 3584)
#good time range: around 2012 at least
skullCap = c(25503, 25732, 25962, 27439, 32384)
#they were operating too early to get a clear network view of activity
#data is only consistent from like 98 onwards, and this is like 95 96
#austinSeven = c(5722, 13082, 19484, 23417, 26243, 28927, 31438)

#automatic matching
finn_copa <- ii_roster %>%
  filter(link_uid %in% FinneganCrew) %>%
  left_join(copa_named, by = c("first_name" = "accused_first_name", 
                               "last_name" = "accused_last_name")) %>%
  distinct(first_name, last_name, .keep_all = TRUE) %>%
  mutate(crew = "Finnegan")

watts_copa <- ii_roster %>%
  filter(link_uid %in% wattsOfficers) %>%
  left_join(copa_named, by = c("first_name" = "accused_first_name", 
                               "last_name" = "accused_last_name")) %>%
  distinct(first_name, last_name, .keep_all = TRUE) %>%
  mutate(crew = "Watts")

#this officer is not in our II data, but is a match in the copa data
edwin_row <- copa_roster %>%
  filter(accused_star == 19901) %>%
  mutate(crew = "SkullCap")

skull_copa <- ii_roster %>%
  filter(link_uid %in% skullCap)%>%
  left_join(copa_named, by = c("first_name" = "accused_first_name", 
                               "last_name" = "accused_last_name")) %>%
  distinct(first_name, last_name, .keep_all = TRUE) %>%
  mutate(crew = "SkullCap")

# austin_copa <- ii_roster %>%
#   filter(link_uid %in% austinSeven)%>%
#   left_join(copa_named, by = c("first_name" = "accused_first_name", 
#                                "last_name" = "accused_last_name")) %>%
#   distinct(first_name, last_name, .keep_all = TRUE) %>%
#   mutate(crew = "Austin")
#james young is a bad match, we don't have one
#kenneth young is a bad match, we don't have one

########################Matching improvements ##########################
#a manual list of crew members who weren't matched:
unmatched_uid <- c(23933, 26902, 27871, 
                   20481)
unmatched_ii <- ii_roster %>% filter(link_uid %in% unmatched_uid)

#here are 4 good matches
star_match <- unmatched_ii %>%
  left_join(copa_named, by = c("star1" = "accused_star")) %>%
  distinct(full_name.y, .keep_all = TRUE) %>%
  #filtering out the incorrect matches
  filter(full_name.y != "JUSTIN CONNER") %>%
  mutate(crew = case_when(
    link_uid %in% FinneganCrew ~ "Finnegan", 
    link_uid %in% skullCap ~ "SkullCap", 
    link_uid %in% wattsOfficers ~ "Watts"
  ), accused_star = "") %>%
  select(-c(accused_first_name, accused_last_name))

unmatched_ii <- unmatched_ii%>% anti_join(star_match)

confirmed_crews <- rbind(finn_copa, watts_copa, skull_copa, star_match) %>%
  select(-c(current_status, current_age, current_unit, star5:star10, 
            flag_bad_dates,n_distinct, accused_sex, record_id, accused_apt_date,
            accused_birth_year, accused_race, accused_middle_initial, data_source
  )) %>%
  filter(!(full_name.y %in% c("KENNETH YOUNG"))) %>%
  mutate(link_string = paste0(full_name.y, accused_star)) %>%
  drop_na(full_name.y)

copa_crews <- copa_roster %>% 
  mutate(link_string = paste0(full_name, accused_star)) %>%
  #edwin utreras isn't in II data, but is in COPA, with below badge number
  filter(link_string %in% confirmed_crews$link_string | accused_star == 19901 |
           full_name %in% c("CALVIN RIDGELL JR", "ELSWORTH SAM JR", "GEROME SUMMERS JR", 
                            "DOUGLAS NICHOLS JR")) %>%
  #this is necessary bc one of these officers has a son who took his badge number
  filter(record_id != 1087554)

write.csv(copa_crews, "Datasets/COPA/copa_crews.csv")

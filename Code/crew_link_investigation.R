#link_crews.R must be run first, this is code that is used to potentially generate
#new matches through investigation, but is NOT necessary for project to run

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
# ii_roster %>%
#   filter(link_uid %in% austinSeven)%>%
#   left_join(copa_named, by = c("first_name" = "accused_first_name", 
#                                "last_name" = "accused_last_name")) %>%
#   distinct(first_name, last_name, .keep_all = TRUE) %>%
#   filter(is.na(full_name.y)) %>%
#   View()

#some creative matching strategies:
unmatched_ii %>% 
  select(-c(gender, current_status, current_age, star4:star10, flag_bad_dates)) %>%
  left_join(copa_named, by = c("last_name" = "accused_last_name", "birth_year" = "accused_birth_year")) %>%
  distinct(full_name.y, .keep_all = TRUE) %>%
  View()
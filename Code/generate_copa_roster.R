#construct a unique ID for each officer in the database

copa_named <- copa_full %>% 
  select(-c(found_address, street_number, street, status, partial_match, 
            geometry, current_penalty, initial_finding, zip_postal_code, 
            initial_penalty, inv_race, inv_star, end_addr_range, 
            error_geocoding, street_side, full_address, lat, address_match, 
            long, current_finding, comm_area_name, comm_area_num, sector, 
            investigator, cpdmember_complaint, address_type, direction, 
            accused_detailed_unit, accused_assignment, allegation_description, 
            district, reporting_category, accused_assigned_unit, allegation_key, 
            inv_rank, inv_gender, beat, accused_on_duty, closed_date, 
            accused_position_rank, allegation_code, data_group, complaint_date
  )) %>%
  mutate_if( is.character, na_if, "") %>%
  drop_na(accused_first_name, accused_last_name) %>%
  # mutate(full_name = ifelse(
  #   !is.na(accused_middle_initial), paste(accused_first_name, accused_middle_initial,
  #                                         accused_last_name, sep = " "), 
  #   paste(accused_first_name, accused_last_name, sep = " ")
  #we were generating extra ids , so full name is now just first + last
  mutate(full_name = paste(accused_first_name, accused_last_name, sep = " ")) %>%
  mutate(full_name = str_to_upper(full_name)) %>%
  group_by(full_name) %>%
  mutate(n_distinct = n_distinct(accused_birth_year)) %>%
  arrange(desc(n_distinct), full_name) 

#roughly 30K / 120K complaints do not have first or last name attached to acc.

#current idea- if 2/3 or more metrics (to be decided) don't match, generate new id



generate_ids <- function(dataset, name, id_index) {
  distance_count = 0
  grouping_var <- NA
  
  possible_matches <- dataset %>%
    filter(full_name == name)
  
  if(n_distinct(possible_matches$accused_birth_year, na.rm = TRUE) > 1) {
    distance_count <- distance_count + 1
    grouping_var <- "accused_birth_year"
  }
  
  if(n_distinct(possible_matches$accused_apt_date, na.rm = TRUE) > 1) {
    distance_count <- distance_count + 1
    grouping_var <- "accused_apt_date"
  }
  
  # if(n_distinct(possible_matches$accused_star) > 1) {
  #   distance_count <- distance_count + 1
  #   #grouping_var <- "accused_star"
  # }
  
  if(distance_count >= 2) {
    possible_matches <- possible_matches %>%
      group_by(full_name, !!! rlang::syms(grouping_var)) %>%
      mutate(link_id = paste0(id_index, cur_group_id()))
  } else {
    possible_matches$link_id = paste0(id_index, "0")
  }
  
  
  #if distance count is 2 or greater, than group by the latest grouping var
  #need to see if there are cases where this isn't enough
  
  return(possible_matches)
}


test_ids <- generate_ids(copa_named, "KEVIN CONNORS", 43)

copa_empty <- copa_named[0,] %>%
  mutate(link_id = "")

id_no <- 1
for (full_name in unique(copa_named$full_name)) {
  id_frame <- generate_ids(copa_named, full_name, id_no)
  
  id_no <- id_no + 1
  
  copa_empty <- rbind(copa_empty, id_frame)
  
  # full_copa_ids <- copa_named %>%
  #   left_join(transmute(id_frame, full_name, incident_datetime, link_id), by = 
  #               c(full_name, incident_datetime))
  
}

copa_roster <- copa_empty %>% 
  distinct(link_id, .keep_all = TRUE) 

write.csv(copa_roster, "Datasets/COPA/copa_roster.csv")

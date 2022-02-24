library(pacman)
p_load(readr, tidyverse, bigrquery, lubridate, dplyr, hyperion, sf)

supp_path <- "~/Documents/GitHub/Crew-Detection/supp_analyses/"
off_comm_assign <- read_csv("Documents/GitHub/Crew-Detection/Datasets/Officer_Community_Assignments.csv")

arr_by_off_q <-  "SELECT * FROM `n3-main.invis_inst.officer_arrests`"
arrests_by_officer <- bq_project_query("n3-main", arr_by_off_q) %>% bq_table_download()

arrest_q <- "SELECT * FROM `n3-main.cpd_anon.arrests`"
arrests <- bq_project_query("n3-main", arrest_q) %>% bq_table_download()

cpd_beats_q <- "SELECT * FROM `n3-main.spatial.cpd_beats_post_2013`"
cpd_beats <- bq_project_query("n3-main", cpd_beats_q) %>% bq_table_download()
cpd_beats <- st_as_sf(cpd_beats, wkt = "geometry")

crew_roster <- off_comm_assign %>%
  filter(Crew == "Watts") %>%
  select(1:14)

crew_arrest <- arrests_by_officer %>%
  filter(link_uid %in% crew_roster$UID)

#this is techinically the active range for the watts crew
range(crew_arrest$arrest_date, na.rm = TRUE)
#peak years are probably closer to 2000 - 2010
hist(crew_arrest$arrest_date, breaks = 200)

comparison_start <- ymd("2003-11-24")
comparison_end <- ymd("2012-02-12")

baseline_arrests <- arrests_by_officer %>%
  filter(arrest_date >= comparison_start &
           arrest_date <= comparison_end) %>%
  mutate(watts_crew = ifelse(link_uid %in% crew_roster$UID, "Watts Crew", "Non-Watts CPD")) 

crew_arrest_comp <- crew_arrest %>%
  filter(arrest_date >= comparison_start &
           arrest_date <= comparison_end)

perc_crew_total <- 100*length((crew_arrest_comp$cb_no))/ length(unique(baseline_arrests$cb_no))

#what percentage of the office force do the watts crew make up during this time?
crew_count <- length(unique(crew_arrest_comp$link_uid))
officer_comp_count <- length(unique(baseline_arrests$link_uid))
force_perc = 100*crew_count / officer_comp_count

#what is the over-representation of the watts crew in arrests vs force average
#during time period of study? 
perc_crew_total / force_perc

#figure generation
baseline_arrests %>%
  group_by(watts_crew) %>%
  summarise(arrests_per_officer = length(unique(cb_no))/ length(unique(link_uid)))

crew_count <- baseline_arrests %>%
  group_by(watts_crew) %>%
  summarise(crew_count = n()) 
arrest_by_type <- baseline_arrests %>%
  group_by(watts_crew, fbi_code) %>%
  summarise(type_of_crime = fbi_code, watts_crew = watts_crew, count = n())
  
arrest_by_type <- baseline_arrests %>%
  group_by(fbi_code) %>%
  summarise(count = n())


table(baseline_arrests$fbi_code)

crew_arr_type <- baseline_arrests %>%
  group_by(watts_crew, fbi_code) %>%
  summarise(count = n()) %>%
  left_join(crew_count, by = c("watts_crew")) %>%
  mutate(perc_of_arrests = 100*count / crew_count) %>%
  ungroup() %>%
  group_by(watts_crew) %>%
  arrange(desc(perc_of_arrests)) %>%
  filter(perc_of_arrests > 1) %>%
  group_by(fbi_code) %>%
  mutate(box_count = n()) %>%
  filter(box_count > 1)

ggplot() + geom_col(data = crew_arr_type, aes(x = watts_crew, y = perc_of_arrests, color = watts_crew))+
  facet_wrap(vars(fbi_code)) + hyperion::hype_theme_light() + 
  theme(axis.text.x = element_text(angle = 25, vjust = .5)) + 
  labs(title = "Rate of Arrest Type", subtitle = "Comparison between Watts Crew and Non-Watts CPD", x = "", y = "Percentage of Arrests for Crime Type")
ggsave(paste0(supp_path, "watts_arrest_type.png"))
 
#assess geographic range of watts crew
arrest_beats <- cpd_beats %>%
  left_join(baseline_arrests, by = c("beat_num" = "arr_beat")) %>%
  mutate(watts_crew_num = ifelse(watts_crew == "Watts Crew", 1, 0)) %>%
  group_by(beat_num) %>%
  summarise(count = n(), prop_watts = sum(watts_crew_num)) %>%
  mutate(prop_watts = ifelse(is.na(prop_watts), 0, prop_watts)) %>%
  filter(prop_watts > 0)
  


ggplot() + geom_sf(data = cpd_beats, alpha = .4) + 
  geom_sf(data = arrest_beats, aes(fill = prop_watts, geometry = geometry)) + 
  hype_theme_light() + guides(fill=guide_legend(title="Watts Crew Arrests")) + 
  labs(title = "Distribution of 'Watts Crew' Arrests", subtitle = "During Peak Years of Activity across CPD Beats") +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.border = element_blank(), panel.background = element_blank(),
        axis.text.x = element_blank(), axis.text.y = element_blank()) 
ggsave(paste0(supp_path, "watts_arrest_map.png"))


ggplot() + geom_histogram(data = crew_arrest, aes(arrest_date)) + 
  geom_vline(data = crew_roster, aes(xintercept = mdy(appointed_date), color = "Appointment Date")) + 
  geom_vline(data = crew_roster, aes(xintercept = mdy(resignation_date), color = "Retirement Date")) + hype_theme_light() + 
  labs(title=  "Peak Years of 'Watts Crew' Activity", x = "Date", y = "Number of Arrests") + 
  geom_vline(aes(xintercept = ymd("12-02-12"), color = "Watts Arrested in Sting Operation"))
ggsave(paste0(supp_path, "watts_arrest_timeline.png"))

#answering questions
on_the_street <- arrests_by_officer %>%
  group_by(link_uid) %>%
  summarise(count = n()) %>%
  filter(count > 10)
mean(on_the_street$count)




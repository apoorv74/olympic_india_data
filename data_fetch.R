


# Master URL --------------------------------------------------------------
url <- 'https://www.rio2016.com/en/india'

library(tidyr)
library(reshape2)

# Athlete Profile ---------------------------------------------------------

name_css_path <- '.athletes-teams-graphic__full-list-name'
gender_css_path <- '.athletes-teams-graphic__full-list-gender'
sports_css_path <- '.athletes-teams-graphic__full-list-sport'
name_data <- url %>% read_html() %>% html_nodes(css = name_css_path) %>% html_text()
gender_data <- url %>% read_html() %>% html_nodes(css = gender_css_path) %>% html_text()
sports_data <- url %>% read_html() %>% html_nodes(css = sports_css_path) %>% html_text()

athlete_profile <- data.frame('name' = name_data, 'gender' = gender_data, 'sport' = sports_data)

sports <- athlete_profile %>% group_by(sport) %>% summarise(num_players = length(sport))

name_url <- '.athletes-teams-graphic__full-list-content-list a'
player_url <- url %>% read_html() %>% html_nodes(css = name_url) %>% html_attrs()
player_url <- unlist(player_url,use.names = F)
player_url <- str_replace_all(player_url,'/en/athlete/','')

athlete_profile$name_url <- player_url

css_num_events <- '.hero-profile__table-body-item'
events_master <- c()
for(i in 1:nrow(athlete_profile)){
  url <- paste0('https://www.rio2016.com/en/athlete/',athlete_profile$name_url[i])
  events_data <- url %>% read_html() %>% html_nodes(css = css_num_events) %>% html_text()
  events_master <- rbind(events_master,events_data)
}

num_events <- as.vector(events_master[,2])
athlete_profile$num_events <- num_events


# Events Data -------------------------------------------------------------

athlete_details <-  ".about__col--data"
url <- paste0('https://www.rio2016.com/en/athlete/',athlete_profile$name_url[i])
athlete_det <- url %>% read_html() %>% html_nodes(css = athlete_details) %>% html_text()







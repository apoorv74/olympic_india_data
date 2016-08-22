


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
athlete_profile$athlete_id <- 1:nrow(athlete_profile)


# Events Data -------------------------------------------------------------

athlete_details <-  ".about__col--data"
details_master <- data.frame('name' = NA,'dob' = NA,'height_weight' = NA,'event' = NA,'athlete_id' = NA,'event_url' = NA)
for(j in 1:nrow(athlete_profile))
{
url <- paste0('https://www.rio2016.com/en/athlete/',athlete_profile$name_url[j])
details_xpath <- '//*[@id="about"]/article/table'

athlete_det <- url %>% read_html() %>% html_nodes(xpath = details_xpath) %>% html_table()
athlete_det <- data.frame(athlete_det)
athlete_det <- setNames(as.list(athlete_det$X2),athlete_det$X1)

event_url <- url %>% read_html() %>% html_nodes(css = '.about__event-link') %>% html_attr('href')
event_url <- str_replace_all(event_url,'/en/','https://www.rio2016.com/en/')
events <- (strsplit(athlete_det$Events,'\r\n')[[1]])
events <- events[events!= '']
num_events <- athlete_profile$num_events[j]
details_sub <- data.frame('name' = NA,'dob' = NA,'height_weight' = NA,'event' = NA,'athlete_id' = NA,'event_url' = NA)
for(k in 1:num_events){
  details <- data.frame('name' = athlete_det$`Full name`,'dob' = athlete_det$`Date of birth`, 'height_weight' = ifelse(length(athlete_det$`Height and weight`) == 1,athlete_det$`Height and weight`,'No_data'), 'event' =  events[k],'athlete_id' = j,'event_url' = event_url[k])
  details_sub <- rbind(details_sub,details)
}
details_master <- rbind(details_master,details_sub)
details_master <- details_master[!is.na(details_master$name),]
}






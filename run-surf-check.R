##################################################################
#     Automated Surf Forecast                                    #
##################################################################


# Setup -----------------------------------------------------------
library(bomrang) 
library(gmailr)
library(glue)
library(dplyr)
library(lubridate)
library(gmailr)

# authentication for gmail API
gmailr::use_secret_file('surf-check-221823.json')

# params
from <- to <- "deanmarchiori@gmail.com"
state <- "NSW"
forecast_district <- "Illawarra"
synoptic_img <- "http://www.bom.gov.au/fwo/IDG00074.gif"

# Run Forecast ------------------------------------------------------------

forecast <- bomrang::get_coastal_forecast(state = state) %>% filter(dist_name == forecast_district)

subject <- glue::glue("Surf Forecast - {forecast$dist_name[1]} - {Sys.time()}")

body <- glue::glue(
"

{lubridate::wday(forecast$start_time_local, label = TRUE, abbr = FALSE)} {as.Date(forecast$start_time_local, tz = 'Australia/Sydney')} will be {forecast$forecast_weather}
The swell is {forecast$forecast_swell1}  
Winds are {forecast$forecast_winds}  

Cautions: {forecast$forecast_caution}  
Warnings: {forecast$marine_forecast}



")

body <- paste(body, collapse = " ")


# Download Weather Map ----------------------------------------------------

tf <- tempfile(fileext = ".gif")
download.file(url = synoptic_img, destfile = tf, mode = "wb")


# Send Mail ---------------------------------------------------------------
msg <- gmailr::mime() %>%
  gmailr::subject(subject) %>% 
  gmailr::to(to) %>%
  gmailr::from(from) %>% 
  gmailr::text_body(body) %>% 
  gmailr::attach_part(body) %>% 
  gmailr::attach_file(tf)

gmailr::send_message(msg)

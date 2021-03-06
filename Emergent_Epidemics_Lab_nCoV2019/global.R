#SV Scarpino - I Ait-Bouziad
#nCov2019
#Jan 27th 2020

#libraries
library(googlesheets4)
library(dplyr)


#globals
cols_to_use <- c("ID", "age", "sex", "city", "province", "country", "date_onset_symptoms", "date_admission_hospital", "date_confirmation", "symptoms", "lives_in_Wuhan", "travel_history_dates", "travel_history_location", "reported_market_exposure", "sequence_available", "outcome", "source")

mapbox_accessToken <- readLines("secrets/mapboxkey.txt")
map_url <- "mapbox://styles/scarpino/ck4zuxput0zz71dlkntkup80v"
google_sheet_name <- readLines("secrets/google_sheet_name.txt")

options(mapbox.accessToken = mapbox_accessToken)



#data
sheets_auth(path = "secrets/service_google_api_key.json")

wuhan_data <- read_sheet(
  ss = google_sheet_name,
  sheet = 'Hubei',
)



#changing wuhan resident column
find_Wuhan_resident <- which(colnames(wuhan_data) == "Wuhan_resident")
if(length(find_Wuhan_resident) == 1){
  colnames(wuhan_data)[find_Wuhan_resident] <- "lives_in_Wuhan" #this is the column in the outside wuhan sheet
}

wuhan_data$ID <- paste0(wuhan_data$ID, "-Wuhan")

outside_wuhan_data <- read_sheet(
  ss = google_sheet_name,
  sheet = 'outside_Hubei',
)


outside_wuhan_data$ID <- paste0(outside_wuhan_data$ID, "-Outside-Wuhan")

outside_wuhan_data$data_moderator_initials <- NULL 

full_data <- rbind(wuhan_data, outside_wuhan_data)

full_data$latitude <- jitter(full_data$latitude, factor = 30)
full_data$longitude <- jitter(full_data$longitude, factor = 30)

full_data$date_admission_hospital <- as.POSIXct(strptime(full_data$date_admission_hospital, format = "%d.%m.%Y"))
full_data$date_confirmation <- as.POSIXct(strptime(full_data$date_confirmation, format = "%d.%m.%Y"))
full_data$date_onset_symptoms <- as.POSIXct(strptime(full_data$date_onset_symptoms, format = "%d.%m.%Y"))




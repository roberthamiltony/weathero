
# Weathero
A simple weather app, showing the next hour and next days summary, using the WeatherKit Rest API.

The architecture approach is to use MVVM-C, with view controllers defining their interface with prospective coordinators.
Views define their own models rather than depending on WeatherKit models to avoid coupling with any specific API. 

The app uses the WeatherClassifications to guide UI - these are just the authors opinions rather than based off anything official.

## TODO
- Move the token to a proxy service and add some authentication
- Add more weather detail, like a current or specific day detail view.
- Save locations for easy access

## WeatherKit Token
To get a WeatherKit token, generate one using this guide: https://developer.apple.com/documentation/weatherkitrestapi/request_authentication_for_weatherkit_rest_api
Alternatively, email me and I will share mine 

module CalcHelper
  def stadium_weather(zipcode)
    require 'open-uri'
    require 'json'

    url = "http://api.wunderground.com/api/65bd4b6d02af0c3b/hourly/q/#{zipcode}.json"
    re = []
    open(url) do |f|
      json_string = f.read
      parsed_json = JSON.parse(json_string)
      forecast_data = parsed_json['hourly_forecast']
      (0..2).each do |i|
        hour_data = forecast_data[i]
        data = {temp: hour_data['temp']['english'], humidity: hour_data['humidity'], dew: hour_data['dewpoint']['english'], pressure: hour_data['mslp']['english'], wind_dir: hour_data['wdir']['dir'], wind_speed: hour_data['wspd']['english'].to_f}
        re << data
      end
    end

    return re
  end
end

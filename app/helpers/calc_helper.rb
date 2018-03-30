module CalcHelper
  include GetHtml
  def wunderground_weather(zipcode)
    require 'open-uri'
    require 'json'

    zipcode = 'M5V1J1' if zipcode == 'M5V 1J1'
    url = "http://api.wunderground.com/api/65bd4b6d02af0c3b/hourly/q/#{zipcode}.json"
    re = []
    open(url) do |f|
      json_string = f.read
      parsed_json = JSON.parse(json_string)
      forecast_data = parsed_json['hourly_forecast']
      count = 0
      forecast_data.each do |hour_data|
        break if count == 12
        data = {temp: hour_data['temp']['english'], humidity: hour_data['humidity'], dew: hour_data['dewpoint']['english'], pressure: hour_data['mslp']['english'], wind_dir: hour_data['wdir']['dir'], wind_speed: hour_data['wspd']['english'].to_f}
        re << data
        count = count + 1
      end
    end

    return re
  end

  def weather_weather(zipcode)
    url = "https://weather.com/weather/hourbyhour/l/#{zipcode}:4:US"
    url = 'https://weather.com/weather/hourbyhour/l/CAXX0504:1:CA' if zipcode == 'M5V 1J1'
    doc = download_document(url)
    puts url

    return [] unless doc
    re = []
    hourlyweathers = doc.css('.twc-table tbody tr')
    hourlyweathers.each_with_index do |weather, index|
      break if count == 12
      time = weather.children[1].children[0].children[0].children[0].text.squish
      minute_index = time.index(':')
      next unless minute_index && time[minute_index+1..minute_index+2] == '00'
      temp = weather.children[3].children[0].children[0].children[0].text.squish
      hum = weather.children[6].children[0].children[0].children[0].text.squish
      wind = weather.children[7].children[0].children[0].children[0].text.squish
      wind_index = wind.rindex(' ')
      wind_dir = wind[wind_index+1..-1]
      wind_speed = wind[0..wind_index-1]
      data = {temp: temp, humidity: hum, dew: '', pressure: '', wind_dir: wind_dir, wind_speed: wind_speed.to_f}
      re << data
      count = count + 1
    end
    return re
  end
end

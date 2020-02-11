module CalcHelper
  @@urls = [
      "https://www.wunderground.com/hourly/us/ca/anaheim/92806?cm_ven=localwx_hour",
      "https://www.wunderground.com/hourly/us/tx/houston/77002?cm_ven=localwx_hour",
      "https://www.wunderground.com/hourly/us/ca/oakland/94621?cm_ven=localwx_hour",
      "https://www.wunderground.com/hourly/ca/toronto?cm_ven=localwx_hour",
      "https://www.wunderground.com/hourly/us/ga/atlanta/30339?cm_ven=localwx_hour",
      "https://www.wunderground.com/hourly/us/wi/milwaukee/53214?cm_ven=localwx_hour",
      "https://www.wunderground.com/hourly/us/mo/saint-louis/63102?cm_ven=localwx_hour",
      "https://www.wunderground.com/hourly/us/il/chicago/60613?cm_ven=localwx_hour",
      "https://www.wunderground.com/hourly/us/az/phoenix/85004?cm_ven=localwx_hour",
      "https://www.wunderground.com/hourly/us/ca/los-angeles/90012?cm_ven=localwx_hour",
      "https://www.wunderground.com/hourly/us/ca/san-francisco/94107?cm_ven=localwx_hour",
      "https://www.wunderground.com/hourly/us/oh/cleveland/44115?cm_ven=localwx_hour",
      "https://www.wunderground.com/hourly/us/wa/seattle/98134?cm_ven=localwx_hour",
      "https://www.wunderground.com/hourly/us/fl/miami/33125?cm_ven=localwx_hour",
      "https://www.wunderground.com/hourly/us/ny/corona/11368?cm_ven=localwx_hour",
      "https://www.wunderground.com/hourly/us/dc/washington/20003?cm_ven=localwx_hour",
      "https://www.wunderground.com/hourly/us/md/baltimore/21201?cm_ven=localwx_hour",
      "https://www.wunderground.com/hourly/us/ca/san-diego/92101?cm_ven=localwx_hour",
      "https://www.wunderground.com/hourly/us/pa/philadelphia/19148?cm_ven=localwx_hour",
      "https://www.wunderground.com/hourly/us/pa/pittsburgh/15212?cm_ven=localwx_hour",
      "https://www.wunderground.com/hourly/us/tx/arlington/76011?cm_ven=localwx_hour",
      "https://www.wunderground.com/hourly/us/fl/saint-petersburg/33705?cm_ven=localwx_hour",
      "https://www.wunderground.com/hourly/us/ma/boston/02215?cm_ven=localwx_hour",
      "https://www.wunderground.com/hourly/us/oh/cincinnati/45202?cm_ven=localwx_hour",
      "https://www.wunderground.com/hourly/us/co/denver/80205?cm_ven=localwx_hour",
      "https://www.wunderground.com/hourly/us/mo/64129?cm_ven=localwx_hour",
      "https://www.wunderground.com/hourly/us/mi/detroit/48201?cm_ven=localwx_hour",
      "https://www.wunderground.com/hourly/us/mn/minneapolis/55403?cm_ven=localwx_hour",
      "https://www.wunderground.com/hourly/us/il/chicago/60616?cm_ven=localwx_hour",
      "https://www.wunderground.com/hourly/us/ny/bronx/10451?cm_ven=localwx_hour"
  ]

  @@url = [
    "https://api.weather.com/v3/wx/forecast/hourly/1day?apiKey=6532d6454b8aa370768e63d6ba5a832e&geocode=33.8%2C-117.88&units=e&language=en-US&format=json",
    "https://api.weather.com/v3/wx/forecast/hourly/1day?apiKey=6532d6454b8aa370768e63d6ba5a832e&geocode=29.76%2C-95.36&units=e&language=en-US&format=json",
    "https://api.weather.com/v3/wx/forecast/hourly/1day?apiKey=6532d6454b8aa370768e63d6ba5a832e&geocode=37.75%2C-122.2&units=e&language=en-US&format=json",
    "https://api.weather.com/v3/wx/forecast/hourly/1day?apiKey=6532d6454b8aa370768e63d6ba5a832e&geocode=43.65%2C-79.39&units=e&language=en-US&format=json",
    "https://api.weather.com/v3/wx/forecast/hourly/1day?apiKey=6532d6454b8aa370768e63d6ba5a832e&geocode=33.88%2C-84.47&units=e&language=en-US&format=json",
    "https://api.weather.com/v3/wx/forecast/hourly/1day?apiKey=6532d6454b8aa370768e63d6ba5a832e&geocode=43.03%2C-87.97&units=e&language=en-US&format=json",
    "https://api.weather.com/v3/wx/forecast/hourly/1day?apiKey=6532d6454b8aa370768e63d6ba5a832e&geocode=38.62%2C-90.19&units=e&language=en-US&format=json",
    "https://api.weather.com/v3/wx/forecast/hourly/1day?apiKey=6532d6454b8aa370768e63d6ba5a832e&geocode=41.95%2C-87.65&units=e&language=en-US&format=json",
    "https://api.weather.com/v3/wx/forecast/hourly/1day?apiKey=6532d6454b8aa370768e63d6ba5a832e&geocode=33.45%2C-112.07&units=e&language=en-US&format=json",
    "https://api.weather.com/v3/wx/forecast/hourly/1day?apiKey=6532d6454b8aa370768e63d6ba5a832e&geocode=34.05%2C-118.24&units=e&language=en-US&format=json",
    "https://api.weather.com/v3/wx/forecast/hourly/1day?apiKey=6532d6454b8aa370768e63d6ba5a832e&geocode=37.78%2C-122.4&units=e&language=en-US&format=json",
    "https://api.weather.com/v3/wx/forecast/hourly/1day?apiKey=6532d6454b8aa370768e63d6ba5a832e&geocode=41.5%2C-81.68&units=e&language=en-US&format=json",
    "https://api.weather.com/v3/wx/forecast/hourly/1day?apiKey=6532d6454b8aa370768e63d6ba5a832e&geocode=47.59%2C-122.33&units=e&language=en-US&format=json",
    "https://api.weather.com/v3/wx/forecast/hourly/1day?apiKey=6532d6454b8aa370768e63d6ba5a832e&geocode=25.78%2C-80.22&units=e&language=en-US&format=json",
    "https://api.weather.com/v3/wx/forecast/hourly/1day?apiKey=6532d6454b8aa370768e63d6ba5a832e&geocode=40.75%2C-73.85&units=e&language=en-US&format=json",
    "https://api.weather.com/v3/wx/forecast/hourly/1day?apiKey=6532d6454b8aa370768e63d6ba5a832e&geocode=38.87%2C-77.01&units=e&language=en-US&format=json",
    "https://api.weather.com/v3/wx/forecast/hourly/1day?apiKey=6532d6454b8aa370768e63d6ba5a832e&geocode=39.29%2C-76.62&units=e&language=en-US&format=json",
    "https://api.weather.com/v3/wx/forecast/hourly/1day?apiKey=6532d6454b8aa370768e63d6ba5a832e&geocode=32.71%2C-117.16&units=e&language=en-US&format=json",
    "https://api.weather.com/v3/wx/forecast/hourly/1day?apiKey=6532d6454b8aa370768e63d6ba5a832e&geocode=39.91%2C-75.17&units=e&language=en-US&format=json",
    "https://api.weather.com/v3/wx/forecast/hourly/1day?apiKey=6532d6454b8aa370768e63d6ba5a832e&geocode=40.45%2C-80.01&units=e&language=en-US&format=json",
    "https://api.weather.com/v3/wx/forecast/hourly/1day?apiKey=6532d6454b8aa370768e63d6ba5a832e&geocode=32.75%2C-97.08&units=e&language=en-US&format=json",
    "https://api.weather.com/v3/wx/forecast/hourly/1day?apiKey=6532d6454b8aa370768e63d6ba5a832e&geocode=27.77%2C-82.65&units=e&language=en-US&format=json",
    "https://api.weather.com/v3/wx/forecast/hourly/1day?apiKey=6532d6454b8aa370768e63d6ba5a832e&geocode=42.35%2C-71.1&units=e&language=en-US&format=json",
    "https://api.weather.com/v3/wx/forecast/hourly/1day?apiKey=6532d6454b8aa370768e63d6ba5a832e&geocode=39.1%2C-84.51&units=e&language=en-US&format=json",
    "https://api.weather.com/v3/wx/forecast/hourly/1day?apiKey=6532d6454b8aa370768e63d6ba5a832e&geocode=39.76%2C-104.99&units=e&language=en-US&format=json",
    "https://api.weather.com/v3/wx/forecast/hourly/1day?apiKey=6532d6454b8aa370768e63d6ba5a832e&geocode=39.05%2C-94.48&units=e&language=en-US&format=json",
    "https://api.weather.com/v3/wx/forecast/hourly/1day?apiKey=6532d6454b8aa370768e63d6ba5a832e&geocode=42.34%2C-83.05&units=e&language=en-US&format=json",
    "https://api.weather.com/v3/wx/forecast/hourly/1day?apiKey=6532d6454b8aa370768e63d6ba5a832e&geocode=44.97%2C-93.28&units=e&language=en-US&format=json",
    "https://api.weather.com/v3/wx/forecast/hourly/1day?apiKey=6532d6454b8aa370768e63d6ba5a832e&geocode=41.86%2C-87.62&units=e&language=en-US&format=json",
    "https://api.weather.com/v3/wx/forecast/hourly/1day?apiKey=6532d6454b8aa370768e63d6ba5a832e&geocode=40.83%2C-73.92&units=e&language=en-US&format=json"
  ]
  
  include GetHtml
  def wunderground_weather(id)
    url = @@url[id-1]
    result = JSON.load(open(url))

    re = []
    result_length = result["dayOfWeek"].select{|d| d == Date.today.strftime("%A")}.count
    (0...result_length).each do |res|
      temp = result["temperature"][res]
      dp = result["temperatureDewPoint"][res]
      hum = result["relativeHumidity"][res]
      pressure = result["pressureMeanSeaLevel"][res]
      wind_speed = result["windSpeed"][res]
      wind_dir = result["windDirectionCardinal"][res]

      data = {
            temp: temp,
            humidity: hum,
            dew: dp,
            pressure: pressure,
            wind_dir: wind_dir,
            wind_speed: wind_speed
        }
        re << data
    end

  return re


=begin
    url = @@urls[id-1]
    doc = download_document(url)
    puts url

    return unless doc
    header = doc.css("#hourly-forecast-table tr").first

    puts header
    return unless header
    headers = {
        'Temp.' => 0,
        'Dew Point' => 0,
        'Humidity' => 0,
        'Pressure' => 0,
        'Wind' => 0,
        'Amount' => 0,
        'Feels Like' => 0
    }

    header.children.each_with_index do |header_element, index|
      key = header_element.text.squish
      headers[key] = index if key == 'Temp.'
      headers[key] = index if key == 'Dew Point'
      headers[key] = index if key == 'Humidity'
      headers[key] = index if key == 'Pressure'
      headers[key] = index if key == 'Wind'
      headers[key] = index if key == 'Amount'
      headers[key] = index if key == 'Feels Like'
    end

    re = []
    hourlyweathers = doc.css("#hourly-forecast-table tbody tr")
    (0...hourlyweathers.length).each do |index|
      temp = hourlyweathers[index].children[headers['Temp.']].text.squish
      dp = hourlyweathers[index].children[headers['Dew Point']].text.squish
      hum = hourlyweathers[index].children[headers['Humidity']].text.squish
      pressure = hourlyweathers[index].children[headers['Pressure']].text.squish
      # precip = hourlyweathers[index].children[headers['Amount']].text.squish
      wind = hourlyweathers[index].children[headers['Wind']].text.squish
      # feel = hourlyweathers[index].children[headers['Feels Like']].text.squish
      wind_index = wind.rindex(' ')
      wind_dir = wind[wind_index+1..-1]
      if wind_dir == "W"
        wind_dir = "West"
      elsif wind_dir == "S"
        wind_dir = "South"
      elsif wind_dir == "N"
        wind_dir = "North"
      elsif wind_dir == "E"
        wind_dir = "East"
      end
      wind_speed = wind[0..wind_index-1]
      temp = temp.split(' °F')[0].to_i
      hum = hum.split('%')[0].to_i
      dp = dp.split(' °F')[0].to_i
      pressure = pressure.split(' in')[0].to_f
      wind_speed = wind_speed.split(' mph')[0].to_i
      data = {
          temp: temp,
          humidity: hum,
          dew: dp,
          pressure: pressure,
          wind_dir: wind_dir,
          wind_speed: wind_speed
      }
      re << data
    end

    return re
=end
  end

  def weather_weather(zipcode)
    url = "https://weather.com/weather/hourbyhour/l/#{zipcode}:4:US"
    url = 'https://weather.com/weather/hourbyhour/l/CAXX0504:1:CA' if zipcode == 'M5V 1J1'
    doc = download_document(url)
    puts url

    return [] unless doc
    re = []
    count = 0
    hourlyweathers = doc.css('.twc-table tbody tr')
    hourlyweathers.each_with_index do |weather, index|
      break if count == 12
      time = weather.children[1].children[0].children[0].children[0].text.squish
      minute_index = time.index(':')
      next unless minute_index && time[minute_index+1..minute_index+2] == '00'
      temp = weather.children[3].children[0].children[0].text.squish
      hum = weather.children[6].children[0].children[0].text.squish
      wind = weather.children[7].children[0].children[0].text.squish
      wind_index = wind.index(' ')
      wind_speed = wind[wind_index+1..-1]
      wind_dir = wind[0..wind_index-1]
      data = {temp: temp, humidity: hum, dew: '', pressure: '', wind_dir: wind_dir, wind_speed: wind_speed.to_f}
      re << data
      count = count + 1
    end
    return re
  end
end

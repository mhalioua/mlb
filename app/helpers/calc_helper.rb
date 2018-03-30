module CalcHelper
  include GetHtml

  def stadium_weather(home_team)

    url = get_url(home_team)
    doc = download_document(url)
    puts url

    return [] unless doc
    header = doc.css("#hourly-forecast-table tr").first
    return [] unless header
    headers = {
      'Time' => 0,
      'Temp.' => 0,
      'Dew Point' => 0,
      'Humidity' => 0,
      'Pressure' => 0,
      'Wind' => 0
    }

    header.children.each_with_index do |header_element, index|
      key = header_element.text.squish
      headers[key] = index if key == 'Time'
      headers[key] = index if key == 'Temp.'
      headers[key] = index if key == 'Dew Point'
      headers[key] = index if key == 'Humidity'
      headers[key] = index if key == 'Pressure'
      headers[key] = index if key == 'Wind'
    end

    re = []
    hourlyweathers = doc.css("#hourly-forecast-table tbody tr")
    hourlyweathers.each_with_index do |weather, index|
      time = hourlyweathers[start_index].children[headers['Time']].text.squish
      temp = hourlyweathers[start_index].children[headers['Temp.']].text.squish
      dp = hourlyweathers[start_index].children[headers['Dew Point']].text.squish
      hum = hourlyweathers[start_index].children[headers['Humidity']].text.squish
      pressure = hourlyweathers[start_index].children[headers['Pressure']].text.squish
      wind = hourlyweathers[start_index].children[headers['Wind']].text.squish
      wind_index = wind.rindex(' ')
      wind_dir = wind[wind_index+1..-1]
      wind_speed = wind[0..wind_index-1]
      data = {time: time, temp: temp, humidity: hum, dew: dp, pressure: pressure, wind_dir: wind_dir, wind_speed: wind_speed}
      re.push(data)
    end
    return re
  end

  def get_url(home_team)
    game_day = Date.today
    url = @@urls[home_team-1]
    find = "year-month-day"
    replace = "#{game_day.year}-#{game_day.month}-#{game_day.day}"
    url.gsub(/#{find}/, replace)
  end

  @@urls = [
    "https://www.wunderground.com/hourly/us/ca/anaheim/92806/date/year-month-day?cm_ven=localwx_hour",
    "https://www.wunderground.com/hourly/us/tx/houston/77002/date/year-month-day?cm_ven=localwx_hour",
    "https://www.wunderground.com/hourly/us/ca/oakland/94621/date/year-month-day?cm_ven=localwx_hour",
    "https://www.wunderground.com/hourly/ca/toronto/43.65000153,-79.38330078/date/year-month-day?cm_ven=localwx_hour",
    "https://www.wunderground.com/hourly/us/ga/atlanta/30315/date/year-month-day?cm_ven=localwx_hour",
    "https://www.wunderground.com/hourly/us/wi/milwaukee/53214/date/year-month-day?cm_ven=localwx_hour",
    "https://www.wunderground.com/hourly/us/mo/saint-louis/63102/date/year-month-day?cm_ven=localwx_hour",
    "https://www.wunderground.com/hourly/us/il/chicago/60613/date/year-month-day?cm_ven=localwx_hour",
    "https://www.wunderground.com/hourly/us/az/phoenix/85004/date/year-month-day?cm_ven=localwx_hour",
    "https://www.wunderground.com/hourly/us/ca/los-angeles/90012/date/year-month-day?cm_ven=localwx_hour",
    "https://www.wunderground.com/hourly/us/ca/san-francisco/94107/date/year-month-day?cm_ven=localwx_hour",
    "https://www.wunderground.com/hourly/us/oh/cleveland/44115/date/year-month-day?cm_ven=localwx_hour",
    "https://www.wunderground.com/hourly/us/wa/seattle/98134/date/year-month-day?cm_ven=localwx_hour",
    "https://www.wunderground.com/hourly/us/fl/miami/33125/date/year-month-day?cm_ven=localwx_hour",
    "https://www.wunderground.com/hourly/us/ny/corona/11368/date/year-month-day?cm_ven=localwx_hour",
    "https://www.wunderground.com/hourly/us/dc/washington/20003/date/year-month-day?cm_ven=localwx_hour",
    "https://www.wunderground.com/hourly/us/md/baltimore/21201/date/year-month-day?cm_ven=localwx_hour",
    "https://www.wunderground.com/hourly/us/ca/san-diego/92101/date/year-month-day?cm_ven=localwx_hour",
    "https://www.wunderground.com/hourly/us/pa/philadelphia/19148/date/year-month-day?cm_ven=localwx_hour",
    "https://www.wunderground.com/hourly/us/pa/pittsburgh/15212/date/year-month-day?cm_ven=localwx_hour",
    "https://www.wunderground.com/hourly/us/tx/arlington/76011/date/year-month-day?cm_ven=localwx_hour",
    "https://www.wunderground.com/hourly/us/fl/saint-petersburg/33705/date/year-month-day?cm_ven=localwx_hour",
    "https://www.wunderground.com/hourly/us/ma/boston/02215/date/year-month-day?cm_ven=localwx_hour",
    "https://www.wunderground.com/hourly/us/oh/cincinnati/45202/date/year-month-day?cm_ven=localwx_hour",
    "https://www.wunderground.com/hourly/us/co/denver/80205/date/year-month-day?cm_ven=localwx_hour",
    "https://www.wunderground.com/hourly/us/mo/64129/date/year-month-day?cm_ven=localwx_hour",
    "https://www.wunderground.com/hourly/us/mi/detroit/48201/date/year-month-day?cm_ven=localwx_hour",
    "https://www.wunderground.com/hourly/us/mn/minneapolis/55403/date/year-month-day?cm_ven=localwx_hour",
    "https://www.wunderground.com/hourly/us/il/chicago/60616/date/year-month-day?cm_ven=localwx_hour",
    "https://www.wunderground.com/hourly/us/ny/bronx/10451/date/year-month-day?cm_ven=localwx_hour"
    ]
end

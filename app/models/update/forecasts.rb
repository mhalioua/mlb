module Update
  class Forecasts

    include GetHtml

    def update(game)
      game_day = game.game_day
      home_team = game.home_team
      time = DateTime.parse(game.game_date).strftime("%I:%M%p").to_time

      url = get_url(home_team, game_day)
      doc = download_document(url)
      puts url

      return unless doc
      header = doc.css("#hourly-forecast-table tr").first
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

      hourlyweathers = doc.css("#hourly-forecast-table tbody tr")
      start_index = hourlyweathers.size - 1
      return if start_index < 0 || (hourlyweathers[0].children[2].text.squish.to_time > time && GameDay.today == game_day)
      start_index = 0
      hourlyweathers.each_with_index do |weather, index|
        date = weather.children[2].text.squish.to_time
        if date > time
          break
        end
        start_index = index
      end

      (1..4).each do |index|
        temp = hourlyweathers[start_index].children[headers['Temp.']].text.squish
        dp = hourlyweathers[start_index].children[headers['Dew Point']].text.squish
        hum = hourlyweathers[start_index].children[headers['Humidity']].text.squish
        pressure = hourlyweathers[start_index].children[headers['Pressure']].text.squish
        precip = hourlyweathers[start_index].children[headers['Amount']].text.squish
        wind = hourlyweathers[start_index].children[headers['Wind']].text.squish
        feel = hourlyweathers[start_index].children[headers['Feels Like']].text.squish
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
        weather = game.weathers.create(station: "Forecast", hour: index)
        weather.update(temp: temp, dp: dp, hum: hum, pressure: pressure, wind_dir: wind_dir, wind_speed: wind_speed, precip: precip, feel: feel)

        start_index = start_index + 1 if start_index < hourlyweathers.size - 1
      end
    end

    def update_table(game)
      name = game.home_team.name
      forecast_one = game.weathers.where(station: "Forecast", hour: 1).order("updated_at DESC")
      forecast_two = game.weathers.where(station: "Forecast", hour: 2).order("updated_at DESC")
      forecast_three = game.weathers.where(station: "Forecast", hour: 3).order("updated_at DESC")
      forecast_four = game.weathers.where(station: "Forecast", hour: 4).order("updated_at DESC")
      return if forecast_one.length == 0
      forecasts = [forecast_one.first, forecast_two.first, forecast_three.first, forecast_four.first]
      row_number = 0
      block_number = 0
      date = forecast_one.first.updated_at.advance(hours: game.home_team.timezone).in_time_zone('Eastern Time (US & Canada)').strftime("%F %I:%M%p")

      Weathersource.where(game_id: game.id, date: date, table_number: 0).destroy_all
      Weathersource.where(game_id: game.id, date: date, table_number: 1).destroy_all
      forecasts.each do |weather|
        wind_min = weather.wind_speed.to_f - 5
        wind_max = weather.wind_speed.to_f + 5
        wind_min = 3 if wind_min < 3
        result = true_data(weather.temp_num - 5, weather.temp_num + 5, weather.dew_num-2, weather.dew_num+2, weather.humid_num-3, weather.humid_num+3, (weather.pressure_num-0.04).round(2), (weather.pressure_num+0.04).round(2), wind_min, wind_max, weather.wind_dir, weather.wind_dir, name)
        create_weathersource(game.id, date, 0, block_number, row_number, weather_time(weather.game.game_date, weather.hour), weather.temp, weather.dp, weather.hum, weather.pressure, weather.wind, result)
        result = true_data_prev(weather.temp_num - 5, weather.temp_num + 5, weather.dew_num-2, weather.dew_num+2, weather.humid_num-3, weather.humid_num+3, (weather.pressure_num-0.04).round(2), (weather.pressure_num+0.04).round(2), wind_min, wind_max, weather.wind_dir, weather.wind_dir, name)
        create_weathersource(game.id, date, 1, block_number, row_number, weather_time(weather.game.game_date, weather.hour), weather.temp, weather.dp, weather.hum, weather.pressure, weather.wind, result)
        row_number = row_number + 1
      end
      block_number = block_number + 1

      forecasts.each_with_index do |weather, index|
        temp_min = weather.temp_num - 4
        temp_max = weather.temp_num + 4
        dew_min = weather.dew_num-2
        dew_max = weather.dew_num+2
        hum_min = weather.humid_num-3
        hum_max = weather.humid_num+3
        pressure_min = (weather.pressure_num-0.04).round(2)
        pressure_max = (weather.pressure_num+0.04).round(2)
        wind_min = weather.wind_speed.to_f - 5
        wind_max = weather.wind_speed.to_f + 5
        wind_min = 3 if wind_min < 3
        result = true_data(temp_min, temp_max, dew_min, dew_max, hum_min, hum_max, pressure_min, pressure_max, wind_min, wind_max, weather.wind_dir, weather.wind_dir, name)
        create_weathersource(game.id, date, 0, block_number, row_number, "#{index + 1} hour", "#{temp_min}-#{temp_max}", "#{dew_min.round}-#{dew_max.round} #{(dew_min+1).round}-#{(dew_max-1).round}", hum_min === hum_max ? hum_min : "#{hum_min}-#{hum_max}", "#{(pressure_min*100).round%100}-#{(pressure_max*100).round%100}", "#{wind_min}-#{wind_max} ,#{weather.wind_dir}", result)
        result = true_data_prev(temp_min, temp_max, dew_min, dew_max, hum_min, hum_max, pressure_min, pressure_max, wind_min, wind_max, weather.wind_dir, weather.wind_dir, name)
        create_weathersource(game.id, date, 1, block_number, row_number, "#{index + 1} hour", "#{temp_min}-#{temp_max}", "#{dew_min.round}-#{dew_max.round} #{(dew_min+1).round}-#{(dew_max-1).round}", hum_min === hum_max ? hum_min : "#{hum_min}-#{hum_max}", "#{(pressure_min*100).round%100}-#{(pressure_max*100).round%100}", "#{wind_min}-#{wind_max} ,#{weather.wind_dir}", result)
        row_number = row_number + 1
      end
      block_number = block_number + 1

      (1..3).each do |one_sec|
        weather_one = forecasts[one_sec - 1]
        weather_two = forecasts[one_sec]

        temp_min = weather_one.temp_num
        temp_max = weather_two.temp_num
        if temp_min > temp_max
          temp_min = weather_two.temp_num
          temp_max = weather_one.temp_num
        end
        temp_diff = ((16 + temp_min - temp_max)/2).to_i
        temp_min = temp_min - temp_diff
        temp_max = temp_max + temp_diff

        dew_min = weather_one.dew_num
        dew_max = weather_two.dew_num
        if dew_min > dew_max
          dew_min = weather_two.dew_num
          dew_max = weather_one.dew_num
        end
        dew_diff = ((7 + dew_min - dew_max)/2).to_i
        dew_min = dew_min - dew_diff
        dew_max = dew_max + dew_diff

        hum_min = weather_one.humid_num
        hum_max = weather_two.humid_num
        if hum_min > hum_max
          hum_min = weather_two.humid_num
          hum_max = weather_one.humid_num
        end
        if (hum_max - hum_min) < 9
          hum_diff = ((8 + hum_min - hum_max)/2).to_i
          hum_min = hum_min - hum_diff
          hum_max = hum_max + hum_diff
        end

        pressure_min = (weather_one.pressure_num * 100).round
        pressure_max = (weather_two.pressure_num * 100).round
        if pressure_min > pressure_max
          pressure_min = (weather_two.pressure_num * 100).round
          pressure_max = (weather_one.pressure_num * 100).round
        end
        pressure_diff = ((8 + pressure_min - pressure_max)/2).to_i
        pressure_min = ((pressure_min - pressure_diff)/100.0).round(2)
        pressure_max = ((pressure_max + pressure_diff)/100.0).round(2)

        wind_min = weather_one.wind_speed.to_f
        wind_max = weather_two.wind_speed.to_f
        if wind_min > wind_max
          wind_min = weather_two.wind_speed.to_f
          wind_max = weather_one.wind_speed.to_f
        end
        wind_speed_diff = ((5 + wind_min - wind_max)/2).to_i
        wind_min = wind_min - wind_speed_diff
        wind_max = wind_max + wind_speed_diff
        wind_min = 3 if wind_min < 3
        result = true_data(temp_min, temp_max, dew_min, dew_max, hum_min, hum_max, pressure_min, pressure_max, wind_min, wind_max, weather_one.wind_dir, weather_two.wind_dir, name)
        create_weathersource(game.id, date, 0, block_number, row_number, "With wind", "#{temp_min}-#{temp_max}", "#{dew_min.round}-#{dew_max.round} #{(dew_min+1).round}-#{(dew_max-1).round}", hum_min === hum_max ? hum_min : "#{hum_min}-#{hum_max}", "#{(pressure_min*100).round%100}-#{(pressure_max*100).round%100}", "#{wind_min}-#{wind_max} ," + (weather_one.wind_dir == weather_two.wind_dir ? weather_one.wind_dir : "#{weather_one.wind_dir}, #{weather_two.wind_dir}"), result)
        result = true_data_prev(temp_min, temp_max, dew_min, dew_max, hum_min, hum_max, pressure_min, pressure_max, wind_min, wind_max, weather_one.wind_dir, weather_two.wind_dir, name)
        create_weathersource(game.id, date, 1, block_number, row_number, "With wind", "#{temp_min}-#{temp_max}", "#{dew_min.round}-#{dew_max.round} #{(dew_min+1).round}-#{(dew_max-1).round}", hum_min === hum_max ? hum_min : "#{hum_min}-#{hum_max}", "#{(pressure_min*100).round%100}-#{(pressure_max*100).round%100}", "#{wind_min}-#{wind_max} ," + (weather_one.wind_dir == weather_two.wind_dir ? weather_one.wind_dir : "#{weather_one.wind_dir}, #{weather_two.wind_dir}"), result)
        row_number = row_number + 1
      end
      block_number = block_number + 1

      (1..3).each do |one_sec|
        slogan = "#{one_sec}-#{one_sec + 1} hour"
        weather_one = forecasts[one_sec - 1]
        weather_two = forecasts[one_sec]

        temp_min = weather_one.temp_num
        temp_max = weather_two.temp_num
        if temp_min > temp_max
          temp_min = weather_two.temp_num
          temp_max = weather_one.temp_num
        end
        temp_diff = ((9 + temp_min - temp_max)/2).to_i
        temp_min = temp_min - temp_diff
        temp_max = temp_max + temp_diff

        dew_min = weather_one.dew_num
        dew_max = weather_two.dew_num
        if dew_min > dew_max
          dew_min = weather_two.dew_num
          dew_max = weather_one.dew_num
        end
        dew_diff = ((5 + dew_min - dew_max)/2).to_i
        dew_min = dew_min - dew_diff
        dew_max = dew_max + dew_diff

        pressure_min = (weather_one.pressure_num * 100).round
        pressure_max = (weather_two.pressure_num * 100).round
        if pressure_min > pressure_max
          pressure_min = (weather_two.pressure_num * 100).round
          pressure_max = (weather_one.pressure_num * 100).round
        end
        pressure_diff = ((8 + pressure_min - pressure_max)/2).to_i
        pressure_min = ((pressure_min - pressure_diff)/100.0).round(2)
        pressure_max = ((pressure_max + pressure_diff)/100.0).round(2)

        wind_min = weather_one.wind_speed.to_f
        wind_max = weather_two.wind_speed.to_f
        if wind_min > wind_max
          wind_min = weather_two.wind_speed.to_f
          wind_max = weather_one.wind_speed.to_f
        end
        wind_speed_diff = ((5 + wind_min - wind_max)/2).to_i
        wind_min = wind_min - wind_speed_diff
        wind_max = wind_max + wind_speed_diff
        wind_min = 3 if wind_min < 3
      
        if one_sec == 1
          if forecasts[0].humid_num > forecasts[3].humid_num
            hum_min = forecasts[0].humid_num + 4
            hum_max = forecasts[0].humid_num + 9
          else
            hum_min = forecasts[0].humid_num - 9
            hum_max = forecasts[0].humid_num - 4
          end
          result = true_data(temp_min, temp_max, dew_min, dew_max, hum_min, hum_max, pressure_min, pressure_max, wind_min, wind_max, weather_one.wind_dir, weather_two.wind_dir, name)
          create_weathersource(game.id, date, 0, block_number, row_number, "Minus 5", "#{temp_min}-#{temp_max}", "#{dew_min.round}-#{dew_max.round} #{(dew_min+1).round}-#{(dew_max-1).round}", hum_min === hum_max ? hum_min : "#{hum_min}-#{hum_max}", "#{(pressure_min*100).round%100}-#{(pressure_max*100).round%100}", "#{wind_min}-#{wind_max} ," + (weather_one.wind_dir == weather_two.wind_dir ? weather_one.wind_dir : "#{weather_one.wind_dir}, #{weather_two.wind_dir}"), result)
          result = true_data_prev(temp_min, temp_max, dew_min, dew_max, hum_min, hum_max, pressure_min, pressure_max, wind_min, wind_max, weather_one.wind_dir, weather_two.wind_dir, name)
          create_weathersource(game.id, date, 1, block_number, row_number, "Minus 5", "#{temp_min}-#{temp_max}", "#{dew_min.round}-#{dew_max.round} #{(dew_min+1).round}-#{(dew_max-1).round}", hum_min === hum_max ? hum_min : "#{hum_min}-#{hum_max}", "#{(pressure_min*100).round%100}-#{(pressure_max*100).round%100}", "#{wind_min}-#{wind_max} ," + (weather_one.wind_dir == weather_two.wind_dir ? weather_one.wind_dir : "#{weather_one.wind_dir}, #{weather_two.wind_dir}"), result)
          row_number = row_number + 1
        end

        if one_sec == 3
          if forecasts[0].humid_num < forecasts[3].humid_num
            hum_min = forecasts[3].humid_num + 4
            hum_max = forecasts[3].humid_num + 9
          else
            hum_min = forecasts[3].humid_num - 9
            hum_max = forecasts[3].humid_num - 4
          end
          result = true_data(temp_min, temp_max, dew_min, dew_max, hum_min, hum_max, pressure_min, pressure_max, wind_min, wind_max, weather_one.wind_dir, weather_two.wind_dir, name)
          create_weathersource(game.id, date, 0, block_number, row_number, "Plus 5", "#{temp_min}-#{temp_max}", "#{dew_min.round}-#{dew_max.round} #{(dew_min+1).round}-#{(dew_max-1).round}", hum_min === hum_max ? hum_min : "#{hum_min}-#{hum_max}", "#{(pressure_min*100).round%100}-#{(pressure_max*100).round%100}", "#{wind_min}-#{wind_max} ," + (weather_one.wind_dir == weather_two.wind_dir ? weather_one.wind_dir : "#{weather_one.wind_dir}, #{weather_two.wind_dir}"), result)
          result = true_data_prev(temp_min, temp_max, dew_min, dew_max, hum_min, hum_max, pressure_min, pressure_max, wind_min, wind_max, weather_one.wind_dir, weather_two.wind_dir, name)
          create_weathersource(game.id, date, 1, block_number, row_number, "Plus 5", "#{temp_min}-#{temp_max}", "#{dew_min.round}-#{dew_max.round} #{(dew_min+1).round}-#{(dew_max-1).round}", hum_min === hum_max ? hum_min : "#{hum_min}-#{hum_max}", "#{(pressure_min*100).round%100}-#{(pressure_max*100).round%100}", "#{wind_min}-#{wind_max} ," + (weather_one.wind_dir == weather_two.wind_dir ? weather_one.wind_dir : "#{weather_one.wind_dir}, #{weather_two.wind_dir}"), result)
          row_number = row_number + 1
        end
        
        hum_min = weather_one.humid_num
        hum_max = weather_two.humid_num
        if hum_min > hum_max
          hum_min = weather_two.humid_num
          hum_max = weather_one.humid_num
        end
        result = true_data(temp_min, temp_max, dew_min, dew_max, hum_min, hum_max, pressure_min, pressure_max, wind_min, wind_max, weather_one.wind_dir, weather_two.wind_dir, name)
        create_weathersource(game.id, date, 0, block_number, row_number, slogan, "#{temp_min}-#{temp_max}", "#{dew_min.round}-#{dew_max.round} #{(dew_min+1).round}-#{(dew_max-1).round}", hum_min === hum_max ? hum_min : "#{hum_min}-#{hum_max}", "#{(pressure_min*100).round%100}-#{(pressure_max*100).round%100}", "#{wind_min}-#{wind_max} ," + (weather_one.wind_dir == weather_two.wind_dir ? weather_one.wind_dir : "#{weather_one.wind_dir}, #{weather_two.wind_dir}"), result)
        result = true_data_prev(temp_min, temp_max, dew_min, dew_max, hum_min, hum_max, pressure_min, pressure_max, wind_min, wind_max, weather_one.wind_dir, weather_two.wind_dir, name)
        create_weathersource(game.id, date, 1, block_number, row_number, slogan, "#{temp_min}-#{temp_max}", "#{dew_min.round}-#{dew_max.round} #{(dew_min+1).round}-#{(dew_max-1).round}", hum_min === hum_max ? hum_min : "#{hum_min}-#{hum_max}", "#{(pressure_min*100).round%100}-#{(pressure_max*100).round%100}", "#{wind_min}-#{wind_max} ," + (weather_one.wind_dir == weather_two.wind_dir ? weather_one.wind_dir : "#{weather_one.wind_dir}, #{weather_two.wind_dir}"), result)
        row_number = row_number + 1
        block_number = block_number + 1

       (hum_min..hum_max).each do |hum_each|
          result = true_data(temp_min, temp_max, dew_min, dew_max, hum_each, hum_each, pressure_min, pressure_max, wind_min, wind_max, weather_one.wind_dir, weather_two.wind_dir, name)
          create_weathersource(game.id, date, 0, block_number, row_number, slogan, "#{temp_min}-#{temp_max}", "#{dew_min.round}-#{dew_max.round} #{(dew_min+1).round}-#{(dew_max-1).round}", hum_each, "#{(pressure_min*100).round%100}-#{(pressure_max*100).round%100}", "#{wind_min}-#{wind_max} ," + (weather_one.wind_dir == weather_two.wind_dir ? weather_one.wind_dir : "#{weather_one.wind_dir}, #{weather_two.wind_dir}"), result)
          result = true_data_prev(temp_min, temp_max, dew_min, dew_max, hum_each, hum_each, pressure_min, pressure_max, wind_min, wind_max, weather_one.wind_dir, weather_two.wind_dir, name)
          create_weathersource(game.id, date, 1, block_number, row_number, slogan, "#{temp_min}-#{temp_max}", "#{dew_min.round}-#{dew_max.round} #{(dew_min+1).round}-#{(dew_max-1).round}", hum_each, "#{(pressure_min*100).round%100}-#{(pressure_max*100).round%100}", "#{wind_min}-#{wind_max} ," + (weather_one.wind_dir == weather_two.wind_dir ? weather_one.wind_dir : "#{weather_one.wind_dir}, #{weather_two.wind_dir}"), result)
          row_number = row_number + 1
        end
        block_number = block_number + 1
      end
    end

    def update_check(game)
      game_day = game.game_day
      home_team = game.home_team
      time = DateTime.parse(game.game_date).strftime("%I:%M%p").to_time

      url = get_url(home_team, game_day)
      doc = download_document(url)
      puts "home_team.name #{home_team.name}"
      puts "game.game_date #{game.game_date}"
      puts "url #{url}"

      return unless doc
      header = doc.css("#hourly-forecast-table tr").first
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

      hourlyweathers = doc.css("#hourly-forecast-table tbody tr")
      start_index = hourlyweathers.size - 1
      puts "game_day #{game_day.inspect}"
      puts "GameDay.today #{GameDay.today.inspect}"
      puts "hourlyweathers[0].children[2].text.squish.to_time #{hourlyweathers[0].children[2].text.squish.to_time}"
      puts "time #{time}"
      return if start_index < 0 || (hourlyweathers[0].children[2].text.squish.to_time > time && GameDay.today == game_day)
      start_index = 0
      hourlyweathers.each_with_index do |weather, index|
        date = weather.children[2].text.squish.to_time
        if date > time
          break
        end
        start_index = index
      end

      (1..4).each do |index|
        puts hourlyweathers[start_index].children[2].text.squish
        temp = hourlyweathers[start_index].children[headers['Temp.']].text.squish
        dp = hourlyweathers[start_index].children[headers['Dew Point']].text.squish
        hum = hourlyweathers[start_index].children[headers['Humidity']].text.squish
        pressure = hourlyweathers[start_index].children[headers['Pressure']].text.squish
        precip = hourlyweathers[start_index].children[headers['Amount']].text.squish
        wind = hourlyweathers[start_index].children[headers['Wind']].text.squish
        feel = hourlyweathers[start_index].children[headers['Feels Like']].text.squish
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

        start_index = start_index + 1 if start_index < hourlyweathers.size - 1
      end
    end

    private

      def get_url(home_team, game_day)
        url = @@urls[home_team.id-1]
        find = "/date/year-month-day"
        replace = "/date/#{game_day.year}-#{game_day.month}-#{game_day.day}"
        replace = "" if game_day == GameDay.today
        url.gsub(/#{find}/, replace)
      end

      def create_weathersource(game_id, date, table_number, block_number, row_number, caption, temp, dp, hum, pressure, wind, result)
        Weathersource.create(
          game_id: game_id,
          date: date,
          offset: 0,
          table_number: table_number,
          block_number: block_number,
          row_number: row_number,
          caption: caption,
          temp: temp,
          dew: dp,
          humid: hum,
          pressure: pressure,
          wind: wind,
          all_stadium_total_average_one: result[:total_avg_1],
          all_stadium_total_average_two: result[:total_avg_2],
          all_stadium_total_hits_average: result[:total_hits_avg],
          all_stadium_home_runs_average: result[:home_runs_avg],
          all_stadium_total_count: result[:total_count],
          all_stadium_min_total_average: result[:lower_one],
          all_stadium_min_total_count: result[:lower_one_count],
          all_stadium_total_lines_average: result[:total_lines_avg],
          only_total_average_one: result[:home_total_runs1_avg],
          only_total_average_two: result[:home_total_runs2_avg],
          only_total_hits_average: result[:total_hits_park_avg],
          only_home_runs_average: result[:total_hr_park],
          only_total_count: result[:home_count],
          only_min_total_average: result[:home_one],
          only_min_total_count: result[:home_one_count],
          only_total_lines_average: result[:total_lines_park_avg],
          only_wind_total_average_one: result[:home_total_runs1_avg_wind],
          only_wind_total_average_two: result[:home_total_runs2_avg_wind],
          only_wind_total_hits_average: result[:total_hits_park_avg_wind],
          only_wind_home_runs_average: result[:total_hr_park_wind],
          only_wind_total_count: result[:home_count_wind],
          only_wind_min_total_average: result[:home_one_wind],
          only_wind_min_total_count: result[:home_one_count_wind],
          only_wind_total_lines_average: result[:total_lines_park_avg_wind],
          except_total_average_one: result[:home_total_runs1_avg_dup],
          except_total_average_two: result[:home_total_runs2_avg_dup],
          except_total_hits_average: result[:total_hits_park_avg_dup],
          except_home_runs_average: result[:total_hr_park_dup],
          except_total_count: result[:home_count_dup],
          except_min_total_average: result[:home_one_dup],
          except_min_total_count: result[:home_one_count_dup],
          except_total_lines_average: result[:total_lines_park_avg_dup],
          t_HITS_avg: result[:t_HITS_avg],
          t_HRS_avg: result[:t_HRS_avg],
          first_count: result[:first_count],
          second_count: result[:second_count],
          third_count: result[:third_count],
          city1: result[:city1],
          city2: result[:city2],
          city3: result[:city3],
          cityCount1: result[:cityCount1],
          cityCount2: result[:cityCount2],
          cityCount3: result[:cityCount3]
        )
      end

      @@urls = [
        "https://www.wunderground.com/hourly/us/ca/anaheim/92806/date/year-month-day?cm_ven=localwx_hour",
        "https://www.wunderground.com/hourly/us/tx/houston/77002/date/year-month-day?cm_ven=localwx_hour",
        "https://www.wunderground.com/hourly/us/ca/oakland/94621/date/year-month-day?cm_ven=localwx_hour",
        "https://www.wunderground.com/hourly/ca/toronto/date/year-month-day?cm_ven=localwx_hour",
        "https://www.wunderground.com/hourly/us/ga/atlanta/30339/date/year-month-day?cm_ven=localwx_hour",
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
end
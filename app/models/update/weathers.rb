module Update
  class Weathers

    include GetHtml

    def update(game)
      actual_weathers = game.weathers.where(station: "Actual")
      return if actual_weathers.length == 4
      game_day = game.game_day
      home_team = game.home_team
      time = DateTime.parse(game.game_date) + 4.hours - home_team.timezone.hours - 31.minutes
      return if time > DateTime.now

      url = get_url(home_team, game_day)
      puts url

      open(url) do |f|
        json_string = f.read
        parsed_json = JSON.parse(json_string)
        forecast_data = parsed_json['observations']
        count = 1
        forecast_data.each_with_index do |hour_data, index|
          break if count == 5
          hour_date_time = DateTime.strptime(hour_data['valid_time_gmt'].to_s,'%s')
          next if hour_date_time < time
          break if index === 0
          temp = hour_data['temp']
          hum = hour_data['rh']
          dp = hour_data['dewPt']
          pressure = hour_data['pressure']
          wind_dir = hour_data['wdir_cardinal']
          wind_dir = '' if wind_dir == nil
          if wind_dir == "W"
            wind_dir = "West"
          elsif wind_dir == "S"
            wind_dir = "South"
          elsif wind_dir == "N"
            wind_dir = "North"
          elsif wind_dir == "E"
            wind_dir = "East"
          end
          wind_speed = hour_data['wspd'].to_f
          wind_speed = 0 if wind_speed < 0
          weather = game.weathers.find_or_create_by(station: "Actual", hour: count)
          weather.update(temp: temp, dp: dp, hum: hum, pressure: pressure, wind_dir: wind_dir, wind_speed: wind_speed)
          count = count + 1
        end
      end
    end

    def update_table(game)
      name = game.home_team.name
      weathers = game.weathers.where(station: "Actual").order(:hour)
      row_number = 0
      block_number = 0
      return if weathers.length < 4
      date = weathers.first.updated_at.advance(hours: game.home_team.timezone).in_time_zone('Eastern Time (US & Canada)').strftime("%F %I:%M%p")

      Weathersource.where(game_id: game.id, table_number: 2).destroy_all
      weathers.each do |weather|
        wind_min = (weather.wind_speed.to_f - 5).round(1)
        wind_max = (weather.wind_speed.to_f + 5).round(1)
        wind_min = 3 if wind_min < 3
        result = true_data((weather.temp_num - 5).round(1), (weather.temp_num + 5).round(1), (weather.dew_num-2).round(1), (weather.dew_num+2).round(1), weather.humid_num-3, weather.humid_num+3, (weather.pressure_num-0.04).round(2), (weather.pressure_num+0.04).round(2), wind_min, wind_max, weather.wind_dir, weather.wind_dir, name)
        create_weathersource(game.id, date, 2, block_number, row_number, weather_time(weather.game.game_date, weather.hour), weather.temp, weather.dp, weather.hum, weather.pressure, weather.wind, result)
        row_number = row_number + 1
      end
      block_number = block_number + 1

      weathers.each_with_index do |weather, index|
        temp_min = (weather.temp_num - 4).round(1)
        temp_max = (weather.temp_num + 4).round(1)
        dew_min = (weather.dew_num-2).round(1)
        dew_max = (weather.dew_num+2).round(1)
        hum_min = weather.humid_num-3
        hum_max = weather.humid_num+3
        pressure_min = (weather.pressure_num-0.04).round(2)
        pressure_max = (weather.pressure_num+0.04).round(2)
        wind_min = (weather.wind_speed.to_f - 5).round(1)
        wind_max = (weather.wind_speed.to_f + 5).round(1)
        wind_min = 3 if wind_min < 3
        result = true_data(temp_min, temp_max, dew_min, dew_max, hum_min, hum_max, pressure_min, pressure_max, wind_min, wind_max, weather.wind_dir, weather.wind_dir, name)
        create_weathersource(game.id, date, 2, block_number, row_number, "#{index + 1} hour", "#{temp_min}-#{temp_max}", "#{dew_min.round}-#{dew_max.round} #{(dew_min+1).round}-#{(dew_max-1).round}", hum_min === hum_max ? hum_min : "#{hum_min}-#{hum_max}", "#{(pressure_min*100).round%100}-#{(pressure_max*100).round%100}", "#{wind_min}-#{wind_max} ,#{weather.wind_dir}", result)
        row_number = row_number + 1
      end
      block_number = block_number + 1

      (1..3).each do |one_sec|
        weather_one = weathers[one_sec - 1]
        weather_two = weathers[one_sec]

        temp_min = weather_one.temp_num
        temp_max = weather_two.temp_num
        if temp_min > temp_max
          temp_min = weather_two.temp_num
          temp_max = weather_one.temp_num
        end
        temp_diff = ((16 + temp_min - temp_max)/2).to_i
        temp_min = (temp_min - temp_diff).round(1)
        temp_max = (temp_max + temp_diff).round(1)

        dew_min = weather_one.dew_num
        dew_max = weather_two.dew_num
        if dew_min > dew_max
          dew_min = weather_two.dew_num
          dew_max = weather_one.dew_num
        end
        dew_diff = ((7 + dew_min - dew_max)/2).to_i
        dew_min = (dew_min - dew_diff).round(1)
        dew_max = (dew_max + dew_diff).round(1)

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
        wind_speed_diff = ((11 + wind_min - wind_max)/2).to_i
        wind_min = (wind_min - wind_speed_diff).round(1)
        wind_max = (wind_max + wind_speed_diff).round(1)
        wind_min = 3 if wind_min < 3
        result = true_data(temp_min, temp_max, dew_min, dew_max, hum_min, hum_max, pressure_min, pressure_max, wind_min, wind_max, weather_one.wind_dir, weather_two.wind_dir, name)
        create_weathersource(game.id, date, 2, block_number, row_number, "With wind", "#{temp_min}-#{temp_max}", "#{dew_min.round}-#{dew_max.round} #{(dew_min+1).round}-#{(dew_max-1).round}", hum_min === hum_max ? hum_min : "#{hum_min}-#{hum_max}", "#{(pressure_min*100).round%100}-#{(pressure_max*100).round%100}", "#{wind_min}-#{wind_max} ," + (weather_one.wind_dir == weather_two.wind_dir ? weather_one.wind_dir : "#{weather_one.wind_dir}, #{weather_two.wind_dir}"), result)
        row_number = row_number + 1
      end
      block_number = block_number + 1

      (1..3).each do |one_sec|
        slogan = "#{one_sec}-#{one_sec + 1} hour"
        weather_one = weathers[one_sec - 1]
        weather_two = weathers[one_sec]

        temp_min = weather_one.temp_num
        temp_max = weather_two.temp_num
        if temp_min > temp_max
          temp_min = weather_two.temp_num
          temp_max = weather_one.temp_num
        end
        temp_diff = ((9 + temp_min - temp_max)/2).to_i
        temp_min = (temp_min - temp_diff).round(1)
        temp_max = (temp_max + temp_diff).round(1)

        dew_min = weather_one.dew_num
        dew_max = weather_two.dew_num
        if dew_min > dew_max
          dew_min = weather_two.dew_num
          dew_max = weather_one.dew_num
        end
        dew_diff = ((5 + dew_min - dew_max)/2).to_i
        dew_min = (dew_min - dew_diff).round(1)
        dew_max = (dew_max + dew_diff).round(1)

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
        wind_speed_diff = ((11 + wind_min - wind_max)/2).to_i
        wind_min = (wind_min - wind_speed_diff).round(1)
        wind_max = (wind_max + wind_speed_diff).round(1)
        wind_min = 3 if wind_min < 3
      
        if one_sec == 1
          if weathers[0].humid_num > weathers[3].humid_num
            hum_min = weathers[0].humid_num + 4
            hum_max = weathers[0].humid_num + 9
          else
            hum_min = weathers[0].humid_num - 9
            hum_max = weathers[0].humid_num - 4
          end
          result = true_data(temp_min, temp_max, dew_min, dew_max, hum_min, hum_max, pressure_min, pressure_max, wind_min, wind_max, weather_one.wind_dir, weather_two.wind_dir, name)
          create_weathersource(game.id, date, 2, block_number, row_number, "Minus 5", "#{temp_min}-#{temp_max}", "#{dew_min.round}-#{dew_max.round} #{(dew_min+1).round}-#{(dew_max-1).round}", hum_min === hum_max ? hum_min : "#{hum_min}-#{hum_max}", "#{(pressure_min*100).round%100}-#{(pressure_max*100).round%100}", "#{wind_min}-#{wind_max} ," + (weather_one.wind_dir == weather_two.wind_dir ? weather_one.wind_dir : "#{weather_one.wind_dir}, #{weather_two.wind_dir}"), result)
          row_number = row_number + 1
        end

        if one_sec == 3
          if weathers[0].humid_num < weathers[3].humid_num
            hum_min = weathers[3].humid_num + 4
            hum_max = weathers[3].humid_num + 9
          else
            hum_min = weathers[3].humid_num - 9
            hum_max = weathers[3].humid_num - 4
          end
          result = true_data(temp_min, temp_max, dew_min, dew_max, hum_min, hum_max, pressure_min, pressure_max, wind_min, wind_max, weather_one.wind_dir, weather_two.wind_dir, name)
          create_weathersource(game.id, date, 2, block_number, row_number, "Plus 5", "#{temp_min}-#{temp_max}", "#{dew_min.round}-#{dew_max.round} #{(dew_min+1).round}-#{(dew_max-1).round}", hum_min === hum_max ? hum_min : "#{hum_min}-#{hum_max}", "#{(pressure_min*100).round%100}-#{(pressure_max*100).round%100}", "#{wind_min}-#{wind_max} ," + (weather_one.wind_dir == weather_two.wind_dir ? weather_one.wind_dir : "#{weather_one.wind_dir}, #{weather_two.wind_dir}"), result)
          row_number = row_number + 1
        end
        
        hum_min = weather_one.humid_num
        hum_max = weather_two.humid_num
        if hum_min > hum_max
          hum_min = weather_two.humid_num
          hum_max = weather_one.humid_num
        end
        result = true_data(temp_min, temp_max, dew_min, dew_max, hum_min, hum_max, pressure_min, pressure_max, wind_min, wind_max, weather_one.wind_dir, weather_two.wind_dir, name)
        create_weathersource(game.id, date, 2, block_number, row_number, slogan, "#{temp_min}-#{temp_max}", "#{dew_min.round}-#{dew_max.round} #{(dew_min+1).round}-#{(dew_max-1).round}", hum_min === hum_max ? hum_min : "#{hum_min}-#{hum_max}", "#{(pressure_min*100).round%100}-#{(pressure_max*100).round%100}", "#{wind_min}-#{wind_max} ," + (weather_one.wind_dir == weather_two.wind_dir ? weather_one.wind_dir : "#{weather_one.wind_dir}, #{weather_two.wind_dir}"), result)
        row_number = row_number + 1
        block_number = block_number + 1

       (hum_min..hum_max).each do |hum_each|
          result = true_data(temp_min, temp_max, dew_min, dew_max, hum_each, hum_each, pressure_min, pressure_max, wind_min, wind_max, weather_one.wind_dir, weather_two.wind_dir, name)
          create_weathersource(game.id, date, 2, block_number, row_number, slogan, "#{temp_min}-#{temp_max}", "#{dew_min.round}-#{dew_max.round} #{(dew_min+1).round}-#{(dew_max-1).round}", hum_each, "#{(pressure_min*100).round%100}-#{(pressure_max*100).round%100}", "#{wind_min}-#{wind_max} ," + (weather_one.wind_dir == weather_two.wind_dir ? weather_one.wind_dir : "#{weather_one.wind_dir}, #{weather_two.wind_dir}"), result)
          row_number = row_number + 1
        end
        block_number = block_number + 1
      end
    end

    private
      def get_url(home_team, game_day)
        next_days = game_day.next_days(1)
        url = @@urls[home_team.id-1]
        find = "startDate=YYYYMMDD"
        replace = "startDate=#{game_day.year}#{game_day.month}#{game_day.day}"
        url = url.gsub(/#{find}/, replace)
        find = "endDate=YYYYMMDD"
        replace = "endDate=#{next_days.year}#{next_days.month}#{next_days.day}"
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
          except_total_lines_average: result[:total_lines_park_avg_dup]
        )
      end

      @@urls = [
        "https://api.weather.com/v1/geocode/33.68/-117.86/observations/historical.json?apiKey=6532d6454b8aa370768e63d6ba5a832e&startDate=YYYYMMDD&endDate=YYYYMMDD&units=e",
        "https://api.weather.com/v1/geocode/29.641/-95.277/observations/historical.json?apiKey=6532d6454b8aa370768e63d6ba5a832e&startDate=YYYYMMDD&endDate=YYYYMMDD&units=e",
        "https://api.weather.com/v1/geocode/37.71/-122.21/observations/historical.json?apiKey=6532d6454b8aa370768e63d6ba5a832e&startDate=YYYYMMDD&endDate=YYYYMMDD&units=e",
        # "https://api.weather.com/v1/geocode/43.636/-79.396/observations/historical.json?apiKey=6532d6454b8aa370768e63d6ba5a832e&startDate=YYYYMMDD&endDate=YYYYMMDD&units=e",
        "https://api.weather.com/v1/geocode/42.91/-78.76/observations/historical.json?apiKey=6532d6454b8aa370768e63d6ba5a832e&startDate=YYYYMMDD&endDate=YYYYMMDD&units=e",
        "https://api.weather.com/v1/geocode/33.64/-84.43/observations/historical.json?apiKey=6532d6454b8aa370768e63d6ba5a832e&startDate=YYYYMMDD&endDate=YYYYMMDD&units=e",
        "https://api.weather.com/v1/geocode/42.946/-87.896/observations/historical.json?apiKey=6532d6454b8aa370768e63d6ba5a832e&startDate=YYYYMMDD&endDate=YYYYMMDD&units=e",
        "https://api.weather.com/v1/geocode/38.74/-90.37/observations/historical.json?apiKey=6532d6454b8aa370768e63d6ba5a832e&startDate=YYYYMMDD&endDate=YYYYMMDD&units=e",
        "https://api.weather.com/v1/geocode/41.79/-87.74/observations/historical.json?apiKey=6532d6454b8aa370768e63d6ba5a832e&startDate=YYYYMMDD&endDate=YYYYMMDD&units=e",
        "https://api.weather.com/v1/geocode/33.444/-112.049/observations/historical.json?apiKey=6532d6454b8aa370768e63d6ba5a832e&startDate=YYYYMMDD&endDate=YYYYMMDD&units=e",
        "https://api.weather.com/v1/geocode/33.96/-118.401/observations/historical.json?apiKey=6532d6454b8aa370768e63d6ba5a832e&startDate=YYYYMMDD&endDate=YYYYMMDD&units=e",
        "https://api.weather.com/v1/geocode/37.71/-122.21/observations/historical.json?apiKey=6532d6454b8aa370768e63d6ba5a832e&startDate=YYYYMMDD&endDate=YYYYMMDD&units=e",
        "https://api.weather.com/v1/geocode/41.42/-81.85/observations/historical.json?apiKey=6532d6454b8aa370768e63d6ba5a832e&startDate=YYYYMMDD&endDate=YYYYMMDD&units=e",
        "https://api.weather.com/v1/geocode/47.44/-122.3/observations/historical.json?apiKey=6532d6454b8aa370768e63d6ba5a832e&startDate=YYYYMMDD&endDate=YYYYMMDD&units=e",
        "https://api.weather.com/v1/geocode/25.822/-80.289/observations/historical.json?apiKey=6532d6454b8aa370768e63d6ba5a832e&startDate=YYYYMMDD&endDate=YYYYMMDD&units=e",
        "https://api.weather.com/v1/geocode/40.77/-73.86/observations/historical.json?apiKey=6532d6454b8aa370768e63d6ba5a832e&startDate=YYYYMMDD&endDate=YYYYMMDD&units=e",
        "https://api.weather.com/v1/geocode/38.85/-77.04/observations/historical.json?apiKey=6532d6454b8aa370768e63d6ba5a832e&startDate=YYYYMMDD&endDate=YYYYMMDD&units=e",
        "https://api.weather.com/v1/geocode/39.18/-76.67/observations/historical.json?apiKey=6532d6454b8aa370768e63d6ba5a832e&startDate=YYYYMMDD&endDate=YYYYMMDD&units=e",
        "https://api.weather.com/v1/geocode/32.733/-117.199/observations/historical.json?apiKey=6532d6454b8aa370768e63d6ba5a832e&startDate=YYYYMMDD&endDate=YYYYMMDD&units=e",
        "https://api.weather.com/v1/geocode/39.87/-75.24/observations/historical.json?apiKey=6532d6454b8aa370768e63d6ba5a832e&startDate=YYYYMMDD&endDate=YYYYMMDD&units=e",
        "https://api.weather.com/v1/geocode/40.52/-80.21/observations/historical.json?apiKey=6532d6454b8aa370768e63d6ba5a832e&startDate=YYYYMMDD&endDate=YYYYMMDD&units=e",
        "https://api.weather.com/v1/geocode/32.9/-97.04/observations/historical.json?apiKey=6532d6454b8aa370768e63d6ba5a832e&startDate=YYYYMMDD&endDate=YYYYMMDD&units=e",
        "https://api.weather.com/v1/geocode/27.914/-82.705/observations/historical.json?apiKey=6532d6454b8aa370768e63d6ba5a832e&startDate=YYYYMMDD&endDate=YYYYMMDD&units=e",
        "https://api.weather.com/v1/geocode/42.375/-71.039/observations/historical.json?apiKey=6532d6454b8aa370768e63d6ba5a832e&startDate=YYYYMMDD&endDate=YYYYMMDD&units=e",
        "https://api.weather.com/v1/geocode/39/-84.65/observations/historical.json?apiKey=6532d6454b8aa370768e63d6ba5a832e&startDate=YYYYMMDD&endDate=YYYYMMDD&units=e",
        "https://api.weather.com/v1/geocode/39.86/-104.67/observations/historical.json?apiKey=6532d6454b8aa370768e63d6ba5a832e&startDate=YYYYMMDD&endDate=YYYYMMDD&units=e",
        "https://api.weather.com/v1/geocode/39.281/-94.733/observations/historical.json?apiKey=6532d6454b8aa370768e63d6ba5a832e&startDate=YYYYMMDD&endDate=YYYYMMDD&units=e",
        "https://api.weather.com/v1/geocode/42.43/-83.08/observations/historical.json?apiKey=6532d6454b8aa370768e63d6ba5a832e&startDate=YYYYMMDD&endDate=YYYYMMDD&units=e",
        "https://api.weather.com/v1/geocode/44.88/-93.21/observations/historical.json?apiKey=6532d6454b8aa370768e63d6ba5a832e&startDate=YYYYMMDD&endDate=YYYYMMDD&units=e",
        "https://api.weather.com/v1/geocode/41.79/-87.74/observations/historical.json?apiKey=6532d6454b8aa370768e63d6ba5a832e&startDate=YYYYMMDD&endDate=YYYYMMDD&units=e",
        "https://api.weather.com/v1/geocode/40.77/-73.86/observations/historical.json?apiKey=6532d6454b8aa370768e63d6ba5a832e&startDate=YYYYMMDD&endDate=YYYYMMDD&units=e"
        ]
  end
end

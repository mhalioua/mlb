module Update
  class Weathers

    include GetHtml

    def update(game)
      game_day = game.game_day
      home_team = game.home_team
      time = DateTime.parse(game.game_date) + 4.hours - home_team.timezone.hours
      return if time > DateTime.now

      url = get_url(home_team, game_day)
      puts url

      open(url) do |f|
        json_string = f.read
        parsed_json = JSON.parse(json_string)
        forecast_data = parsed_json['history']['observations']
        count = 1
        forecast_data.each do |hour_data|
          break if count == 5
          hour_date_time = DateTime.parse(hour_data['utcdate']['pretty'])
          next if hour_date_time < time
          temp = hour_data['tempi']
          hum = hour_data['hum']
          dp = hour_data['dewpti']
          pressure = hour_data['pressurei']
          wind_dir = hour_data['wdire']
          wind_speed = hour_data['wspdi'].to_f
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
      return if weathers.length == 0
      date = weathers.first.updated_at.advance(hours: game.home_team.timezone).in_time_zone('Eastern Time (US & Canada)').strftime("%F %I:%M%p")

      Weathersource.where(game_id: game.id, date: date, table_number: 2).destroy_all
      weathers.each do |weather|
        wind_min = (weather.wind_speed.to_f - 5).round(1)
        wind_max = (weather.wind_speed.to_f + 5).round(1)
        wind_min = 3 if wind_min < 3
        result = true_data(weather.temp_num - 5, weather.temp_num + 5, weather.dew_num-2, weather.dew_num+2, weather.humid_num-3, weather.humid_num+3, (weather.pressure_num-0.04).round(2), (weather.pressure_num+0.04).round(2), wind_min, wind_max, weather.wind_dir, weather.wind_dir, name)
        create_weathersource(game.id, date, 2, block_number, row_number, weather_time(weather.game.game_date, weather.hour), weather.temp, weather.dp, weather.hum, weather.pressure, weather.wind, result)
        row_number = row_number + 1
      end
      block_number = block_number + 1

      weathers.each_with_index do |weather, index|
        temp_min = (weather.temp_num - 4).round(1)
        temp_max = (weather.temp_num + 4).round(1)
        dew_min = weather.dew_num-2
        dew_max = weather.dew_num+2
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
        wind_speed_diff = ((11 + wind_min - wind_max)/2).to_i
        wind_min = (wind_min - wind_speed_diff).round(1)
        wind_max = (wind_max + wind_speed_diff).round(1)
        wind_min = 3 if wind_min < 3
      
        if one_sec == 1
          if weathers[0].humid_num > weathers[3].humid_num
            hum_min = weathers[0].humid_num + 1
            hum_max = weathers[0].humid_num + 6
          else
            hum_min = weathers[0].humid_num - 6
            hum_max = weathers[0].humid_num - 1
          end
          result = true_data(temp_min, temp_max, dew_min, dew_max, hum_min, hum_max, pressure_min, pressure_max, wind_min, wind_max, weather_one.wind_dir, weather_two.wind_dir, name)
          create_weathersource(game.id, date, 2, block_number, row_number, "Before", "#{temp_min}-#{temp_max}", "#{dew_min.round}-#{dew_max.round} #{(dew_min+1).round}-#{(dew_max-1).round}", hum_min === hum_max ? hum_min : "#{hum_min}-#{hum_max}", "#{(pressure_min*100).round%100}-#{(pressure_max*100).round%100}", "#{wind_min}-#{wind_max} ," + (weather_one.wind_dir == weather_two.wind_dir ? weather_one.wind_dir : "#{weather_one.wind_dir}, #{weather_two.wind_dir}"), result)
          row_number = row_number + 1
        end

        if one_sec == 3
          if weathers[0].humid_num < weathers[3].humid_num
            hum_min = weathers[3].humid_num + 1
            hum_max = weathers[3].humid_num + 6
          else
            hum_min = weathers[3].humid_num - 6
            hum_max = weathers[3].humid_num - 1
          end
          result = true_data(temp_min, temp_max, dew_min, dew_max, hum_min, hum_max, pressure_min, pressure_max, wind_min, wind_max, weather_one.wind_dir, weather_two.wind_dir, name)
          create_weathersource(game.id, date, 2, block_number, row_number, "After", "#{temp_min}-#{temp_max}", "#{dew_min.round}-#{dew_max.round} #{(dew_min+1).round}-#{(dew_max-1).round}", hum_min === hum_max ? hum_min : "#{hum_min}-#{hum_max}", "#{(pressure_min*100).round%100}-#{(pressure_max*100).round%100}", "#{wind_min}-#{wind_max} ," + (weather_one.wind_dir == weather_two.wind_dir ? weather_one.wind_dir : "#{weather_one.wind_dir}, #{weather_two.wind_dir}"), result)
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
        url = "http://api.wunderground.com/api/65bd4b6d02af0c3b/history_YYYYMMDD/q/#{home_team.zipcode}.json"
        url = "http://api.wunderground.com/api/65bd4b6d02af0c3b/history_YYYYMMDD/q/zmw:00000.233.71508.json" if home_team.zipcode == 'M5V 1J1'
        find = "YYYYMMDD"
        replace = "#{game_day.year}#{game_day.month}#{game_day.day}"
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
        "https://www.wunderground.com/history/daily/KFUL/date/year-month-day?req_city=Anaheim&req_state=CA&reqdb.zip=92806&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/daily/KMCJ/date/year-month-day?req_city=Houston&req_state=TX&reqdb.zip=77002&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/daily/KOAK/date/year-month-day?req_city=Oakland&req_state=CA&reqdb.zip=94621&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/daily/CXTO/date/year-month-day?req_city=Toronto&req_state=ON&req_statename=Ontario&reqdb.zip=00000&reqdb.magic=233&reqdb.wmo=71508",
        "https://www.wunderground.com/history/daily/KATL/date/year-month-day?req_city=Atlanta&req_state=GA&reqdb.zip=30315&reqdb.magic=1&reqdb.wmo=99999&MR=1",
        "https://www.wunderground.com/history/daily/KMWC/date/year-month-day?req_city=Milwaukee&req_state=WI&reqdb.zip=53214&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/daily/KCPS/date/year-month-day?req_city=Saint%20Louis&req_state=MO&reqdb.zip=63102&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/daily/KMDW/date/year-month-day?req_city=Chicago&req_state=IL&reqdb.zip=60613&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/daily/KPHX/date/year-month-day?req_city=Phoenix&req_state=AZ&reqdb.zip=85004&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/daily/KCQT/date/year-month-day?req_city=Los%20Angeles&req_state=CA&reqdb.zip=90012&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/daily/KOAK/date/year-month-day?req_city=San%20Francisco&req_state=CA&reqdb.zip=94107&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/daily/KBKL/date/year-month-day?req_city=Cleveland&req_state=OH&reqdb.zip=44115&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/daily/KBFI/date/year-month-day?req_city=Seattle&req_state=WA&reqdb.zip=98134&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/daily/KMIA/date/year-month-day?req_city=Miami&req_state=FL&reqdb.zip=33125&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/daily/KLGA/date/year-month-day?req_city=Corona&req_state=NY&reqdb.zip=11368&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/daily/KDCA/date/year-month-day?req_city=Washington&req_state=DC&reqdb.zip=20003&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/daily/KDMH/date/year-month-day?req_city=Baltimore&req_state=MD&req_statename=&reqdb.zip=21201&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/daily/KSAN/date/year-month-day?req_city=San%20Diego&req_state=CA&reqdb.zip=92101&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/daily/KPHL/date/year-month-day?req_city=Philadelphia&req_state=PA&reqdb.zip=19148&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/daily/KAGC/date/year-month-day?req_city=Pittsburgh&req_state=PA&reqdb.zip=15212&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/daily/KGPM/date/year-month-day?req_city=Arlington&req_state=TX&reqdb.zip=76011&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/daily/KSPG/date/year-month-day?req_city=Saint%20Petersburg&req_state=FL&reqdb.zip=33705&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/daily/KBOS/date/year-month-day?req_city=Boston&req_state=MA&reqdb.zip=02215&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/daily/KLUK/date/year-month-day?req_city=Cincinnati&req_state=OH&reqdb.zip=45202&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/daily/KBKF/date/year-month-day?req_city=Denver&req_state=CO&reqdb.zip=80205&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/daily/KMKC/date/year-month-day?req_city=Kansas%20City&req_state=MO&reqdb.zip=64129&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/daily/KDET/date/year-month-day?req_city=Detroit&req_state=MI&reqdb.zip=48201&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/daily/KMSP/date/year-month-day?req_city=Minneapolis&req_state=MN&reqdb.zip=55403&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/daily/KMDW/date/year-month-day?req_city=Chicago&req_state=IL&reqdb.zip=60616&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/daily/KLGA/date/year-month-day?req_city=Bronx&req_state=NY&reqdb.zip=10451&reqdb.magic=1&reqdb.wmo=99999"
        ]
  end
end

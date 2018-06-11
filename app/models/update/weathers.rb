module Update
  class Weathers

    include GetHtml

    def update(game)
      game_day = game.game_day
      home_team = game.home_team
      time = DateTime.parse(game.game_date).strftime("%I:%M%p").to_time

      url = get_url(home_team, game_day)
      doc = download_document(url)
      puts url

      return unless doc
      header = doc.css(".obs-table tr").first
      return unless header
      headers = {
        'Temp.' => 0,
        'Dew Point' => 0,
        'Humidity' => 0,
        'Pressure' => 0,
        'Wind Dir' => 0,
        'Wind Speed' => 0,
        'Precip' => 0
      }

      header.children.each_with_index do |header_element, index|
        key = header_element.text.squish
        headers[key] = index if key == 'Temp.'
        headers[key] = index if key == 'Dew Point'
        headers[key] = index if key == 'Humidity'
        headers[key] = index if key == 'Pressure'
        headers[key] = index if key == 'Wind Dir'
        headers[key] = index if key == 'Wind Speed' 
        headers[key] = index if key == 'Precip'
      end

      hourlyweathers = doc.css(".obs-table tbody tr")
      start_index = hourlyweathers.size - 1
      return if hourlyweathers[start_index].children[1].text.to_time < time
      hourlyweathers.each_with_index do |weather, index|
        date = weather.children[1].text.to_time
        if date > time
          break
        end
        start_index = index
      end

      (1..4).each do |i|
        temp = hourlyweathers[start_index].children[headers['Temp.']].text.squish
        dp = hourlyweathers[start_index].children[headers['Dew Point']].text.squish
        hum = hourlyweathers[start_index].children[headers['Humidity']].text.squish
        pressure = hourlyweathers[start_index].children[headers['Pressure']].text.squish
        precip = hourlyweathers[start_index].children[headers['Precip']].text.squish
        wind_dir = hourlyweathers[start_index].children[headers['Wind Dir']].text.squish
        wind_speed = hourlyweathers[start_index].children[headers['Wind Speed']].text.squish
        weather = game.weathers.find_or_create_by(station: "Actual", hour: i)
        weather.update(temp: temp, dp: dp, hum: hum, pressure: pressure, wind_dir: wind_dir, wind_speed: wind_speed, precip: precip)

        start_index = start_index + 1 if start_index < hourlyweathers.size - 1
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
        wind_min = weather.wind_speed.to_f - 5
        wind_max = weather.wind_speed.to_f + 5
        wind_min = 3 if wind_min < 3
        result = true_data(weather.temp_num - 5, weather.temp_num + 5, weather.dew_num-2, weather.dew_num+2, weather.humid_num-3, weather.humid_num+3, (weather.pressure_num-0.04).round(2), (weather.pressure_num+0.04).round(2), wind_min, wind_max, weather.wind_dir, weather.wind_dir, name)
        create_weathersource(game.id, date, 2, block_number, row_number, weather_time(weather.game.game_date, weather.hour), weather.temp, weather.dp, weather.hum, weather.pressure, weather.wind, result)
        row_number = row_number + 1
      end
      block_number = block_number + 1

      weathers.each_with_index do |weather, index|
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
        wind_speed_diff = ((11 + wind_min - wind_max)/2).to_i
        wind_min = wind_min - wind_speed_diff
        wind_max = wind_max + wind_speed_diff
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
        wind_speed_diff = ((11 + wind_min - wind_max)/2).to_i
        wind_min = wind_min - wind_speed_diff
        wind_max = wind_max + wind_speed_diff
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
        url = @@urls[home_team.id-1]
        find = "year/month/day"
        replace = "#{game_day.year}/#{game_day.month}/#{game_day.day}"
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
        "https://www.wunderground.com/history/airport/KFUL/year/month/day/DailyHistory.html?req_city=Anaheim&req_state=CA&reqdb.zip=92806&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/airport/KMCJ/year/month/day/DailyHistory.html?req_city=Houston&req_state=TX&reqdb.zip=77002&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/airport/KOAK/year/month/day/DailyHistory.html?req_city=Oakland&req_state=CA&reqdb.zip=94621&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/airport/CXTO/year/month/day/DailyHistory.html?req_city=Toronto&req_statename=Ontario&reqdb.zip=00000&reqdb.magic=233&reqdb.wmo=71508",
        "https://www.wunderground.com/history/airport/KATL/year/month/day/DailyHistory.html?req_city=Atlanta&req_state=GA&reqdb.zip=30315&reqdb.magic=1&reqdb.wmo=99999&MR=1",
        "https://www.wunderground.com/history/airport/KMWC/year/month/day/DailyHistory.html?req_city=Milwaukee&req_state=WI&reqdb.zip=53214&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/airport/KCPS/year/month/day/DailyHistory.html?req_city=Saint%20Louis&req_state=MO&reqdb.zip=63102&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/airport/KMDW/year/month/day/DailyHistory.html?req_city=Chicago&req_state=IL&reqdb.zip=60613&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/airport/KPHX/year/month/day/DailyHistory.html?req_city=Phoenix&req_state=AZ&reqdb.zip=85004&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/airport/KCQT/year/month/day/DailyHistory.html?req_city=Los%20Angeles&req_state=CA&reqdb.zip=90012&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/airport/KOAK/year/month/day/DailyHistory.html?req_city=San%20Francisco&req_state=CA&reqdb.zip=94107&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/airport/KBKL/year/month/day/DailyHistory.html?req_city=Cleveland&req_state=OH&reqdb.zip=44115&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/airport/KBFI/year/month/day/DailyHistory.html?req_city=Seattle&req_state=WA&reqdb.zip=98134&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/airport/KMIA/year/month/day/DailyHistory.html?req_city=Miami&req_state=FL&reqdb.zip=33125&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/airport/KLGA/year/month/day/DailyHistory.html?req_city=Corona&req_state=NY&reqdb.zip=11368&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/airport/KDCA/year/month/day/DailyHistory.html?req_city=Washington&req_state=DC&reqdb.zip=20003&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/airport/KDMH/year/month/day/DailyHistory.html?req_city=Baltimore&req_state=MD&req_statename=&reqdb.zip=21201&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/airport/KSAN/year/month/day/DailyHistory.html?req_city=San%20Diego&req_state=CA&reqdb.zip=92101&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/airport/KPHL/year/month/day/DailyHistory.html?req_city=Philadelphia&req_state=PA&reqdb.zip=19148&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/airport/KAGC/year/month/day/DailyHistory.html?req_city=Pittsburgh&req_state=PA&reqdb.zip=15212&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/airport/KGPM/year/month/day/DailyHistory.html?req_city=Arlington&req_state=TX&reqdb.zip=76011&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/airport/KSPG/year/month/day/DailyHistory.html?req_city=Saint%20Petersburg&req_state=FL&reqdb.zip=33705&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/airport/KBOS/year/month/day/DailyHistory.html?req_city=Boston&req_state=MA&reqdb.zip=02215&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/airport/KLUK/year/month/day/DailyHistory.html?req_city=Cincinnati&req_state=OH&reqdb.zip=45202&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/airport/KBKF/year/month/day/DailyHistory.html?req_city=Denver&req_state=CO&reqdb.zip=80205&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/airport/KMKC/year/month/day/DailyHistory.html?req_city=Kansas%20City&req_state=MO&reqdb.zip=64129&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/airport/KDET/year/month/day/DailyHistory.html?req_city=Detroit&req_state=MI&reqdb.zip=48201&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/airport/KMSP/year/month/day/DailyHistory.html?req_city=Minneapolis&req_state=MN&reqdb.zip=55403&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/airport/KMDW/year/month/day/DailyHistory.html?req_city=Chicago&req_state=IL&reqdb.zip=60616&reqdb.magic=1&reqdb.wmo=99999",
        "https://www.wunderground.com/history/airport/KLGA/year/month/day/DailyHistory.html?req_city=Bronx&req_state=NY&reqdb.zip=10451&reqdb.magic=1&reqdb.wmo=99999"
        ]
  end
end

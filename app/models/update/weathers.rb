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

    private
      def get_url(home_team, game_day)
        url = @@urls[home_team.id-1]
        find = "year/month/day"
        replace = "#{game_day.year}/#{game_day.month}/#{game_day.day}"
        url.gsub(/#{find}/, replace)
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

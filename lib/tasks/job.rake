namespace :job do

  task add: :environment do
    filename = File.join Rails.root, "Workbook.csv"
    count = 0
    CSV.foreach(filename, headers:true) do |row|
      Workbook.create(Home_Team:row['Home_Team'], TEMP:row['TEMP'], DP:row['DP'], HUMID:row['HUMID'], BARo:row['BARo'], R:row['R'], Total_Hits:row['Total_Hits'], Total_Walks:row['Total_Walks'], home_runs:row['home_runs'])
      count = count + 1
    end
    puts count

    filename = File.join Rails.root, "colo.csv"
    count = 0
    CSV.foreach(filename, headers:true) do |row|
      Colo.create(Home_Team:row['Home_Team'], TEMP:row['temp'], DP:row['DP'], HUMID:row['HUMID'], BARo:row['Baro'], R:row['R'], Total_Hits:row['Total_Hits'], Total_Walks:row['Total_Walks'], home_runs:row['home_runs'])
      count = count + 1
    end
    puts count

    filename = File.join Rails.root, "houston.csv"
    count = 0
    CSV.foreach(filename, headers:true) do |row|
      Houston.create(Home_Team:row['Home_Team'], TEMP:row['TEMP'], DP:row['DP'], HUMID:row['HUMID'], BARo:row['BARo'], R:row['R'], Total_Hits:row['Total_Hits'], Total_Walks:row['Total_Walks'], home_runs:row['home_runs'])
      count = count + 1
    end
    puts count

    filename = File.join Rails.root, "tampa.csv"
    count = 0
    CSV.foreach(filename, headers:true) do |row|
      Tampa.create(Home_Team:row['Home_Team'], TEMP:row['TEMP'], DP:row['DP'], HUMID:row['HUMID'], BARo:row['BARo'], R:row['R'], Total_Hits:row['Total_Hits'], Total_Walks:row['Total_Walks'], home_runs:row['home_runs'])
      count = count + 1
    end
    puts count
  end

  task :import => :environment do
    require 'csv'
    CSV.foreach(Rails.root.join('csv', 'results.csv'), headers: true) do |row|
      Result.create(row.to_h)
    end
  end

  task bydate: :environment do
    include GetHtml
    index_date = Date.new(2011, 3, 31)
    year = 2011
    index = { away_team: 0, home_team: 1, result: 2 }
    while index_date <= Date.new(2011, 10, 28)
      game_date = index_date.strftime("%Y%m%d")
      url = "http://www.espn.com/mlb/schedule/_/date/#{game_date}"
      doc = download_document(url)
      elements = doc.css("tr")
      elements.each do |slice|
        if slice.children.size < 5
          next
        end
        away_team = slice.children[index[:away_team]].text
        if away_team == "matchup"
          next
        end
        href = slice.children[index[:result]].child['href']
        game_id = href[-9..-1]
        if slice.children[index[:result]].text == 'Canceled'
          puts game_id
          puts 'Canceled'
          next
        end
        game = Export.find_or_create_by(game_id: game_id)
        if slice.children[index[:home_team]].children[0].children.size == 2
          home_team = slice.children[index[:home_team]].children[0].children[1].children[0].text
          home_abbr = slice.children[index[:home_team]].children[0].children[1].children[2].text
        elsif slice.children[index[:home_team]].children[0].children.size == 1
          home_team = slice.children[index[:home_team]].children[0].children[0].children[0].text
          home_abbr = slice.children[index[:home_team]].children[0].children[0].children[2].text
        end

        if slice.children[index[:away_team]].children.size == 2
          away_abbr = slice.children[index[:away_team]].children[1].children[2].text
          away_team = slice.children[index[:away_team]].children[1].children[0].text
        elsif slice.children[index[:away_team]].children.size == 1
          away_abbr = slice.children[index[:away_team]].children[0].children[2].text
          away_team = slice.children[index[:away_team]].children[0].children[0].text
        end
        url = "http://www.espn.com/mlb/game?gameId=#{game_id}"
        doc = download_document(url)
        element = doc.css(".game-date-time").first
        game_date = element.children[1]['data-date']
        date = DateTime.parse(game_date)
        puts date
        element = doc.css(".location-details ul li").first
        if element
          stadium = element.text.squish
        else
          stadium = home_team
        end
        puts stadium
        game.update(year: year, away_team: away_team, away_abbr: away_abbr, home_team: home_team, home_abbr: home_abbr, game_id: game_id, game_date: date, stadium: stadium)
      end
      index_date = index_date + 1.days
    end
  end

  task byteam: :environment do
    include GetHtml
    team_abbrs = @team.keys
      year = 2018
      team_abbrs.each do |home_team_abbr|
        (1..1).each do |type|
          url = "http://www.espn.com/mlb/team/schedule/_/name/#{home_team_abbr}/year/#{year}/seasontype/2/half/#{type}"
          doc = download_document(url)
          elements = doc.css("tr")
          elements.each do |element|
            if element.children.size < 8
              next
            end
            if element.children[3].text == 'OPPONENT'
              next
            end
            status = element.children[2].children[0].children[0].text
            if element.children[2].children[0].children.size == 3
              opposite_team_link = element.children[2].children[0].children[2].children[0]['href']
              opposite_team_name_start = opposite_team_link.index('name/')
              opposite_team_name_end = opposite_team_link.index('/', opposite_team_name_start+5)
              opposite_team_name = opposite_team_link[opposite_team_name_start+5..opposite_team_name_end-1]
            else
              opposite_team_name = element.children[2].children[0].children[1].text.squish
            end

            if status == 'vs'
              away_abbr = opposite_team_name
              home_abbr = home_team_abbr
            else
              home_abbr = opposite_team_name
              away_abbr = home_team_abbr
            end

            away_abbr = @abbr[away_abbr] if @abbr[away_abbr]
            home_abbr = @abbr[home_abbr] if @abbr[home_abbr]

            away_team = away_abbr
            home_team = home_abbr
            away_team = @team[away_team] if @team[away_team]
            home_team = @team[home_team] if @team[home_team]
            puts away_team
            puts home_team

            next unless element.children[4].children[0].children.size == 2
            game_link = element.children[4].children[0].children[1].children[0]['href']
            if game_link && game_link != ''

              game_index_start = game_link.rindex('/')
              game_id = game_link[game_index_start+1..-1]

              url = "http://www.espn.com/mlb/game?gameId=#{game_id}"
              doc = download_document(url)
              element = doc.css(".game-date-time").first
              game_date = element.children[1]['data-date']
              date = DateTime.parse(game_date)
              puts date
              element = doc.css(".location-details ul li").first
              if element
                stadium = element.text.squish
              else
                stadium = home_team
              end
              game = Result.find_or_create_by(game_id: game_id)
              game.update(year: year, away_team: away_team, away_abbr: away_abbr, home_team: home_team, home_abbr: home_abbr, game_id: game_id, game_date: date, stadium: stadium)
            else
              date = element.children[0].text.squish + " " + year.to_s
              game = Result.find_or_create_by(year: year, away_team: away_team, away_abbr: away_abbr, home_team: home_team, home_abbr: home_abbr, game_date: date)
            end
          end
        end
      end
  end

  task getTimes: :environment do
    games = Result.where("month is null")
    games.each do |game|
      game_date = DateTime.parse(game.game_date)
      timeStadium = Stadium.where(stadium: game.stadium).first
      game_date = game_date + (timeStadium[:time].to_i).hours
      game.update(year: game_date.strftime("%Y"), day: game_date.strftime("%e"), month: game_date.strftime("%b"), time: game_date.strftime("%I:%M%p"))
    end
  end

  task getGameScore: :environment do
    include GetHtml
    games = Result.where("home_score_first is null")
    games.each do |game|
      url = "http://www.espn.com/mlb/boxscore?gameId=#{game.game_id}"
      puts url
      doc = download_document(url)
      element = doc.css(".linescore__table tr")
      size = element[1].children.size/2

      away_score_first =    element[1].children[3].text.squish
      away_score_second =   element[1].children[5].text.squish
      away_score_third =    element[1].children[7].text.squish
      away_score_forth =    element[1].children[9].text.squish
      away_score_fifth =    element[1].children[11].text.squish
      away_score_sixth =    element[1].children[13].text.squish
      away_score_seventh =  element[1].children[15].text.squish
      away_score_eighth =   element[1].children[17].text.squish
      away_score_nineth =   element[1].children[19].text.squish
      away_score_tenth =    element[1].children[size*2-5].text.squish

      home_score_first =    element[2].children[3].text.squish
      home_score_second =   element[2].children[5].text.squish
      home_score_third =    element[2].children[7].text.squish
      home_score_forth =    element[2].children[9].text.squish
      home_score_fifth =    element[2].children[11].text.squish
      home_score_sixth =    element[2].children[13].text.squish
      home_score_seventh =  element[2].children[15].text.squish
      home_score_eighth =   element[2].children[17].text.squish
      home_score_nineth =   element[2].children[19].text.squish
      home_score_tenth =    element[2].children[size*2-5].text.squish

      game.update(
        away_score_first: away_score_first,
        away_score_second: away_score_second,
        away_score_third: away_score_third,
        away_score_forth: away_score_forth,
        away_score_fifth: away_score_fifth,
        away_score_sixth: away_score_sixth,
        away_score_seventh: away_score_seventh,
        away_score_eighth: away_score_eighth,
        away_score_nineth: away_score_nineth,
        away_score_tenth: away_score_tenth,
        home_score_first: home_score_first,
        home_score_second: home_score_second,
        home_score_third: home_score_third,
        home_score_forth: home_score_forth,
        home_score_fifth: home_score_fifth,
        home_score_sixth: home_score_sixth,
        home_score_seventh: home_score_seventh,
        home_score_eighth: home_score_eighth,
        home_score_nineth: home_score_nineth,
        home_score_tenth: home_score_tenth
      )
    end
  end

  task getML: :environment do
    include GetHtml
    index_date = Date.new(2018, 3, 29)
    while index_date <= Date.new(2018, 5, 3)
      game_date = index_date.strftime("%Y%m%d")
      puts game_date
      url = "https://www.sportsbookreview.com/betting-odds/mlb-baseball/?date=#{game_date}"
      doc = download_document(url)
      elements = doc.css(".event-holder")
      elements.each do |element|
        home_ml = element.children[0].children[11].children[1].text.squish
        away_ml = element.children[0].children[11].children[0].text.squish

        home_name = element.children[0].children[5].children[1].text.squish
        away_name = element.children[0].children[5].children[0].text.squish

        home_name_index = home_name.index(' -')
        home_name = home_name_index ? home_name[0..home_name_index-1].downcase : home_name.downcase

        away_name_index = away_name.index(' -')
        away_name = away_name_index ? away_name[0..away_name_index-1].downcase : away_name.downcase

        if @team[home_name]
          home_name = @team[home_name]
        end
        if @team[away_name]
          away_name = @team[away_name]
        end

        game = Result.where("home_team = ? AND away_team = ? AND year = ? AND day = ? AND month = ?", home_name, away_name, index_date.strftime("%Y"), index_date.strftime("%e"), index_date.strftime("%b"))

        if game.count == 2
          if element.children[0].children[1].children.size > 2
            home_score = element.children[0].children[1].children[2].children[3].children[1].children[1].text.squish
            away_score = element.children[0].children[1].children[2].children[3].children[0].children[1].text.squish
            game = Result.where("home_team = ? AND away_team = ? AND year = ? AND day = ? AND month = ? AND home_score_tenth = ? AND away_score_tenth = ?", home_name, away_name, index_date.strftime("%Y"), index_date.strftime("%e"), index_date.strftime("%b"), home_score, away_score).first
          else
            game = game.second
          end
        elsif game.count == 1
          game = game.first
        elsif game.count == 0
          game = Result.where("away_team = ? AND home_team = ? AND year = ? AND day = ? AND month = ?", home_name, away_name, index_date.strftime("%Y"), index_date.strftime("%e"), index_date.strftime("%b"))
          if game.count == 2
            if element.children[0].children[1].children.size > 2
              home_score = element.children[0].children[1].children[2].children[3].children[1].children[1].text.squish
              away_score = element.children[0].children[1].children[2].children[3].children[0].children[1].text.squish
              game = Result.where("away_team = ? AND home_team = ? AND year = ? AND day = ? AND month = ? AND away_score_tenth = ? AND home_score_tenth = ?", home_name, away_name, index_date.strftime("%Y"), index_date.strftime("%e"), index_date.strftime("%b"), home_score, away_score).first
            else
              game = game.second
            end
          elsif game.count == 1
            game = game.first
          end
        end
        game.update(away_ml: away_ml, home_ml: home_ml) if game
      end
      index_date = index_date + 1.days
    end
  end

  task getTotal: :environment do
    include GetHtml
    index_date = Date.new(2018, 3, 29)
    while index_date <= Date.new(2018, 5, 3)
      game_date = index_date.strftime("%Y%m%d")
      puts game_date
      url = "https://www.sportsbookreview.com/betting-odds/mlb-baseball/totals/?date=#{game_date}"
      doc = download_document(url)
      elements = doc.css(".event-holder")
      elements.each do |element|
        home_total = element.children[0].children[11].children[1].text.squish
        away_total = element.children[0].children[11].children[0].text.squish

        home_name = element.children[0].children[5].children[1].text.squish
        away_name = element.children[0].children[5].children[0].text.squish

        home_name_index = home_name.index(' -')
        home_name = home_name_index ? home_name[0..home_name_index-1].downcase : home_name.downcase

        away_name_index = away_name.index(' -')
        away_name = away_name_index ? away_name[0..away_name_index-1].downcase : away_name.downcase

        if @team[home_name]
          home_name = @team[home_name]
        end
        if @team[away_name]
          away_name = @team[away_name]
        end

        game = Result.where("home_team = ? AND away_team = ? AND year = ? AND day = ? AND month = ?", home_name, away_name, index_date.strftime("%Y"), index_date.strftime("%e"), index_date.strftime("%b"))

        if game.count == 2
          if element.children[0].children[1].children.size > 2
            home_score = element.children[0].children[1].children[2].children[3].children[1].children[1].text.squish
            away_score = element.children[0].children[1].children[2].children[3].children[0].children[1].text.squish
            game = Result.where("home_team = ? AND away_team = ? AND year = ? AND day = ? AND month = ? AND home_score_tenth = ? AND away_score_tenth = ?", home_name, away_name, index_date.strftime("%Y"), index_date.strftime("%e"), index_date.strftime("%b"), home_score, away_score).first
          else
            game = game.second
          end
        elsif game.count == 1
          game = game.first
        elsif game.count == 0
          game = Result.where("away_team = ? AND home_team = ? AND year = ? AND day = ? AND month = ?", home_name, away_name, index_date.strftime("%Y"), index_date.strftime("%e"), index_date.strftime("%b"))
          if game.count == 2
            if element.children[0].children[1].children.size > 2
              home_score = element.children[0].children[1].children[2].children[3].children[1].children[1].text.squish
              away_score = element.children[0].children[1].children[2].children[3].children[0].children[1].text.squish
              game = Result.where("away_team = ? AND home_team = ? AND year = ? AND day = ? AND month = ? AND away_score_tenth = ? AND home_score_tenth = ?", home_name, away_name, index_date.strftime("%Y"), index_date.strftime("%e"), index_date.strftime("%b"), home_score, away_score).first
            else
              game = game.second
            end
          elsif game.count == 1
            game = game.first
          end
        end

        game.update(away_total: away_total, home_total: home_total) if game
      end
      index_date = index_date + 1.days
    end
  end

  task getBoxScore: :environment do
    include GetHtml
    games = Result.where("total_hits_both_team is null")
    games.each do |game|
      url = "http://www.espn.com/mlb/boxscore?gameId=#{game.game_id}"
      puts url
      doc = download_document(url)

      pitchers = doc.css('.stats-wrap')
      next if pitchers.size < 4
      away_pitcher = pitchers[1]
      home_pitcher = pitchers[3]
      away_pitcher_size = away_pitcher.children.size
      home_pitcher_size = home_pitcher.children.size
      next if away_pitcher_size == 3 && away_pitcher.children[1].children[0].children.size == 1
      next if home_pitcher_size == 3 && home_pitcher.children[1].children[0].children.size == 1
      away_total = away_pitcher.children[away_pitcher_size-1].children[0]
      home_total = home_pitcher.children[home_pitcher_size-1].children[0]
      hr_total = away_total.children[7].text.to_i + home_total.children[7].text.to_i
      h_total = away_total.children[2].text.to_i + home_total.children[2].text.to_i
      bb_total = away_total.children[5].text.to_i + home_total.children[5].text.to_i

      batters = doc.css('.team-stats-container')
      next if batters.size < 4
      away_batter = batters[0].children[0].children[0].children[1..-1]
      home_batter = batters[2].children[0].children[0].children[1..-1]
      away_twob_total = 0
      away_threeb_total = 0
      home_twob_total = 0
      home_threeb_total = 0

      away_batter.each do |batter|
        if batter.children[0].text == '2B:'
          b = batter.children[1].text.split(';')
          b.each do |eachb|
            eachb_index = eachb.index(' (')
            eachb_index = eachb[eachb_index-1].to_i
            eachb_index = 1 if eachb_index == 0
            away_twob_total = away_twob_total + eachb_index
          end
        end
        if batter.children[0].text == '3B:'
          b = batter.children[1].text.split(';')
          b.each do |eachb|
            eachb_index = eachb.index(' (')
            eachb_index = eachb[eachb_index-1].to_i
            eachb_index = 1 if eachb_index == 0
            away_threeb_total = away_threeb_total + eachb_index
          end
          break
        end
      end

      home_batter.each do |batter|
        if batter.children[0].text == '2B:'
          b = batter.children[1].text.split(';')
          b.each do |eachb|
            eachb_index = eachb.index(' (')
            eachb_index = eachb[eachb_index-1].to_i
            eachb_index = 1 if eachb_index == 0
            home_twob_total = home_twob_total + eachb_index
          end
        end
        if batter.children[0].text == '3B:'
          b = batter.children[1].text.split(';')
          b.each do |eachb|
            eachb_index = eachb.index(' (')
            eachb_index = eachb[eachb_index-1].to_i
            eachb_index = 1 if eachb_index == 0
            home_threeb_total = home_threeb_total + eachb_index
          end
          break
        end
      end

      twob_total = away_twob_total + home_twob_total
      threeb_total = away_threeb_total + home_threeb_total

      away_starter = away_pitcher.children[1].children[0].children[0].children[0]['href']
      doc = download_document(away_starter)
      away_full_name = doc.css('h1').first.text
      away_name_index = away_full_name.rindex(' ')
      away_first_name = away_full_name[0..away_name_index-1]
      away_last_name = away_full_name[away_name_index+1..-1]
      away_starter_info = doc.css('.general-info')
      away_starter_hand = ''
      if away_starter_info.children.size > 2
        away_starter_info = away_starter_info.children[1].text
        away_starter_info_index = away_starter_info.index('Throws: ')
        away_starter_hand = away_starter_info[away_starter_info_index+8]
      end

      home_starter = home_pitcher.children[1].children[0].children[0].children[0]['href']
      doc = download_document(home_starter)
      home_full_name = doc.css('h1').first.text
      home_name_index = home_full_name.rindex(' ')
      home_first_name = home_full_name[0..home_name_index-1]
      home_last_name = home_full_name[home_name_index+1..-1]
      home_starter_info = doc.css('.general-info')
      home_starter_hand = ''
      if home_starter_info.children.size > 2
        home_starter_info = home_starter_info.children[1].text
        home_starter_info_index = home_starter_info.index('Throws: ')
        home_starter_hand = home_starter_info[home_starter_info_index+8]
      end
      game.update(total_hits_both_team: h_total,
        total_walks_both_team: bb_total,
        total_doubles_both_team: twob_total,
        total_triples_both_team: threeb_total,
        total_bases_both_team: hr_total,
        away_starter_last_game: away_last_name,
        away_starter_first_name: away_first_name,
        away_starter_handedness: away_starter_hand,
        home_starter_last_name: home_last_name,
        home_starter_first_name: home_first_name,
        home_starter_handedness: home_starter_hand)
    end
  end

  task getWeather: :environment do
    include GetHtml
    games = Result.where("first_temp is null")
    games.each do |game|
      time = game.time.to_time - 30.minutes
      url = @weaterstation[game.stadium]
      url = url.gsub('year', game.year)
      url = url.gsub('month', @month[game.month])
      url = url.gsub('day', game.day.squish)
      puts url
      doc = download_document(url)
      header = doc.css(".obs-table tr").first
      next unless header
      headers = {
        'Temp.' => 0,
        'Dew Point' => 0,
        'Humidity' => 0,
        'Pressure' => 0,
        'Wind Dir' => 0,
        'Wind Speed' => 0
      }
      header.children.each_with_index do |header_element, index|
        key = header_element.text.squish
        headers[key] = index if key == 'Temp.'
        headers[key] = index if key == 'Dew Point'
        headers[key] = index if key == 'Humidity'
        headers[key] = index if key == 'Pressure'
        headers[key] = index if key == 'Wind Dir'
        headers[key] = index if key == 'Wind Speed' 
      end

      hourlyweathers = doc.css(".no-metars")
      start_index = hourlyweathers.size - 1
      hourlyweathers.each_with_index do |weather, index|
        date = weather.children[1].text.to_time
        if date > time
          start_index = index
          break
        end
      end
      first_temp = hourlyweathers[start_index].children[headers['Temp.']].children[1].children[0].text unless hourlyweathers[start_index].children[headers['Temp.']].children.size == 1
      first_dp = hourlyweathers[start_index].children[headers['Dew Point']].children[1].children[0].text unless hourlyweathers[start_index].children[headers['Dew Point']].children.size == 1
      first_humid = hourlyweathers[start_index].children[headers['Humidity']].text
      first_baro = hourlyweathers[start_index].children[headers['Pressure']].children[1].children[0].text unless hourlyweathers[start_index].children[headers['Pressure']].children.size == 1
      first_wind_direction = hourlyweathers[start_index].children[headers['Wind Dir']].text
      first_wind_speed = hourlyweathers[start_index].children[headers['Wind Speed']].text

      start_index = start_index + 1 if start_index < hourlyweathers.size - 1
      second_temp = hourlyweathers[start_index].children[headers['Temp.']].children[1].children[0].text unless hourlyweathers[start_index].children[headers['Temp.']].children.size == 1
      second_dp = hourlyweathers[start_index].children[headers['Dew Point']].children[1].children[0].text unless hourlyweathers[start_index].children[headers['Dew Point']].children.size == 1
      second_humid = hourlyweathers[start_index].children[headers['Humidity']].text
      second_baro = hourlyweathers[start_index].children[headers['Pressure']].children[1].children[0].text unless hourlyweathers[start_index].children[headers['Pressure']].children.size == 1
      second_wind_direction = hourlyweathers[start_index].children[headers['Wind Dir']].text
      second_wind_speed = hourlyweathers[start_index].children[headers['Wind Speed']].text

      start_index = start_index + 1 if start_index < hourlyweathers.size - 1
      third_temp = hourlyweathers[start_index].children[headers['Temp.']].children[1].children[0].text unless hourlyweathers[start_index].children[headers['Temp.']].children.size == 1
      third_dp = hourlyweathers[start_index].children[headers['Dew Point']].children[1].children[0].text unless hourlyweathers[start_index].children[headers['Dew Point']].children.size == 1
      third_humid = hourlyweathers[start_index].children[headers['Humidity']].text
      third_baro = hourlyweathers[start_index].children[headers['Pressure']].children[1].children[0].text unless hourlyweathers[start_index].children[headers['Pressure']].children.size == 1
      third_wind_direction = hourlyweathers[start_index].children[headers['Wind Dir']].text
      third_wind_speed = hourlyweathers[start_index].children[headers['Wind Speed']].text
      game.update(first_temp: first_temp,
        second_temp: second_temp,
        third_temp: third_temp,
        first_dp: first_dp,
        second_dp: second_dp,
        third_dp: third_dp,
        first_humid: first_humid,
        second_humid: second_humid,
        third_humid: third_humid,
        first_baro: first_baro,
        second_baro: second_baro,
        third_baro: third_baro,
        first_wind_direction: first_wind_direction,
        second_wind_direction: second_wind_direction,
        third_wind_direction: third_wind_direction,
        first_wind_speed: first_wind_speed,
        second_wind_speed: second_wind_speed,
        third_wind_speed: third_wind_speed)
    end
  end

  @month = {
    'Jan' => '1',
    'Feb' => '2',
    'Mar' => '3',
    'Apr' => '4',
    'May' => '5',
    'Jun' => '6',
    'Jul' => '7',
    'Aug' => '8',
    'Sep' => '9',
    'Oct' => '10',
    'Nov' => '11',
    'Dec' => '12'
  }

  @abbr = {
    'la' => 'lad',
    'Florida' => 'mia',
    'was' => 'wsh',
    'cws' => 'chw',
    'Montreal' => 'wsh',
    'Anaheim' => 'laa',
    'California' => 'laa'
  }

  @team = {
    'bal' => 'Baltimore Orioles',
    'bos' => 'Boston Red Sox',
    'nyy' => 'New York Yankees',
    'tb' => 'Tampa Bay Rays',
    'tor' => 'Toronto Blue Jays',
    'atl' => 'Atlanta Braves',
    'mia' => 'Miami Marlins',
    'nym' => 'New York Mets',
    'phi' => 'Philadelphia Phillies',
    'wsh' => 'Washington Nationals',
    'chw' => 'Chicago White Sox',
    'cle' => 'Cleveland Indians',
    'det' => 'Detroit Tigers',
    'kc' => 'Kansas City Royals',
    'min' => 'Minnesota Twins',
    'chc' => 'Chicago Cubs',
    'cin' => 'Cincinnati Reds',
    'mil' => 'Milwaukee Brewers',
    'pit' => 'Pittsburgh Pirates',
    'stl' => 'St. Louis Cardinals',
    'hou' => 'Houston Astros',
    'laa' => 'Los Angeles Angels',
    'oak' => 'Oakland Athletics',
    'sea' => 'Seattle Mariners',
    'tex' => 'Texas Rangers',
    'ari' => 'Arizona Diamondbacks',
    'col' => 'Colorado Rockies',
    'lad' => 'Los Angeles Dodgers',
    'sd' => 'San Diego Padres',
    'sf' => 'San Francisco Giants'
  }


  @weaterstation = {
    'Flushing, New York 11390' => 'https://www.wunderground.com/history/airport/KLGA/year/month/day/DailyHistory.html?req_city=Flushing&req_state=&req_statename=New+York&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
    'Minneapolis, Minnesota 55488' => 'https://www.wunderground.com/history/airport/KMIC/year/month/day/DailyHistory.html?req_city=Minneapolis&req_state=&req_statename=Minnesota&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
    'San Diego, California 92199' => 'https://www.wunderground.com/history/airport/KSAN/year/month/day/DailyHistory.html?req_city=San+Diego&req_state=CA&req_statename=California&reqdb.zip=92101&reqdb.magic=1&reqdb.wmo=99999',
    'Kansas City, Missouri 64999' => 'https://www.wunderground.com/history/airport/KNKA/year/month/day/DailyHistory.html?req_city=Kansas+City&req_state=&req_statename=Missouri&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
    'Anaheim, California 92899' => 'https://www.wunderground.com/history/airport/KFUL/year/month/day/DailyHistory.html?req_city=Anaheim&req_state=CA&req_statename=California&reqdb.zip=92801&reqdb.magic=1&reqdb.wmo=99999',
    'Houston, Texas 77299' => 'https://www.wunderground.com/history/airport/KMCJ/year/month/day/DailyHistory.html?req_city=Houston&req_state=TX&req_statename=Texas&reqdb.zip=77001&reqdb.magic=1&reqdb.wmo=99999',
    'Detroit, Michigan 48201' => 'https://www.wunderground.com/history/airport/KDET/year/month/day/DailyHistory.html?req_city=Detroit&req_state=&req_statename=Michigan&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
    'Toronto, Ontario' => 'https://www.wunderground.com/history/airport/CXTO/year/month/day/DailyHistory.html?req_city=Toronto&req_state=&req_statename=Ontario&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
    'Oakland, California 94666' => 'https://www.wunderground.com/history/airport/KOAK/year/month/day/DailyHistory.html?req_city=Oakland&req_state=&req_statename=California&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
    'San Juan, Puerto Rico' => 'https://www.wunderground.com/history/airport/TJSJ/year/month/day/DailyHistory.html?req_city=San+Juan&req_state=&req_statename=Puerto+Rico&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
    'St. Louis, Missouri 63012' => 'https://www.wunderground.com/history/airport/KCPS/year/month/day/DailyHistory.html?req_city=Saint+Louis&req_state=&req_statename=Missouri&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
    'Chicago, Illinois 60616' => 'https://www.wunderground.com/history/airport/KORD/year/month/day/DailyHistory.html?req_city=Chicago&req_state=&req_statename=Illinois&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
    'St. Petersburg, Florida 33784' => 'https://www.wunderground.com/history/airport/KSPG/year/month/day/DailyHistory.html?req_city=Saint+Petersburg&req_state=&req_statename=Florida&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
    'Miami, Florida 33299' => 'https://www.wunderground.com/history/airport/KMIA/year/month/day/DailyHistory.html?req_city=Miami&req_state=&req_statename=Florida&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
    'Boston, Massachusetts 02297' => 'https://www.wunderground.com/history/airport/KBOS/year/month/day/DailyHistory.html?req_city=Boston&req_state=&req_statename=Massachusetts&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
    'Los Angeles, California 90185' => 'https://www.wunderground.com/history/airport/KCQT/year/month/day/DailyHistory.html?req_city=Los+Angeles&req_state=&req_statename=California&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
    'New York, New York 10451' => 'https://www.wunderground.com/history/airport/KNYC/year/month/day/DailyHistory.html?req_city=New+York&req_state=&req_statename=New+York&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
    'Arlington, Texas 76096' => 'https://www.wunderground.com/history/airport/KGKY/year/month/day/DailyHistory.html?req_city=Arlington&req_state=&req_statename=Texas&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
    'Williamsport, PA' => 'https://www.wunderground.com/history/airport/KIPT/year/month/day/DailyHistory.html?req_city=Williamsport&req_state=&req_statename=Pennsylvania&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
    'San Francisco, California 94188' => 'https://www.wunderground.com/history/airport/KSFO/year/month/day/DailyHistory.html?req_city=San+Francisco&req_state=&req_statename=California&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
    'Baltimore, Maryland 21298' => 'https://www.wunderground.com/history/airport/KDMH/year/month/day/DailyHistory.html?req_city=Baltimore&req_state=&req_statename=Maryland&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
    'Washington, D.C.' => 'https://www.wunderground.com/history/airport/KDCA/year/month/day/DailyHistory.html?req_city=Washington&req_state=DC&req_statename=District+of+Columbia&reqdb.zip=20001&reqdb.magic=1&reqdb.wmo=99999',
    'Cumberland, GA' => 'https://www.wunderground.com/history/airport/KAHN/year/month/day/DailyHistory.html?req_city=Cumberland&req_state=&req_statename=Georgia&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
    'Washington, D.C. 20003' => 'https://www.wunderground.com/history/airport/KDCA/year/month/day/DailyHistory.html?req_city=Washington&req_state=DC&req_statename=District+of+Columbia&reqdb.zip=20001&reqdb.magic=1&reqdb.wmo=99999',
    'Denver, Colorado 80299' => 'https://www.wunderground.com/history/airport/KBKF/year/month/day/DailyHistory.html?req_city=Denver&req_state=&req_statename=Colorado&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
    'Kissimmee, Florida 34759' => 'https://www.wunderground.com/history/airport/KISM/year/month/day/DailyHistory.html?req_city=Kissimmee&req_state=&req_statename=Florida&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
    'Seattle, Washington 98104' => 'https://www.wunderground.com/history/airport/KBFI/year/month/day/DailyHistory.html?req_city=Seattle&req_state=WA&req_statename=Washington&reqdb.zip=98101&reqdb.magic=1&reqdb.wmo=99999',
    'Bronx, New York 10499' => 'https://www.wunderground.com/history/airport/KLGA/year/month/day/DailyHistory.html?req_city=Bronx&req_state=&req_statename=New+York&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
    'New York, New York 11368' => 'https://www.wunderground.com/history/airport/KNYC/year/month/day/DailyHistory.html?req_city=New+York&req_state=&req_statename=New+York&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
    'Tokyo, Japan' => 'https://www.wunderground.com/history/airport/RJTD/year/month/day/DailyHistory.html?req_city=Tokyo&req_state=&req_statename=Japan&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
    'Milwaukee, Wisconsin 53295' => 'https://www.wunderground.com/history/airport/KMKE/year/month/day/DailyHistory.html?req_city=Milwaukee&req_state=&req_statename=Wisconsin&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
    'Cleveland, Ohio 44199' => 'https://www.wunderground.com/history/airport/KBKL/year/month/day/DailyHistory.html?req_city=Cleveland&req_state=&req_statename=Ohio&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
    'Phoenix, Arizona 85099' => 'https://www.wunderground.com/history/airport/KPHX/year/month/day/DailyHistory.html?req_city=Phoenix&req_state=&req_statename=Arizona&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
    'Cumberland, NC' => 'https://www.wunderground.com/history/airport/KFAY/year/month/day/DailyHistory.html?req_city=Cumberland&req_state=&req_statename=North+Carolina&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
    'Sydney, New South' => 'https://www.wunderground.com/history/airport/YSSY/year/month/day/DailyHistory.html?req_city=Sydney&req_state=&req_statename=Australia&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
    'Pittsburgh, Pennsylvania 15212' => 'https://www.wunderground.com/history/airport/KAGC/year/month/day/DailyHistory.html?req_city=Pittsburgh&req_state=PA&req_statename=Pennsylvania&reqdb.zip=15201&reqdb.magic=1&reqdb.wmo=99999',
    'Cincinnati, Ohio 45999' => 'https://www.wunderground.com/history/airport/KLUK/year/month/day/DailyHistory.html?req_city=Cincinnati&req_state=OH&req_statename=Ohio&reqdb.zip=45201&reqdb.magic=1&reqdb.wmo=99999',
    'Cumberland, Georgia 39901' => 'https://www.wunderground.com/history/airport/KAHN/year/month/day/DailyHistory.html?req_city=Cumberland&req_state=&req_statename=Georgia&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
    'Philadelphia, Pennsylvania 19255' => 'https://www.wunderground.com/history/airport/KPHL/year/month/day/DailyHistory.html?req_city=Philadelphia&req_state=&req_statename=Pennsylvania&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
    'Chicago, Illinois 60613' => 'https://www.wunderground.com/history/airport/KORD/year/month/day/DailyHistory.html?req_city=Chicago&req_state=&req_statename=Illinois&reqdb.zip=&reqdb.magic=&reqdb.wmo='
  }


end

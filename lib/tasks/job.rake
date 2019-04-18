require "#{Rails.root}/app/helpers/game_helper"
include GameHelper
namespace :job do

  task :test => :environment do
    include GetHtml
    url = "http://www.baseballpress.com/bullpen-usage"
    puts url
    doc = download_document(url)

    doc.css(".no-space tr").each do |element|
      if element.children.size < 3
        puts element.children[0].text
        next
      end
      puts text.to_i
    end
  end

  task getGameID: :environment do
    game = Game.find(2629)
    puts game.game_day.inspect
  end

  task :prevgame => :environment do
    require 'csv'
    filename = File.join Rails.root, 'csv', "new_weather_second.csv"
    CSV.foreach(filename, headers: true) do |row|
      game = row.to_h
      if game['away_total']
        line_index = row['away_total'].index('-')
        line_index = row['away_total'].index('+') unless line_index
        game['total_line'] = line_index ? row['away_total'][0..line_index - 1] : ''
        home_team_index = game['home_team'].rindex(' ')
        game['Home_Team'] = game['home_team'][0..home_team_index - 1]
        game['N'] = game['speed'].to_i
        game['M'] = game['wind']
      end
      Prevgame.create(game)
    end
  end

  task :weather_first => :environment do
    require 'csv'
    filename = Rails.root.join('csv', 'new_weather_first.csv')
    CSV.foreach(filename, headers: true) do |row|
      Workbook.create(row.to_h)
    end
  end

  task :fix_first => :environment do
    games = Workbook.where('total_line is null')
    games.each do |game|
      if game['Away_Total']
        line_index = game['Away_Total'].index('-')
        line_index = game['Away_Total'].index('+') unless line_index
        game.update(total_line: line_index ? game['Away_Total'][0..line_index - 1] : '')
      end
    end
  end

  task :weather_second => :environment do
    require 'csv'
    filename = Rails.root.join('csv', 'weather_second.csv')
    CSV.foreach(filename, headers: true) do |row|
      WeatherSecond.create(row.to_h)
    end
  end

  task :weather_first_game_duplicate => :environment do
    include GetHtml
    weather_firsts = WeatherFirst.where('game_id is not null')
    weather_firsts.each do |weather_first|
      sameItems = WeatherFirst.where('game_id = ?', weather_first.game_id)
      if sameItems.length > 2
        puts weather_first.game_id
        sameItems.update(game_id: nil)
      end
    end
  end

  task :basketball_game => :environment do
    include GetHtml
    url = "https://www.baseball-reference.com/boxes/?date=2016-05-20"
    doc = download_document(url)
    doc.xpath('//comment()').each {|comment| comment.replace(comment.text)}
    next unless doc
    trs = doc.css(".game_summary table:first-child tbody")
    trs.each do |slice|
      away_team = slice.children[1].children[1].children[0].text
      home_team = slice.children[3].children[1].children[0].text
      away_score = slice.children[1].children[3].text.to_i
      home_score = slice.children[3].children[3].text.to_i
      game_id = slice.children[1].children[5].children[1]['href']
      puts away_team
      puts home_team
      puts away_score
      puts home_score
      puts game_id
    end
    url = "https://www.baseball-reference.com/boxes/ATL/ATL200409240.shtml"
    doc = download_document(url)
    doc.xpath('//comment()').each {|comment| comment.replace(comment.text)}
    next unless doc
    elements = doc.css("#all_play_by_play tbody tr")
    index = 0
    home_runs = 0
    hits = 0
    elements.each do |element|
      if element.children.length == 12
        if element.children[11].text.include?("Home Run")
          home_runs += 1
        end
      end
      if element['class'].include?("pbp_summary_bottom")
        row_number = ((index + 2) / 2).to_i
        score_string = element.children[9].text
        score_string_end = score_string.rindex(" hit")
        score_string_start = score_string.rindex(",", score_string_end)
        hits += score_string[score_string_start + 1..score_string_end - 1].to_i
        index = index + 1
        if index % 2 == 0
          puts row_number
          puts hits
          puts home_runs
          hits = 0
          home_runs = 0
        end
      end
    end
  end

  task :count => :environment do
    players = Player.all
    list = []
    players.each do |player|
      next if player.name.include?("'")
      matched_players = Player.where("name LIKE '%" + player.name + "%'")
      if matched_players.length > 1
        list.push(player.name)
      end
    end
    puts list.inspect
  end

  task :newworkbook_id => :environment do
    include GetHtml
    games = Newworkbook.where('game_id is null')
    games.each_with_index do |game, index|
      puts index
      game_date = Date.strptime(game.Date, "%m/%d/%y")
      game_date = game_date.strftime("%Y%m%d")
      url = "http://www.espn.com/mlb/schedule/_/date/#{game_date}"
      puts url

      doc = download_document(url)
      next unless doc

      elements = doc.css("tr")
      elements[1..-1].each do |slice|
        if slice.children.size < 5
          next
        end
        away_team = slice.children[0].text
        if away_team == "matchup"
          break
        end
        href = 'http://www.espn.com' + slice.children[2].child['href']
        game_id = href[-9..-1]

        doc = download_document(href)
        next unless doc

        names = doc.css(".short-name")
        away_team = names[0].text.squish
        home_team = names[1].text.squish

        scores = doc.css(".score-container")
        away_score = scores[0].text.to_i
        home_score = scores[1].text.to_i

        away_score_data = game.A1.to_i + game.A2.to_i + game.A3.to_i + game.a4.to_i + game.a5.to_i + game.a6.to_i +
            game.a7.to_i + game.a8.to_i + game.a9.to_i
        home_score_data = game.h1.to_i + game.h2.to_i + game.h3.to_i + game.h4.to_i + game.h5.to_i + game.h6.to_i +
            game.h7.to_i + game.h8.to_i + game.h9.to_i

        if away_team == game.Away_Team && home_team == game.Home_Team
          game.update(game_id: game_id)
          break
        end
      end
    end
  end

  task :newworkbook_link => :environment do
    include GetHtml
    games = Newworkbook.where('link is null')
    games.each_with_index do |game, index|
      game_date = Date.strptime(game.Date, "%m/%d/%y")
      game_date = game_date.strftime("%F")
      url = "https://www.baseball-reference.com/boxes/?date=#{game_date}"
      puts url
      doc = download_document(url)
      next unless doc
      doc.xpath('//comment()').each {|comment| comment.replace(comment.text)}
      trs = doc.css(".game_summary table:first-child tbody")
      away_team_data = game.Away_Team
      home_team_data = game.Home_Team
      away_score_data = game.A1.to_i + game.A2.to_i + game.A3.to_i + game.a4.to_i + game.a5.to_i + game.a6.to_i +
          game.a7.to_i + game.a8.to_i + game.a9.to_i
      home_score_data = game.h1.to_i + game.h2.to_i + game.h3.to_i + game.h4.to_i + game.h5.to_i + game.h6.to_i +
          game.h7.to_i + game.h8.to_i + game.h9.to_i
      trs.each do |slice|
        away_team = slice.children[1].children[1].children[0].text
        home_team = slice.children[3].children[1].children[0].text
        away_score = slice.children[1].children[3].text.to_i
        home_score = slice.children[3].children[3].text.to_i
        if away_team.include?(away_team_data) && home_team.include?(home_team_data)
          link = slice.children[1].children[5].children[1]['href']
          game.update(link: link)
          break
        end
      end
    end
  end

  task :play_by_play => :environment do
    include GetHtml
    games = Newworkbook.where('"game_id" is not null and "ll_ab" is null')
    games.each do |game|
      url = "https://www.baseball-reference.com#{game.link}"
      puts url

      doc = download_document(url)
      next unless doc

      pitchers = []
      batters = []

      doc.xpath('//comment()').each {|comment| comment.replace(comment.text)}
      elements = doc.css('.table_outer_container table')
      elements[0..3].each_with_index do |element, flag|
        element.children[6].children.each_with_index do |tr, index|
          next if index % 2 == 0
          name = tr.children[0]
          next if name.children.length == 0
          name_link = name.children[0]
          name_link = name.children[1] if name.children.length == 3
          player_name = name_link.children[0]
          player_link = "https://www.baseball-reference.com#{name_link['href']}"
          player_info = download_document(player_link)
          next unless player_info
          player_data = player_info.css('#meta')
          player_data = player_data.text.squish
          if flag < 2
            index = player_data.index('Bats: ')
            batters.push({'name' => player_name.text, 'hand' => player_data[index + 6]})
          else
            index = player_data.index('Throws: ')
            pitchers.push({'name' => player_name.text, 'hand' => player_data[index + 8]})
          end
        end
      end

      url = "http://www.espn.com/mlb/playbyplay?gameId=#{game.game_id}"
      puts url

      doc = download_document(url)
      next unless doc

      lines = doc.css("#allPlays .headline")
      pitcher_flag = "l"
      batter_flag = "r"

      result = {
        'll_ab' => 0,
        'll_h' => 0,
        'll_bb' => 0,
        'll_hr' => 0,
        'll_k' => 0,
        'lr_ab' => 0,
        'lr_h' => 0,
        'lr_bb' => 0,
        'lr_hr' => 0,
        'lr_k' => 0,
        'rl_ab' => 0,
        'rl_h' => 0,
        'rl_bb' => 0,
        'rl_hr' => 0,
        'rl_k' => 0,
        'rr_ab' => 0,
        'rr_h' => 0,
        'rr_bb' => 0,
        'rr_hr' => 0,
        'rr_k' => 0
      }

      lines.each do |line|
        line_string = line.text.squish
        line_string = line_string.gsub('á', 'a')
        line_string = line_string.gsub('í', 'i')
        line_string = line_string.gsub('é', 'e')
        line_string = line_string.gsub('ñ', 'n')
        line_string = line_string.gsub('ó', 'o')
        line_string = line_string.gsub('ú', 'u')
        next if line_string.length == 0
        name = line_string.split(' ')[0]
        name = line_string.split(' ')[1] if name[-1] == '.' || name.length < 3
        next if name == nil
        check_pitcher = pitchers.select {|player| player['name'].include?(name)}
        check_batter = batters.select {|player| player['name'].include?(name)}
        if check_pitcher.length != 0
          pitcher_flag = check_pitcher[0]['hand'].downcase
        elsif check_batter.length != 0
          batter_flag = check_batter[0]['hand'].downcase
          flag = batter_flag + pitcher_flag
          if batter_flag == 'b'
            flag = (pitcher_flag == 'l' ? 'rl' : 'lr')
          elsif pitcher_flag == 'b'
            flag = (batter_flag == 'r' ? 'rl' : 'lr')
          end
          if line_string.include?("homered to")
            result[flag + '_hr'] += 1
            result[flag + '_ab'] += 1
            result[flag + '_h'] += 1
          elsif line_string.include?("singled to") || line_string.include?("bunt hit") ||line_string.include?("doubled to") ||line_string.include?("tripled to")
            result[flag + '_ab'] += 1
            result[flag + '_h'] += 1
          elsif line_string.include?("struck out")
            result[flag + '_ab'] += 1
            result[flag + '_k'] += 1
          elsif line_string.include?("out")
            result[flag + '_ab'] += 1
          elsif line_string.include?("walked")
            result[flag + '_bb'] += 1
          end
        else
          puts name + " does not exist"
        end
      end

      game.update(
        ll_ab: result['ll_ab'],
        ll_h: result['ll_h'],
        ll_bb: result['ll_bb'],
        ll_hr: result['ll_hr'],
        ll_k: result['ll_k'],
        lr_ab: result['lr_ab'],
        lr_h: result['lr_h'],
        lr_bb: result['lr_bb'],
        lr_hr: result['lr_hr'],
        lr_k: result['lr_k'],
        rl_ab: result['rl_ab'],
        rl_h: result['rl_h'],
        rl_bb: result['rl_bb'],
        rl_hr: result['rl_hr'],
        rl_k: result['rl_k'],
        rr_ab: result['rr_ab'],
        rr_h: result['rr_h'],
        rr_bb: result['rr_bb'],
        rr_hr: result['rr_hr'],
        rr_k: result['rr_k']
      )
    end
  end


  task :weather_first_game => :environment do
    include GetHtml
    weather_firsts = Newworkbook.where('hits1 is null')
    weather_firsts.each do |weather_first|
      game_date = Date.strptime(weather_first.Date, "%m/%d/%y")
      game_date = game_date.strftime("%F")
      url = "https://www.baseball-reference.com/boxes/?date=#{game_date}"
      puts url
      doc = download_document(url)
      next unless doc
      doc.xpath('//comment()').each {|comment| comment.replace(comment.text)}
      trs = doc.css(".game_summary table:first-child tbody")
      away_team_data = weather_first.Away_Team
      home_team_data = weather_first.Home_Team
      away_score_data = weather_first.A1.to_i + weather_first.A2.to_i + weather_first.A3.to_i + weather_first.a4.to_i + weather_first.a5.to_i + weather_first.a6.to_i + weather_first.a7.to_i + weather_first.a8.to_i + weather_first.a9.to_i
      home_score_data = weather_first.h1.to_i + weather_first.h2.to_i + weather_first.h3.to_i + weather_first.h4.to_i + weather_first.h5.to_i + weather_first.h6.to_i + weather_first.h7.to_i + weather_first.h8.to_i + weather_first.h9.to_i
      trs.each do |slice|
        away_team = slice.children[1].children[1].children[0].text
        home_team = slice.children[3].children[1].children[0].text
        away_score = slice.children[1].children[3].text.to_i
        home_score = slice.children[3].children[3].text.to_i
        if away_team.include?(away_team_data) && home_team.include?(home_team_data)
          game_id = slice.children[1].children[5].children[1]['href']
          url = "https://www.baseball-reference.com#{game_id}"
          doc = download_document(url)
          next unless doc
          doc.xpath('//comment()').each {|comment| comment.replace(comment.text)}
          elements = doc.css("#all_play_by_play tbody tr")
          index = 0
          home_runs = 0
          hits = 0
          elements.each do |element|
            if element.children.length == 12
              if element.children[11].text.include?("Home Run")
                home_runs += 1
              end
            end
            next unless element['class']
            if element['class'].include?("pbp_summary_bottom")
              row_number = ((index + 2) / 2).to_i
              score_string = element.children[9].text
              score_string_end = score_string.rindex(" hit")
              score_string_start = score_string.rindex(",", score_string_end)
              hits += score_string[score_string_start + 1..score_string_end - 1].to_i
              index = index + 1
              if index % 2 == 0
                if row_number === 1
                  weather_first.update(hits1: hits, home_runs1: home_runs)
                elsif row_number === 2
                  weather_first.update(hits2: hits, home_runs2: home_runs)
                elsif row_number === 3
                  weather_first.update(hits3: hits, home_runs3: home_runs)
                elsif row_number === 4
                  weather_first.update(hits4: hits, home_runs4: home_runs)
                elsif row_number === 5
                  weather_first.update(hits5: hits, home_runs5: home_runs)
                elsif row_number === 6
                  weather_first.update(hits6: hits, home_runs6: home_runs)
                elsif row_number === 7
                  weather_first.update(hits7: hits, home_runs7: home_runs)
                elsif row_number === 8
                  weather_first.update(hits8: hits, home_runs8: home_runs)
                elsif row_number === 9
                  weather_first.update(hits9: hits, home_runs9: home_runs)
                end
                hits = 0
                home_runs = 0
              end
            end
          end
          break
        end
      end
    end
  end

  task add: :environment do
    require 'csv'

    filename = File.join Rails.root, 'csv', "Workbook.csv"
    CSV.foreach(filename, headers: true) do |row|
      workbook = row.to_h
      workbook['table'] = 'Workbook'
      if row['Away_Total']
        line_index = row['Away_Total'].index(' ')
        workbook['total_line'] = line_index ? row['Away_Total'][0..line_index - 1] : ''
      end
      Workbook.create(workbook)
    end

    filename = File.join Rails.root, 'csv', "colo.csv"
    CSV.foreach(filename, headers: true) do |row|
      workbook = row.to_h
      workbook['table'] = "colo"
      if row['Away_Total']
        line_index = row['Away_Total'].index(' ')
        workbook['total_line'] = line_index ? row['Away_Total'][0..line_index - 1] : ''
      end
      Workbook.create(workbook)
    end

    filename = File.join Rails.root, 'csv', "houston.csv"
    CSV.foreach(filename, headers: true) do |row|
      workbook = row.to_h
      workbook['table'] = "houston"
      if row['Away_Total']
        line_index = row['Away_Total'].index(' ')
        workbook['total_line'] = line_index ? row['Away_Total'][0..line_index - 1] : ''
      end
      Workbook.create(workbook)
    end

    filename = File.join Rails.root, 'csv', "tampa.csv"
    CSV.foreach(filename, headers: true) do |row|
      workbook = row.to_h
      workbook['table'] = "tampa"
      if row['Away_Total']
        line_index = row['Away_Total'].index(' ')
        workbook['total_line'] = line_index ? row['Away_Total'][0..line_index - 1] : ''
      end
      Workbook.create(workbook)
    end

    filename = File.join Rails.root, 'csv', "colowind.csv"
    CSV.foreach(filename, headers: true) do |row|
      workbook = row.to_h
      workbook['table'] = "colowind"
      if row['Away_Total']
        line_index = row['Away_Total'].index(' ')
        workbook['total_line'] = line_index ? row['Away_Total'][0..line_index - 1] : ''
      end
      Workbook.create(workbook)
    end

    filename = File.join Rails.root, 'csv', "wind.csv"
    CSV.foreach(filename, headers: true) do |row|
      workbook = row.to_h
      workbook['table'] = "wind"
      if row['Away_Total']
        line_index = row['Away_Total'].index(' ')
        workbook['total_line'] = line_index ? row['Away_Total'][0..line_index - 1] : ''
      end
      Workbook.create(workbook)
    end
  end

  task :workbookUpdate => :environment do
    games = Workbook.where("hits1 is null")
    games.each do |game|
      game_date = game.Date
      game_date = game_date[0..-5] + game_date[-2..-1]
      newworkbook = Newworkbook.where(Away_Team: game.Away_Team, Home_Team: game.Home_Team, Date: game_date, Time: game.Time).first
      if newworkbook
        game.update(hits1: newworkbook.hits1,
                    hits2: newworkbook.hits2,
                    hits3: newworkbook.hits3,
                    hits4: newworkbook.hits4,
                    hits5: newworkbook.hits5,
                    hits6: newworkbook.hits6,
                    hits7: newworkbook.hits7,
                    hits8: newworkbook.hits8,
                    hits9: newworkbook.hits9,
                    home_runs1: newworkbook.home_runs1,
                    home_runs2: newworkbook.home_runs2,
                    home_runs3: newworkbook.home_runs3,
                    home_runs4: newworkbook.home_runs4,
                    home_runs5: newworkbook.home_runs5,
                    home_runs6: newworkbook.home_runs6,
                    home_runs7: newworkbook.home_runs7,
                    home_runs8: newworkbook.home_runs8,
                    home_runs9: newworkbook.home_runs9)
      end
    end
  end

  task :workbookGame => :environment do
    include GetHtml
    weather_firsts = Workbook.where('hits1 is null')
    weather_firsts.each do |weather_first|
      game_date = Date.strptime(weather_first.Date, "%m/%d/%Y")
      game_date = game_date.strftime("%F")
      url = "https://www.baseball-reference.com/boxes/?date=#{game_date}"
      puts url
      doc = download_document(url)
      next unless doc
      doc.xpath('//comment()').each {|comment| comment.replace(comment.text)}
      trs = doc.css(".game_summary table:first-child tbody")
      away_team_data = weather_first.Away_Team
      home_team_data = weather_first.Home_Team
      away_score_data = weather_first.A1.to_i + weather_first.A2.to_i + weather_first.A3.to_i + weather_first.a4.to_i + weather_first.a5.to_i + weather_first.a6.to_i + weather_first.a7.to_i + weather_first.a8.to_i + weather_first.a9.to_i
      home_score_data = weather_first.h1.to_i + weather_first.h2.to_i + weather_first.h3.to_i + weather_first.h4.to_i + weather_first.h5.to_i + weather_first.h6.to_i + weather_first.h7.to_i + weather_first.h8.to_i + weather_first.h9.to_i
      trs.each do |slice|
        away_team = slice.children[1].children[1].children[0].text
        home_team = slice.children[3].children[1].children[0].text
        away_score = slice.children[1].children[3].text.to_i
        home_score = slice.children[3].children[3].text.to_i
        if away_team.include?(away_team_data) && home_team.include?(home_team_data)
          game_id = slice.children[1].children[5].children[1]['href']
          url = "https://www.baseball-reference.com#{game_id}"
          doc = download_document(url)
          next unless doc
          doc.xpath('//comment()').each {|comment| comment.replace(comment.text)}
          elements = doc.css("#all_play_by_play tbody tr")
          index = 0
          home_runs = 0
          hits = 0
          elements.each do |element|
            if element.children.length == 12
              if element.children[11].text.include?("Home Run")
                home_runs += 1
              end
            end
            next unless element['class']
            if element['class'].include?("pbp_summary_bottom")
              row_number = ((index + 2) / 2).to_i
              score_string = element.children[9].text
              score_string_end = score_string.rindex(" hit")
              score_string_start = score_string.rindex(",", score_string_end)
              hits += score_string[score_string_start + 1..score_string_end - 1].to_i
              index = index + 1
              if index % 2 == 0
                if row_number === 1
                  weather_first.update(hits1: hits, home_runs1: home_runs)
                elsif row_number === 2
                  weather_first.update(hits2: hits, home_runs2: home_runs)
                elsif row_number === 3
                  weather_first.update(hits3: hits, home_runs3: home_runs)
                elsif row_number === 4
                  weather_first.update(hits4: hits, home_runs4: home_runs)
                elsif row_number === 5
                  weather_first.update(hits5: hits, home_runs5: home_runs)
                elsif row_number === 6
                  weather_first.update(hits6: hits, home_runs6: home_runs)
                elsif row_number === 7
                  weather_first.update(hits7: hits, home_runs7: home_runs)
                elsif row_number === 8
                  weather_first.update(hits8: hits, home_runs8: home_runs)
                elsif row_number === 9
                  weather_first.update(hits9: hits, home_runs9: home_runs)
                end
                hits = 0
                home_runs = 0
              end
            end
          end
          break
        end
      end
    end
  end

  task :workbookHits => :environment do
    include GetHtml
    games = Workbook.where('"t_HRS" is null')
    puts games.count
    games.each do |game|
      t_HITS_SUM = game.hits5.to_i
      t_HRS_SUM = game.home_runs5.to_i
      if ((game.id >= 311826 && game.id <= 337437) ||
          (game.id >= 363736 && game.id <= 364883) ||
          (game.id >= 366037 && game.id <= 367266) ||
          (game.id >= 368491 && game.id <= 369606) ||
          (game.id >= 370722 && game.id <= 371869) ||
          (game.id >= 373023 && game.id <= 400400))
        t_HITS_SUM += game.hits2.to_i + game.hits3.to_i + game.hits4.to_i
        t_HRS_SUM += game.home_runs2.to_i + game.home_runs3.to_i + game.home_runs4.to_i
      end
      if ((game.id >= 337438 && game.id <= 363735) ||
          (game.id >= 364884 && game.id <= 366036) ||
          (game.id >= 367267 && game.id <= 368490) ||
          (game.id >= 369607 && game.id <= 370721) ||
          (game.id >= 371870 && game.id <= 373022) ||
          (game.id >= 400401))
        t_HITS_SUM += game.hits6.to_i + game.hits7.to_i + game.hits8.to_i
        t_HRS_SUM += game.home_runs6.to_i + game.home_runs7.to_i + game.home_runs8.to_i
      end
      t_HITS = t_HITS_SUM.to_f / 4 * 9
      t_HRS = t_HRS_SUM.to_f / 4 * 9
      game.update(t_HITS_SUM: t_HITS_SUM, t_HRS_SUM: t_HRS_SUM, t_HITS: t_HITS, t_HRS: t_HRS)
    end
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
    index = {away_team: 0, home_team: 1, result: 2}
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
            opposite_team_name_end = opposite_team_link.index('/', opposite_team_name_start + 5)
            opposite_team_name = opposite_team_link[opposite_team_name_start + 5..opposite_team_name_end - 1]
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
            game_id = game_link[game_index_start + 1..-1]

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
      size = element[1].children.size / 2

      away_score_first = element[1].children[3].text.squish
      away_score_second = element[1].children[5].text.squish
      away_score_third = element[1].children[7].text.squish
      away_score_forth = element[1].children[9].text.squish
      away_score_fifth = element[1].children[11].text.squish
      away_score_sixth = element[1].children[13].text.squish
      away_score_seventh = element[1].children[15].text.squish
      away_score_eighth = element[1].children[17].text.squish
      away_score_nineth = element[1].children[19].text.squish
      away_score_tenth = element[1].children[size * 2 - 5].text.squish

      home_score_first = element[2].children[3].text.squish
      home_score_second = element[2].children[5].text.squish
      home_score_third = element[2].children[7].text.squish
      home_score_forth = element[2].children[9].text.squish
      home_score_fifth = element[2].children[11].text.squish
      home_score_sixth = element[2].children[13].text.squish
      home_score_seventh = element[2].children[15].text.squish
      home_score_eighth = element[2].children[17].text.squish
      home_score_nineth = element[2].children[19].text.squish
      home_score_tenth = element[2].children[size * 2 - 5].text.squish

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
        home_name = home_name_index ? home_name[0..home_name_index - 1].downcase : home_name.downcase

        away_name_index = away_name.index(' -')
        away_name = away_name_index ? away_name[0..away_name_index - 1].downcase : away_name.downcase

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

  task old: :environment do
    url = "https://classic.sportsbookreview.com/betting-odds/mlb-baseball/"
    puts url
    doc = Nokogiri::HTML(open(url))
    doc.css(".team-name a").each_with_index do |stat, index|
      if index%2 == 1
        puts stat.child.text[0...-3].to_s
      end
    end
    doc.css(".eventLine-opener div").each_with_index do |stat, index|
      if index%2 == 0
        puts stat.text
      else
        puts stat.text
      end
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
        home_name = home_name_index ? home_name[0..home_name_index - 1].downcase : home_name.downcase

        away_name_index = away_name.index(' -')
        away_name = away_name_index ? away_name[0..away_name_index - 1].downcase : away_name.downcase

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
      away_total = away_pitcher.children[away_pitcher_size - 1].children[0]
      home_total = home_pitcher.children[home_pitcher_size - 1].children[0]
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
            eachb_index = eachb[eachb_index - 1].to_i
            eachb_index = 1 if eachb_index == 0
            away_twob_total = away_twob_total + eachb_index
          end
        end
        if batter.children[0].text == '3B:'
          b = batter.children[1].text.split(';')
          b.each do |eachb|
            eachb_index = eachb.index(' (')
            eachb_index = eachb[eachb_index - 1].to_i
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
            eachb_index = eachb[eachb_index - 1].to_i
            eachb_index = 1 if eachb_index == 0
            home_twob_total = home_twob_total + eachb_index
          end
        end
        if batter.children[0].text == '3B:'
          b = batter.children[1].text.split(';')
          b.each do |eachb|
            eachb_index = eachb.index(' (')
            eachb_index = eachb[eachb_index - 1].to_i
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
      away_first_name = away_full_name[0..away_name_index - 1]
      away_last_name = away_full_name[away_name_index + 1..-1]
      away_starter_info = doc.css('.general-info')
      away_starter_hand = ''
      if away_starter_info.children.size > 2
        away_starter_info = away_starter_info.children[1].text
        away_starter_info_index = away_starter_info.index('Throws: ')
        away_starter_hand = away_starter_info[away_starter_info_index + 8]
      end

      home_starter = home_pitcher.children[1].children[0].children[0].children[0]['href']
      doc = download_document(home_starter)
      home_full_name = doc.css('h1').first.text
      home_name_index = home_full_name.rindex(' ')
      home_first_name = home_full_name[0..home_name_index - 1]
      home_last_name = home_full_name[home_name_index + 1..-1]
      home_starter_info = doc.css('.general-info')
      home_starter_hand = ''
      if home_starter_info.children.size > 2
        home_starter_info = home_starter_info.children[1].text
        home_starter_info_index = home_starter_info.index('Throws: ')
        home_starter_hand = home_starter_info[home_starter_info_index + 8]
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

  task pitchers: :environment do
    include GetHtml
    games = Result.where("home_pitcher_name is null")
    games.each do |game|
      url = "http://www.espn.com/mlb/boxscore?gameId=#{game.game_id}"
      puts url
      doc = download_document(url)
      next unless doc

      pitchers = doc.css('.stats-wrap')
      next if pitchers.size < 4
      away_pitcher = pitchers[1]
      home_pitcher = pitchers[3]
      away_pitcher_size = away_pitcher.children.size
      home_pitcher_size = home_pitcher.children.size
      next if away_pitcher_size == 3 && away_pitcher.children[1].children[0].children.size == 1
      next if home_pitcher_size == 3 && home_pitcher.children[1].children[0].children.size == 1

      away_pitcher_link = away_pitcher.children[1].children[0].children[0].children[0]['href']
      away_pitcher_name = away_pitcher.children[1].children[0].children[0].children[0].text.squish
      away_pitcher_ip = away_pitcher.children[1].children[0].children[1].text.squish
      away_pitcher_h = away_pitcher.children[1].children[0].children[2].text.squish
      away_pitcher_r = away_pitcher.children[1].children[0].children[3].text.squish
      away_pitcher_bb = away_pitcher.children[1].children[0].children[5].text.squish

      home_pitcher_link = home_pitcher.children[1].children[0].children[0].children[0]['href']
      home_pitcher_name = home_pitcher.children[1].children[0].children[0].children[0].text.squish
      home_pitcher_ip = home_pitcher.children[1].children[0].children[1].text.squish
      home_pitcher_h = home_pitcher.children[1].children[0].children[2].text.squish
      home_pitcher_r = home_pitcher.children[1].children[0].children[3].text.squish
      home_pitcher_bb = home_pitcher.children[1].children[0].children[5].text.squish

      game.update(away_pitcher_link: away_pitcher_link,
                  away_pitcher_name: away_pitcher_name,
                  away_pitcher_ip: away_pitcher_ip,
                  away_pitcher_h: away_pitcher_h,
                  away_pitcher_r: away_pitcher_r,
                  away_pitcher_bb: away_pitcher_bb,
                  home_pitcher_link: home_pitcher_link,
                  home_pitcher_name: home_pitcher_name,
                  home_pitcher_ip: home_pitcher_ip,
                  home_pitcher_h: home_pitcher_h,
                  home_pitcher_r: home_pitcher_r,
                  home_pitcher_bb: home_pitcher_bb)
    end
  end

  task update_pitcher_value: :environment do
    include GetHtml
    games = Result.where("home_pitcher_game_first_ip is null")
    games.each do |game|
      away_pitcher = game.away_pitcher_link
      away_previous_games = Result.where("away_pitcher_link = ? AND game_date < ?", away_pitcher, game.game_date).or(Result.where("home_pitcher_link = ? AND game_date < ?", away_pitcher, game.game_date)).order('game_date DESC').limit(30)

      away_pitcher_game_first_ip = []
      away_pitcher_game_first_bb = 0
      away_pitcher_game_first_h = 0
      away_pitcher_game_first_r = 0
      away_pitcher_game_second_ip = []
      away_pitcher_game_second_bb = 0
      away_pitcher_game_second_h = 0
      away_pitcher_game_second_r = 0

      away_pitcher_game_opp_first_ip = []
      away_pitcher_game_opp_first_bb = 0
      away_pitcher_game_opp_first_h = 0
      away_pitcher_game_opp_first_r = 0
      away_pitcher_game_opp_second_ip = []
      away_pitcher_game_opp_second_bb = 0
      away_pitcher_game_opp_second_h = 0
      away_pitcher_game_opp_second_r = 0

      away_previous_games.each_with_index do |element, index|
        if element.away_pitcher_link == game.away_pitcher_link
          if index < 15
            away_pitcher_game_first_ip.push(element.away_pitcher_ip)
            away_pitcher_game_first_bb = away_pitcher_game_first_bb + element.away_pitcher_bb
            away_pitcher_game_first_h = away_pitcher_game_first_h + element.away_pitcher_h
            away_pitcher_game_first_r = away_pitcher_game_first_r + element.away_pitcher_r
            away_pitcher_game_opp_first_ip.push(element.home_pitcher_ip)
            away_pitcher_game_opp_first_bb = away_pitcher_game_opp_first_bb + element.home_pitcher_bb
            away_pitcher_game_opp_first_h = away_pitcher_game_opp_first_h + element.home_pitcher_h
            away_pitcher_game_opp_first_r = away_pitcher_game_opp_first_r + element.home_pitcher_r
          else
            away_pitcher_game_second_ip.push(element.away_pitcher_ip)
            away_pitcher_game_second_bb = away_pitcher_game_second_bb + element.away_pitcher_bb
            away_pitcher_game_second_h = away_pitcher_game_second_h + element.away_pitcher_h
            away_pitcher_game_second_r = away_pitcher_game_second_r + element.away_pitcher_r
            away_pitcher_game_opp_second_ip.push(element.home_pitcher_ip)
            away_pitcher_game_opp_second_bb = away_pitcher_game_opp_second_bb + element.home_pitcher_bb
            away_pitcher_game_opp_second_h = away_pitcher_game_opp_second_h + element.home_pitcher_h
            away_pitcher_game_opp_second_r = away_pitcher_game_opp_second_r + element.home_pitcher_r
          end
        else
          if index < 15
            away_pitcher_game_first_ip.push(element.home_pitcher_ip)
            away_pitcher_game_first_bb = away_pitcher_game_first_bb + element.home_pitcher_bb
            away_pitcher_game_first_h = away_pitcher_game_first_h + element.home_pitcher_h
            away_pitcher_game_first_r = away_pitcher_game_first_r + element.home_pitcher_r
            away_pitcher_game_opp_first_ip.push(element.away_pitcher_ip)
            away_pitcher_game_opp_first_bb = away_pitcher_game_opp_first_bb + element.away_pitcher_bb
            away_pitcher_game_opp_first_h = away_pitcher_game_opp_first_h + element.away_pitcher_h
            away_pitcher_game_opp_first_r = away_pitcher_game_opp_first_r + element.away_pitcher_r
          else
            away_pitcher_game_second_ip.push(element.home_pitcher_ip)
            away_pitcher_game_second_bb = away_pitcher_game_second_bb + element.home_pitcher_bb
            away_pitcher_game_second_h = away_pitcher_game_second_h + element.home_pitcher_h
            away_pitcher_game_second_r = away_pitcher_game_second_r + element.home_pitcher_r
            away_pitcher_game_opp_second_ip.push(element.away_pitcher_ip)
            away_pitcher_game_opp_second_bb = away_pitcher_game_opp_second_bb + element.away_pitcher_bb
            away_pitcher_game_opp_second_h = away_pitcher_game_opp_second_h + element.away_pitcher_h
            away_pitcher_game_opp_second_r = away_pitcher_game_opp_second_r + element.away_pitcher_r
          end
        end
      end

      home_pitcher = game.home_pitcher_link
      home_previous_games = Result.where("home_pitcher_link = ? AND game_date < ?", home_pitcher, game.game_date).or(Result.where("away_pitcher_link = ? AND game_date < ?", home_pitcher, game.game_date)).order('game_date DESC').limit(30)

      home_pitcher_game_first_ip = []
      home_pitcher_game_first_bb = 0
      home_pitcher_game_first_h = 0
      home_pitcher_game_first_r = 0
      home_pitcher_game_second_ip = []
      home_pitcher_game_second_bb = 0
      home_pitcher_game_second_h = 0
      home_pitcher_game_second_r = 0

      home_pitcher_game_opp_first_ip = []
      home_pitcher_game_opp_first_bb = 0
      home_pitcher_game_opp_first_h = 0
      home_pitcher_game_opp_first_r = 0
      home_pitcher_game_opp_second_ip = []
      home_pitcher_game_opp_second_bb = 0
      home_pitcher_game_opp_second_h = 0
      home_pitcher_game_opp_second_r = 0

      home_previous_games.each_with_index do |element, index|
        if element.away_pitcher_link == game.home_pitcher_link
          if index < 15
            home_pitcher_game_first_ip.push(element.away_pitcher_ip)
            home_pitcher_game_first_bb = home_pitcher_game_first_bb + element.away_pitcher_bb
            home_pitcher_game_first_h = home_pitcher_game_first_h + element.away_pitcher_h
            home_pitcher_game_first_r = home_pitcher_game_first_r + element.away_pitcher_r
            home_pitcher_game_opp_first_ip.push(element.home_pitcher_ip)
            home_pitcher_game_opp_first_bb = home_pitcher_game_opp_first_bb + element.home_pitcher_bb
            home_pitcher_game_opp_first_h = home_pitcher_game_opp_first_h + element.home_pitcher_h
            home_pitcher_game_opp_first_r = home_pitcher_game_opp_first_r + element.home_pitcher_r
          else
            home_pitcher_game_second_ip.push(element.away_pitcher_ip)
            home_pitcher_game_second_bb = home_pitcher_game_second_bb + element.away_pitcher_bb
            home_pitcher_game_second_h = home_pitcher_game_second_h + element.away_pitcher_h
            home_pitcher_game_second_r = home_pitcher_game_second_r + element.away_pitcher_r
            home_pitcher_game_opp_second_ip.push(element.home_pitcher_ip)
            home_pitcher_game_opp_second_bb = home_pitcher_game_opp_second_bb + element.home_pitcher_bb
            home_pitcher_game_opp_second_h = home_pitcher_game_opp_second_h + element.home_pitcher_h
            home_pitcher_game_opp_second_r = home_pitcher_game_opp_second_r + element.home_pitcher_r
          end
        else
          if index < 15
            home_pitcher_game_first_ip.push(element.home_pitcher_ip)
            home_pitcher_game_first_bb = home_pitcher_game_first_bb + element.home_pitcher_bb
            home_pitcher_game_first_h = home_pitcher_game_first_h + element.home_pitcher_h
            home_pitcher_game_first_r = home_pitcher_game_first_r + element.home_pitcher_r
            home_pitcher_game_opp_first_ip.push(element.away_pitcher_ip)
            home_pitcher_game_opp_first_bb = home_pitcher_game_opp_first_bb + element.away_pitcher_bb
            home_pitcher_game_opp_first_h = home_pitcher_game_opp_first_h + element.away_pitcher_h
            home_pitcher_game_opp_first_r = home_pitcher_game_opp_first_r + element.away_pitcher_r
          else
            home_pitcher_game_second_ip.push(element.home_pitcher_ip)
            home_pitcher_game_second_bb = home_pitcher_game_second_bb + element.home_pitcher_bb
            home_pitcher_game_second_h = home_pitcher_game_second_h + element.home_pitcher_h
            home_pitcher_game_second_r = home_pitcher_game_second_r + element.home_pitcher_r
            home_pitcher_game_opp_second_ip.push(element.away_pitcher_ip)
            home_pitcher_game_opp_second_bb = home_pitcher_game_opp_second_bb + element.away_pitcher_bb
            home_pitcher_game_opp_second_h = home_pitcher_game_opp_second_h + element.away_pitcher_h
            home_pitcher_game_opp_second_r = home_pitcher_game_opp_second_r + element.away_pitcher_r
          end
        end
      end
      game.update(
          home_pitcher_game_first_ip: add_innings(home_pitcher_game_first_ip),
          home_pitcher_game_first_bb: home_pitcher_game_first_bb,
          home_pitcher_game_first_h: home_pitcher_game_first_h,
          home_pitcher_game_first_r: home_pitcher_game_first_r,
          home_pitcher_game_second_ip: add_innings(home_pitcher_game_second_ip),
          home_pitcher_game_second_bb: home_pitcher_game_second_bb,
          home_pitcher_game_second_h: home_pitcher_game_second_h,
          home_pitcher_game_second_r: home_pitcher_game_second_r,
          home_pitcher_game_opp_first_ip: add_innings(home_pitcher_game_opp_first_ip),
          home_pitcher_game_opp_first_bb: home_pitcher_game_opp_first_bb,
          home_pitcher_game_opp_first_h: home_pitcher_game_opp_first_h,
          home_pitcher_game_opp_first_r: home_pitcher_game_opp_first_r,
          home_pitcher_game_opp_second_ip: add_innings(home_pitcher_game_opp_second_ip),
          home_pitcher_game_opp_second_bb: home_pitcher_game_opp_second_bb,
          home_pitcher_game_opp_second_h: home_pitcher_game_opp_second_h,
          home_pitcher_game_opp_second_r: home_pitcher_game_opp_second_r,

          away_pitcher_game_first_ip: add_innings(away_pitcher_game_first_ip),
          away_pitcher_game_first_bb: away_pitcher_game_first_bb,
          away_pitcher_game_first_h: away_pitcher_game_first_h,
          away_pitcher_game_first_r: away_pitcher_game_first_r,
          away_pitcher_game_second_ip: add_innings(away_pitcher_game_second_ip),
          away_pitcher_game_second_bb: away_pitcher_game_second_bb,
          away_pitcher_game_second_h: away_pitcher_game_second_h,
          away_pitcher_game_second_r: away_pitcher_game_second_r,
          away_pitcher_game_opp_first_ip: add_innings(away_pitcher_game_opp_first_ip),
          away_pitcher_game_opp_first_bb: away_pitcher_game_opp_first_bb,
          away_pitcher_game_opp_first_h: away_pitcher_game_opp_first_h,
          away_pitcher_game_opp_first_r: away_pitcher_game_opp_first_r,
          away_pitcher_game_opp_second_ip: add_innings(away_pitcher_game_opp_second_ip),
          away_pitcher_game_opp_second_bb: away_pitcher_game_opp_second_bb,
          away_pitcher_game_opp_second_h: away_pitcher_game_opp_second_h,
          away_pitcher_game_opp_second_r: away_pitcher_game_opp_second_r
      )
    end
  end

  task update_pitcher_value_check: :environment do
    include GetHtml
    games = Result.where("id = 29186")
    games.each do |game|
      away_pitcher = game.away_pitcher_link
      away_previous_games = Result.where("away_pitcher_link = ? AND game_date < ?", away_pitcher, game.game_date).or(Result.where("home_pitcher_link = ? AND game_date < ?", away_pitcher, game.game_date)).order(:game_date).limit(30)

      away_pitcher_game_first_ip = []
      away_pitcher_game_first_bb = 0
      away_pitcher_game_first_h = 0
      away_pitcher_game_first_r = 0
      away_pitcher_game_second_ip = []
      away_pitcher_game_second_bb = 0
      away_pitcher_game_second_h = 0
      away_pitcher_game_second_r = 0

      away_pitcher_game_opp_first_ip = []
      away_pitcher_game_opp_first_bb = 0
      away_pitcher_game_opp_first_h = 0
      away_pitcher_game_opp_first_r = 0
      away_pitcher_game_opp_second_ip = []
      away_pitcher_game_opp_second_bb = 0
      away_pitcher_game_opp_second_h = 0
      away_pitcher_game_opp_second_r = 0

      away_previous_games.each_with_index do |element, index|
        if element.away_pitcher_link == game.away_pitcher_link
          puts element.away_pitcher_ip
          if index < 15
            away_pitcher_game_first_ip.push(element.away_pitcher_ip)
            away_pitcher_game_first_bb = away_pitcher_game_first_bb + element.away_pitcher_bb
            away_pitcher_game_first_h = away_pitcher_game_first_h + element.away_pitcher_h
            away_pitcher_game_first_r = away_pitcher_game_first_r + element.away_pitcher_r
            away_pitcher_game_opp_first_ip.push(element.home_pitcher_ip)
            away_pitcher_game_opp_first_bb = away_pitcher_game_opp_first_bb + element.home_pitcher_bb
            away_pitcher_game_opp_first_h = away_pitcher_game_opp_first_h + element.home_pitcher_h
            away_pitcher_game_opp_first_r = away_pitcher_game_opp_first_r + element.home_pitcher_r
          else
            away_pitcher_game_second_ip.push(element.away_pitcher_ip)
            away_pitcher_game_second_bb = away_pitcher_game_second_bb + element.away_pitcher_bb
            away_pitcher_game_second_h = away_pitcher_game_second_h + element.away_pitcher_h
            away_pitcher_game_second_r = away_pitcher_game_second_r + element.away_pitcher_r
            away_pitcher_game_opp_second_ip.push(element.home_pitcher_ip)
            away_pitcher_game_opp_second_bb = away_pitcher_game_opp_second_bb + element.home_pitcher_bb
            away_pitcher_game_opp_second_h = away_pitcher_game_opp_second_h + element.home_pitcher_h
            away_pitcher_game_opp_second_r = away_pitcher_game_opp_second_r + element.home_pitcher_r
          end
        else
          puts element.home_pitcher_ip
          if index < 15
            away_pitcher_game_first_ip.push(element.home_pitcher_ip)
            away_pitcher_game_first_bb = away_pitcher_game_first_bb + element.home_pitcher_bb
            away_pitcher_game_first_h = away_pitcher_game_first_h + element.home_pitcher_h
            away_pitcher_game_first_r = away_pitcher_game_first_r + element.home_pitcher_r
            away_pitcher_game_opp_first_ip.push(element.away_pitcher_ip)
            away_pitcher_game_opp_first_bb = away_pitcher_game_opp_first_bb + element.away_pitcher_bb
            away_pitcher_game_opp_first_h = away_pitcher_game_opp_first_h + element.away_pitcher_h
            away_pitcher_game_opp_first_r = away_pitcher_game_opp_first_r + element.away_pitcher_r
          else
            puts element.home_pitcher_ip
            away_pitcher_game_second_ip.push(element.home_pitcher_ip)
            away_pitcher_game_second_bb = away_pitcher_game_second_bb + element.home_pitcher_bb
            away_pitcher_game_second_h = away_pitcher_game_second_h + element.home_pitcher_h
            away_pitcher_game_second_r = away_pitcher_game_second_r + element.home_pitcher_r
            away_pitcher_game_opp_second_ip.push(element.away_pitcher_ip)
            away_pitcher_game_opp_second_bb = away_pitcher_game_opp_second_bb + element.away_pitcher_bb
            away_pitcher_game_opp_second_h = away_pitcher_game_opp_second_h + element.away_pitcher_h
            away_pitcher_game_opp_second_r = away_pitcher_game_opp_second_r + element.away_pitcher_r
          end
        end
      end
    end
  end

  task update_total_line: :environment do
    workbooks = Workbook.where('total_line is null')
    workbooks.each do |workbook|
      away = @team_uppercase[workbook['Away_Team']]
      total = Total.where('"DATE" = ? AND "AWAY" = ?', workbook['Date'], away).first
      workbook.update(total_line: total['TOTAL']) if total
    end
  end

  @clean = {
      'Los Angeles Angels' => 'Angels',
      'Houston Astros' => 'Astros',
      'Oakland Athletics' => 'Athletics',
      'Toronto Blue Jays' => 'Blue Jays',
      'Atlanta Braves' => 'Braves',
      'Milwaukee Brewers' => 'Brewers',
      'St. Louis Cardinals' => 'Cardinals',
      'Chicago Cubs' => 'Cubs',
      'Arizona Diamondbacks' => 'Diamondbacks',
      'Los Angeles Dodgers' => 'Dodgers',
      'San Francisco Giants' => 'Giants',
      'Cleveland Indians' => 'Indians',
      'Seattle Mariners' => 'Mariners',
      'Miami Marlins' => 'Marlins',
      'New York Mets' => 'Mets',
      'Washington Nationals' => 'Nationals',
      'Baltimore Orioles' => 'Orioles',
      'San Diego Padres' => 'Padres',
      'Philadelphia Phillies' => 'Phillies',
      'Pittsburgh Pirates' => 'Pirates',
      'Texas Rangers' => 'Rangers',
      'Tampa Bay Rays' => 'Rays',
      'Boston Red Sox' => 'Red Sox',
      'Cincinnati Reds' => 'Reds',
      'Colorado Rockies' => 'Rockies',
      'Kansas City Royals' => 'Royals',
      'Detroit Tigers' => 'Tigers',
      'Minnesota Twins' => 'Twins',
      'Chicago White Sox' => 'White Sox',
      'New York Yankees' => 'Yankees'
  }

  @team_uppercase = {
      'Angels' => 'LA ANGELS',
      'Astros' => 'HOUSTON',
      'Athletics' => 'OAKLAND',
      'Blue Jays' => 'TORONTO',
      'Braves' => 'ATLANTA',
      'Brewers' => 'MILWAUKEE',
      'Cardinals' => 'ST LOUIS',
      'Cubs' => 'CHI CUBS',
      'Diamondbacks' => 'ARIZONA',
      'Dodgers' => 'LOS ANGELES',
      'Giants' => 'SAN FRANCISCO',
      'Indians' => 'CLEVELAND',
      'Mariners' => 'SEATTLE',
      'Marlins' => 'MIAMI',
      'Mets' => 'NY METS',
      'Nationals' => 'WASHINGTON',
      'Orioles' => 'BALTIMORE',
      'Padres' => 'SAN DIEGO',
      'Phillies' => 'PHILADELPHIA',
      'Pirates' => 'PITTSBURGH',
      'Rangers' => 'TEXAS',
      'Rays' => 'TAMPA BAY',
      'Red Sox' => 'BOSTON',
      'Reds' => 'CINCINNATI',
      'Rockies' => 'COLORADO',
      'Royals' => 'KANSAS CITY',
      'Tigers' => 'DETROIT',
      'Twins' => 'MINNESOTA',
      'White Sox' => 'CHI WHITE SOX',
      'Yankees' => 'NY YANKEES'
  }

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
      'cws' => 'Chicago White Sox',
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
      'Kansas City, Missouri 64999' => 'https://www.wunderground.com/history/airport/KMKC/year/month/day/DailyHistory.html?req_city=Kansas+City&req_state=MO&req_statename=Missouri&reqdb.zip=64999&reqdb.magic=1&reqdb.wmo=99999',
      'Anaheim, California 92899' => 'https://www.wunderground.com/history/airport/KFUL/year/month/day/DailyHistory.html?req_city=Anaheim&req_state=CA&req_statename=California&reqdb.zip=92801&reqdb.magic=1&reqdb.wmo=99999',
      'Houston, Texas 77299' => 'https://www.wunderground.com/history/airport/KMCJ/year/month/day/DailyHistory.html?req_city=Houston&req_state=TX&req_statename=Texas&reqdb.zip=77299&reqdb.magic=1&reqdb.wmo=99999',
      'Detroit, Michigan 48201' => 'https://www.wunderground.com/history/airport/KDET/year/month/day/DailyHistory.html?req_city=Detroit&req_state=&req_statename=Michigan&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
      'Toronto, Ontario' => 'https://www.wunderground.com/history/airport/CXTO/year/month/day/DailyHistory.html?req_city=Toronto&req_state=&req_statename=Ontario&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
      'Oakland, California 94666' => 'https://www.wunderground.com/history/airport/KOAK/year/month/day/DailyHistory.html?req_city=Oakland&req_state=&req_statename=California&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
      'San Juan, Puerto Rico' => 'https://www.wunderground.com/history/airport/TJSJ/year/month/day/DailyHistory.html?req_city=San+Juan&req_state=&req_statename=Puerto+Rico&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
      'St. Louis, Missouri 63012' => 'https://www.wunderground.com/history/airport/KCPS/year/month/day/DailyHistory.html?req_city=Barnhart&req_state=MO&req_statename=Missouri&reqdb.zip=63012&reqdb.magic=1&reqdb.wmo=99999',
      'Chicago, Illinois 60616' => 'https://www.wunderground.com/history/airport/KORD/year/month/day/DailyHistory.html?req_city=Chicago&req_state=&req_statename=Illinois&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
      'St. Petersburg, Florida 33784' => 'https://www.wunderground.com/history/airport/KSPG/year/month/day/DailyHistory.html?req_city=Saint+Petersburg&req_state=FL&req_statename=Florida&reqdb.zip=33784&reqdb.magic=1&reqdb.wmo=99999',
      'Miami, Florida 33299' => 'https://www.wunderground.com/history/airport/KMIA/year/month/day/DailyHistory.html?req_city=Miami&req_state=&req_statename=Florida&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
      'Boston, Massachusetts 02297' => 'https://www.wunderground.com/history/airport/KBOS/year/month/day/DailyHistory.html?req_city=Boston&req_state=&req_statename=Massachusetts&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
      'Los Angeles, California 90185' => 'https://www.wunderground.com/history/airport/KCQT/year/month/day/DailyHistory.html?req_city=Los+Angeles&req_state=&req_statename=California&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
      'New York, New York 10451' => 'https://www.wunderground.com/history/airport/KNYC/year/month/day/DailyHistory.html?req_city=New+York&req_state=&req_statename=New+York&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
      'Arlington, Texas 76096' => 'https://www.wunderground.com/history/airport/KGPM/year/month/day/DailyHistory.html?req_city=Arlington&req_state=TX&req_statename=Texas&reqdb.zip=76096&reqdb.magic=1&reqdb.wmo=99999',
      'Williamsport, PA' => 'https://www.wunderground.com/history/airport/KIPT/year/month/day/DailyHistory.html?req_city=Williamsport&req_state=&req_statename=Pennsylvania&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
      'San Francisco, California 94188' => 'https://www.wunderground.com/history/airport/KSFO/year/month/day/DailyHistory.html?req_city=San+Francisco&req_state=&req_statename=California&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
      'Baltimore, Maryland 21298' => 'https://www.wunderground.com/history/airport/KDMH/year/month/day/DailyHistory.html?req_city=Baltimore&req_state=MD&req_statename=Maryland&reqdb.zip=21298&reqdb.magic=1&reqdb.wmo=99999',
      'Washington, D.C.' => 'https://www.wunderground.com/history/airport/KDCA/year/month/day/DailyHistory.html?req_city=Washington&req_state=DC&req_statename=District+of+Columbia&reqdb.zip=20001&reqdb.magic=1&reqdb.wmo=99999',
      'Cumberland, GA' => 'https://www.wunderground.com/history/airport/KAHN/year/month/day/DailyHistory.html?req_city=Cumberland&req_state=&req_statename=Georgia&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
      'Washington, D.C. 20003' => 'https://www.wunderground.com/history/airport/KDCA/year/month/day/DailyHistory.html?req_city=Washington&req_state=DC&req_statename=District+of+Columbia&reqdb.zip=20001&reqdb.magic=1&reqdb.wmo=99999',
      'Denver, Colorado 80299' => 'https://www.wunderground.com/history/airport/KBKF/year/month/day/DailyHistory.html?req_city=Denver&req_state=&req_statename=Colorado&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
      'Kissimmee, Florida 34759' => 'https://www.wunderground.com/history/airport/KISM/year/month/day/DailyHistory.html?req_city=Kissimmee&req_state=&req_statename=Florida&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
      'Seattle, Washington 98104' => 'https://www.wunderground.com/history/airport/KBFI/year/month/day/DailyHistory.html?req_city=Seattle&req_state=WA&req_statename=Washington&reqdb.zip=98104&reqdb.magic=1&reqdb.wmo=99999',
      'Bronx, New York 10499' => 'https://www.wunderground.com/history/airport/KLGA/year/month/day/DailyHistory.html?req_city=Bronx&req_state=&req_statename=New+York&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
      'New York, New York 11368' => 'https://www.wunderground.com/history/airport/KLGA/year/month/day/DailyHistory.html?req_city=Corona&req_state=NY&req_statename=New+York&reqdb.zip=11368&reqdb.magic=1&reqdb.wmo=99999',
      'Tokyo, Japan' => 'https://www.wunderground.com/history/airport/RJTD/year/month/day/DailyHistory.html?req_city=Tokyo&req_state=&req_statename=Japan&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
      'Milwaukee, Wisconsin 53295' => 'https://www.wunderground.com/history/airport/KMKE/year/month/day/DailyHistory.html?req_city=Milwaukee&req_state=&req_statename=Wisconsin&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
      'Cleveland, Ohio 44199' => 'https://www.wunderground.com/history/airport/KBKL/year/month/day/DailyHistory.html?req_city=Cleveland&req_state=&req_statename=Ohio&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
      'Phoenix, Arizona 85099' => 'https://www.wunderground.com/history/airport/KPHX/year/month/day/DailyHistory.html?req_city=Phoenix&req_state=&req_statename=Arizona&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
      'Cumberland, NC' => 'https://www.wunderground.com/history/airport/KFAY/year/month/day/DailyHistory.html?req_city=Cumberland&req_state=&req_statename=North+Carolina&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
      'Sydney, New South' => 'https://www.wunderground.com/history/airport/YSSY/year/month/day/DailyHistory.html?req_city=Sydney&req_state=&req_statename=Australia&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
      'Pittsburgh, Pennsylvania 15212' => 'https://www.wunderground.com/history/airport/KAGC/year/month/day/DailyHistory.html?req_city=Pittsburgh&req_state=PA&req_statename=Pennsylvania&reqdb.zip=15212&reqdb.magic=1&reqdb.wmo=99999',
      'Cincinnati, Ohio 45999' => 'https://www.wunderground.com/history/airport/KLUK/year/month/day/DailyHistory.html?req_city=Cincinnati&req_state=OH&req_statename=Ohio&reqdb.zip=45999&reqdb.magic=1&reqdb.wmo=99999',
      'Cumberland, Georgia 39901' => 'https://www.wunderground.com/history/airport/KAHN/year/month/day/DailyHistory.html?req_city=Cumberland&req_state=&req_statename=Georgia&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
      'Philadelphia, Pennsylvania 19255' => 'https://www.wunderground.com/history/airport/KPHL/year/month/day/DailyHistory.html?req_city=Philadelphia&req_state=&req_statename=Pennsylvania&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
      'Chicago, Illinois 60613' => 'https://www.wunderground.com/history/airport/KORD/year/month/day/DailyHistory.html?req_city=Chicago&req_state=&req_statename=Illinois&reqdb.zip=&reqdb.magic=&reqdb.wmo=',
      'Cumberland, GA 30339' => 'https://www.wunderground.com/history/airport/KMGE/year/month/day/DailyHistory.html?req_city=Atlanta&req_state=GA&req_statename=Georgia&reqdb.zip=30339&reqdb.magic=1&reqdb.wmo=99999'
  }


end

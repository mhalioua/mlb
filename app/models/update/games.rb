module Update
  class Games

    include GetHtml

    def update(game_day)
      lines(game_day)
      if game_day == GameDay.search(Time.now)
        umpire(game_day)
      end
      if game_day == GameDay.today || game_day == GameDay.yesterday
        scores(game_day)
      end
    end

    private
    def lines(game_day)
      day_games = game_day.games
      game_size = day_games.size
      date_url = "?date=" + game_day.date.to_formatted_s(:number)
      url = "https://classic.sportsbookreview.com/betting-odds/mlb-baseball/#{date_url}"
      puts url
      doc = Nokogiri::HTML(open(url))
      game_array = Array.new
      doc.css(".team-name a").each_with_index do |stat, index|
        # Break once we find the all teams playing today
        if index == game_size * 2
          break
        end
        if index % 2 == 1
          abbr = stat.child.text.to_s
          abbr = fix_abbr(abbr)
          team = Team.find_by(espn_abbr: abbr)
          add_game_to_array(game_array, day_games, team)
        end
      end

      away_money_line = Array.new
      home_money_line = Array.new
      doc.css(".eventLine-opener div").each_with_index do |stat, index|
        if index == game_size * 2
          break
        end
        if index % 2 == 0
          away_money_line << stat.text
        else
          home_money_line << stat.text
        end
      end

      away_money_line_closer = Array.new
      home_money_line_closer = Array.new
      doc.css(".eventLine-consensus+ .eventLine-book b").each_with_index do |stat, index|
        if index == game_size * 2
          break
        end
        if index % 2 == 0
          away_money_line_closer << stat.text
        else
          home_money_line_closer << stat.text
        end
      end

      away_totals = Array.new
      home_totals = Array.new
      url = "https://classic.sportsbookreview.com/betting-odds/mlb-baseball/totals/" + date_url
      doc = Nokogiri::HTML(open(url))
      doc.css(".eventLine-opener div").each_with_index do |stat, index|
        if index == game_size * 2
          break
        end
        if index % 2 == 0
          away_totals << stat.text
        else
          home_totals << stat.text
        end
      end

      away_totals_closer = Array.new
      home_totals_closer = Array.new
      doc.css(".eventLine-consensus+ .eventLine-book b").each_with_index do |stat, index|
        if index == game_size * 2
          break
        end
        if index % 2 == 0
          away_totals_closer << stat.text
        else
          home_totals_closer << stat.text
        end
      end
      puts game_array.inspect
      puts away_money_line.inspect
      puts home_money_line.inspect
      puts away_money_line_closer.inspect
      puts home_money_line_closer.inspect
      puts away_totals.inspect
      puts home_totals.inspect
      puts away_totals_closer.inspect
      puts home_totals_closer.inspect

      (0...game_size).each do |i|
        game = game_array[i]
        if game
          game.update(away_money_line: away_money_line[i], home_money_line: home_money_line[i], away_total: away_totals[i], home_total: home_totals[i],
                      away_money_line_closer: away_money_line_closer[i], home_money_line_closer: home_money_line_closer[i], away_total_closer: away_totals_closer[i], home_total_closer: home_totals_closer[i])
        end
      end
    end

    def umpire(game_day)
      url = "http://www.statfox.com/mlb/umpiremain.asp"
      doc = download_document(url)
      games = game_day.games
      team_id = var = 0
      doc.css(".datatable a").each do |data|
        var += 1
        if var % 3 == 2
          team_id = data['href']
        elsif var % 3 == 0
          if data.text.size == 3
            var = 1
            next
          end
          ump = data.text
          Umpire.find_or_create_by(statfox: ump, year: 2021)
          Umpire.find_or_create_by(statfox: ump, year: 2020)
          Umpire.find_or_create_by(statfox: ump, year: 2019)
          Umpire.find_or_create_by(statfox: ump, year: 2018)
          Umpire.find_or_create_by(statfox: ump, year: 2017)
          Umpire.find_or_create_by(statfox: ump, year: 2016)
          Umpire.find_or_create_by(statfox: ump, year: 2015)
          team_name = find_team_name(team_id)
          if team = Team.find_by_name(team_name)
            game = games.where("away_team_id = #{team.id} OR home_team_id = #{team.id}").first
            if game
              game.update(ump: ump)
              puts "#{game.game_id} #{ump}"
            end
          end
        end
      end
    end

    def fix_abbr(abbr)
      abbr = abbr.split(' - ')[0]
      case abbr
        when "CWS"
          "CHW"
        else
          abbr
      end
    end

    def scores(game_day)
      games = game_day.games
      games.each do |game|
        url = "http://www.espn.com/mlb/playbyplay?gameId=#{game.game_id}"
        puts url
        doc = Nokogiri::HTML(open(url))
        elements = doc.css('tbody .linescore__item:not(.linescore__teamName)')
        next if elements.length === 0
        elements.each_with_index do |element, index|
          break if index === elements.length / 2
          game_stat = game.game_stats.find_or_create_by(row_number: index + 1)
          game_stat.update(away_score: element.text.squish, home_score: elements.children[index + elements.length / 2].text.squish)
        end
        element_length = doc.css("#allPlaysContainer section").size / 2
        (0..element_length).each do |index|
          top = doc.css("#allPlaysContainer section#allPlaysTop" + (index + 1).to_s + " ul .accordion-item .left")
          bottom = doc.css("#allPlaysContainer section#allPlaysBottom" + (index + 1).to_s + " ul .accordion-item .left")
          home_runs = 0
          top.each do |element|
            string = element.text
            home_runs = home_runs + 1 if string.include?("homered")
          end
          bottom.each do |element|
            string = element.text
            home_runs = home_runs + 1 if string.include?("homered")
          end
          walked = 0
          top.each do |element|
            string = element.text
            walked = walked + 1 if string.include?("walked")
          end
          bottom.each do |element|
            string = element.text
            walked = walked + 1 if string.include?("walked")
          end
          top_hits_string = doc.css("#allPlaysContainer section#allPlaysTop" + (index + 1).to_s + " ul .info-row--footer")
          top_hits_count = 0
          if top_hits_string.length != 0
            top_hits_string = top_hits_string[0].text.squish
            top_hits_string_end = top_hits_string.rindex("Hit")
            top_hits_string_start = top_hits_string.rindex(",", top_hits_string_end)
            top_hits_count = top_hits_string[top_hits_string_start + 1..top_hits_string_end - 1].to_i
          end
          bottom_hits_string = doc.css("#allPlaysContainer section#allPlaysBottom" + (index + 1).to_s + " ul .info-row--footer")
          bottom_hits_count = 0
          if bottom_hits_string.length != 0
            bottom_hits_string = bottom_hits_string[0].text.squish
            bottom_hits_string_end = bottom_hits_string.rindex("Hit")
            bottom_hits_string_start = bottom_hits_string.rindex(",", bottom_hits_string_end)
            bottom_hits_count = bottom_hits_string[bottom_hits_string_start + 1..bottom_hits_string_end - 1].to_i
          end
          hits = top_hits_count + bottom_hits_count
          game_stat = game.game_stats.find_or_create_by(row_number: (index + 1))
          game_stat.update(hits: hits, home_runs: home_runs, walked: walked)
        end
      end
    end

    def add_game_to_array(game_array, day_games, team)
      unless team
        game_array << nil
        return
      end
      games = day_games.where("away_team_id = #{team.id} OR home_team_id = #{team.id}")
      if games.size == 2
        if game_array.include?(games.first)
          game_array << games.second
        else
          game_array << games.first
        end
      elsif games.size == 1
        game_array << games.first
      else
        game_array << nil
      end
    end

    def find_team_name(team_id)
      case team_id
        when /ANGELS/
          "Angels"
        when /HOUSTON/
          "Astros"
        when /OAKLAND/
          "Athletics"
        when /TORONTO/
          "Blue Jays"
        when /ATLANTA/
          "Braves"
        when /MILWAUKEE/
          "Brewers"
        when /LOUIS/
          "Cardinals"
        when /CUBS/
          "Cubs"
        when /ARIZONA/
          "Diamondbacks"
        when /DODGERS/
          "Dodgers"
        when /FRANCISCO/
          "Giants"
        when /CLEVELAND/
          "Indians"
        when /SEATTLE/
          "Mariners"
        when /MIAMI/
          "Marlins"
        when /METS/
          "Mets"
        when /WASHINGTON/
          "Nationals"
        when /BALTIMORE/
          "Orioles"
        when /DIEGO/
          "Padres"
        when /PHILADELPHIA/
          "Phillies"
        when /PITTSBURGH/
          "Pirates"
        when /TEXAS/
          "Rangers"
        when /TAMPA/
          "Rays"
        when /BOSTON/
          "Red Sox"
        when /CINCINATTI/
          "Reds"
        when /COLORADO/
          "Rockies"
        when /KANSAS/
          "Royals"
        when /DETROIT/
          "Tigers"
        when /MINNESOTA/
          "Twins"
        when /WHITE/
          "White Sox"
        when /YANKEES/
          "Yankees"
        else
          "Not found"
      end
    end
  end
end

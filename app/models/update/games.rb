module Update
  class Games

    include GetHtml

    def update(game_day)
      closingline(game_day)
      if game_day == GameDay.search(Time.now)
        umpire(game_day)
      end
      if game_day == GameDay.today || game_day == GameDay.yesterday
        scores(game_day)
      end
    end

    private
      def closingline(game_day)
        day_games = game_day.games
        game_size = day_games.size
        date_url = "?date=" + game_day.date.to_formatted_s(:number)
        url = "https://www.sportsbookreview.com/betting-odds/mlb-baseball/#{date_url}"
        puts url
        doc = Nokogiri::HTML(open(url))
        elements = doc.css(".event-holder")
        game_array = Array.new
        elements.each_with_index do |element, index|
          # Break once we find the all teams playing today
          if index == game_size
            break
          end
          home_abbr = element.children[0].children[5].children[1].text[0...3].squish
          away_abbr = element.children[0].children[5].children[0].text[0...3].squish
          home_abbr = 'CHW' if home_abbr == 'CWS'
          away_abbr = 'CHW' if away_abbr == 'CWS'
          home_team = Team.find_by(espn_abbr: home_abbr)
          away_team = Team.find_by(espn_abbr: away_abbr)
          add_game_to_array(game_array, day_games, home_team, away_team)
        end

        away_money_line = Array.new
        home_money_line = Array.new
        doc.css(".event-holder").each_with_index do |element, index|
          if index == game_size
            break
          end
          home_line = element.children[0].children[11].children[1].text.squish
          away_line = element.children[0].children[11].children[0].text.squish
          away_money_line << away_line
          home_money_line << home_line
        end

        away_totals = Array.new
        home_totals = Array.new
        url = "https://www.sportsbookreview.com/betting-odds/mlb-baseball/totals/" + date_url
        doc = Nokogiri::HTML(open(url))
        doc.css(".event-holder").each_with_index do |element, index|
          if index == game_size
            break
          end
          home_line = element.children[0].children[11].children[1].text.squish
          away_line = element.children[0].children[11].children[0].text.squish
          away_totals << away_line
          home_totals << home_line
        end

        (0...game_size).each do |i|
          game = game_array[i]
          if game
            game.update(away_money_line: away_money_line[i], home_money_line: home_money_line[i], away_total: away_totals[i], home_total: home_totals[i])
          end
        end

      end

      def umpire(game_day)
        url = "http://www.statfox.com/mlb/umpiremain.asp"
        doc = download_document(url)
        games = game_day.games
        team_id = var = 0
        team = nil
        doc.css(".datatable a").each do |data|
          var += 1
          if var%3 == 2
            team_id = data['href']
          elsif var%3 == 0
            if data.text.size == 3
              var = 1
              next
            end
            ump = data.text
            team_name = find_team_name(team_id)
            if team = Team.find_by_name(team_name)
              game = games.find_by(home_team_id: team.id)
              game.update(ump: ump)
              puts "#{game.game_id} #{ump}"
            end
          end
        end
      end

      def scores(game_day)
        games = game_day.games
        games.each do |game|
          url="http://www.espn.com/mlb/playbyplay?gameId=#{game.game_id}"
          puts url
          doc = Nokogiri::HTML(open(url))
          elements = doc.css("table.linescore__table tr")
          next if elements.size != 3
          elements[1].children.each_with_index do |element, index|
            next if index % 2 == 0 || index == 1
            game_stat = game.game_stats.find_or_create_by(row_number: index/2)
            game_stat.update(home_score: elements[1].children[index].text.squish, away_score: elements[2].children[index].text.squish)
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
            top_hits_string = doc.css("#allPlaysContainer section#allPlaysTop" + (index + 1).to_s + " ul .info-row--footer")
            top_hits_count = 0
            puts index + 1
            if top_hits_string.length != 0
              top_hits_string = top_hits_string.length[0].text.squish
              top_hits_string_end = top_hits_string.rindex("Hit")
              top_hits_string_start = top_hits_string.rindex(",", top_hits_string_end)
              top_hits_count = top_hits_string[top_hits_string_start+1..top_hits_string_end-1].to_i
            end
            bottom_hits_string = doc.css("#allPlaysContainer section#allPlaysBottom" + (index + 1).to_s + " ul .info-row--footer")
            bottom_hits_count = 0
            if bottom_hits_string.length != 0
              bottom_hits_string = bottom_hits_string[0].text.squish
              bottom_hits_string_end = bottom_hits_string.rindex("Hit")
              bottom_hits_string_start = bottom_hits_string.rindex(",", bottom_hits_string_end)
              bottom_hits_count = bottom_hits_string[bottom_hits_string_start+1..bottom_hits_string_end-1].to_i
            end
            hits = top_hits_count + bottom_hits_count
            game_stat = game.game_stats.find_or_create_by(row_number: (index + 1))
            game_stat.update(hits: hits, home_runs: home_runs)
          end
        end
      end

      def add_game_to_array(game_array, day_games, home_team, away_team)
        unless home_team && away_team
          game_array << nil
          return
        end
        games = day_games.where("home_team_id = ? AND away_team_id = ?", home_team.id, away_team.id)
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

module Create
  class Matchups

    include GetHtml
    
    def create(game_day)
      create_games(game_day)
      set_starters_false
      create_game_stats(game_day)
      remove_excess_starters(game_day)
    end

    private

      def set_starters_false
        Batter.starters.update_all(starter: false)
        Lancer.starters.update_all(starter: false)
      end

      def create_games(game_day)
        url = "http://www.espn.com/mlb/schedule/_/date/%d%s%02d" % [game_day.year, game_day.month, game_day.day]
        doc = download_document(url)
        puts url
        index = { away_team: 0, home_team: 1, result: 2 }
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
          if slice.children[index[:home_team]].children[0].children.size == 2
            home_abbr = slice.children[index[:home_team]].children[0].children[1].children[2].text
          elsif slice.children[index[:home_team]].children[0].children.size == 1
            home_abbr = slice.children[index[:home_team]].children[0].children[0].children[2].text
          end

          if slice.children[index[:away_team]].children.size == 2
            away_abbr = slice.children[index[:away_team]].children[1].children[2].text
          elsif slice.children[index[:away_team]].children.size == 1
            away_abbr = slice.children[index[:away_team]].children[0].children[2].text
          end

          away_team = Team.find_by_espn_abbr(away_abbr)
          home_team = Team.find_by_espn_abbr(home_abbr)
          next unless away_team
          next unless home_team

          url = "http://www.espn.com/mlb/game?gameId=#{game_id}"
          doc = download_document(url)
          element = doc.css(".game-date-time").first
          game_date = element.children[1]['data-date']
          date = DateTime.parse(game_date) - 4.hours + home_team.timezone.hours
          game = Game.find_or_create_by(game_id: game_id)
          gameDay = GameDay.find_or_create_by(season: game_day.season, date: date)
          game.update(game_day: gameDay, away_team: away_team, home_team: home_team, game_date: date)
        end
      end

      def create_game_stats(game_day)
        url = "http://www.baseballpress.com/lineups/%d-%s-%02d" % [game_day.year, game_day.month, game_day.day]
        doc = download_document(url)
        puts url
        games = game_day.games
        elements = doc.css(".lineup-card")
        season = game_day.season
        elements.each do |element|
          teams = element.css('.lineup-card-header')[0].children[1].css('a')
          away_team = Team.find_by_name(teams[0].text.squish)
          home_team = Team.find_by_name(teams[1].text.squish)

          game_date = element.css('.lineup-card-header')[0].children[1].children[5].text.squish
          game_date = DateTime.parse(game_date) + home_team.timezone.hours
          game_date = game_date.strftime('%FT%T%:z')
          game = games.where(away_team: away_team, home_team: home_team, game_date: game_date).first
          game = games.where(away_team: away_team, home_team: home_team).first unless game
          game = game_day.next_days(1).games.where(away_team: away_team, home_team: home_team).first unless game
          next unless game

          players = element.css('.lineup-card-header')[0].children[3].css('.player')
          away_pitcher = players[0]
          home_pitcher = players[1]

          if away_pitcher.text.squish != 'TBD'
            away_pitcher_name = away_pitcher.children[0].children[0].text.squish
            away_pitcher_handedness = away_pitcher.children[1].text.squish[1]
            away_pitcher_handedness = 'B' if away_pitcher_handedness == 'S'

            puts away_pitcher_name
            puts away_pitcher_handedness
            player = Player.search(away_pitcher_name, nil, 0, away_team.id)
            player = Player.search(away_pitcher_name, nil, 0) unless player
            unless player
              puts "Away Pitcher Player #{away_team.name} #{away_pitcher_name} not found"
              player = Player.create(name: away_pitcher_name, throwhand: away_pitcher_handedness)
            end
            player.update(team: away_team)
            lancer = player.create_lancer(season)
            lancer.update_attributes(starter: true)
            game_lancer = player.create_lancer(season, away_team, game)
            game_lancer.update(starter: true)
          end

          if home_pitcher.text.squish != 'TBD'
            home_pitcher_name = home_pitcher.children[0].children[0].text.squish
            home_pitcher_handedness = home_pitcher.children[1].text.squish[1]
            home_pitcher_handedness = 'B' if home_pitcher_handedness == 'S'
            player = Player.search(home_pitcher_name, nil, 0, home_team.id)
            player = Player.search(home_pitcher_name, nil, 0) unless player
            unless player
              puts "Home Pitcher Player #{home_team.name} #{home_pitcher_name} not found"
              player = Player.create(name: home_pitcher_name, throwhand: home_pitcher_handedness)
            end
            player.update(team: home_team)
            lancer = player.create_lancer(season)
            lancer.update_attributes(starter: true)
            game_lancer = player.create_lancer(season, home_team, game)
            game_lancer.update(starter: true)
          end

          players = element.css('.lineup-card-body .h-100 .col')
          away_players = players[0].css('.player')

          away_players.each do |away_player|
            name = away_player.children[1].children[0].text
            lineup = away_player.child.to_s[0].to_i
            handedness = away_player.children[2].to_s[2]
            position = away_player.children[2].to_s.match(/\w*$/).to_s
            puts name
            puts lineup
            puts handedness
            puts position

            player = Player.search(name, nil, 0, away_team.id)
            player = Player.search(name, nil, 0) unless player
            player = Player.create(name: name, bathand: handedness) unless player
            player.update(team: away_team)
            batter = player.create_batter(season)
            batter.update(starter: true)
            game_batter = player.create_batter(season, away_team, game)
            game_batter.update(starter: true, position: position, lineup: lineup)
          end

          home_players = players[1].css('.player')

          home_players.each do |home_player|
            name = home_player.children[1].children[0].text
            lineup = home_player.child.to_s[0].to_i
            handedness = home_player.children[2].to_s[2]
            position = home_player.children[2].to_s.match(/\w*$/).to_s
            puts name
            puts lineup
            puts handedness
            puts position

            player = Player.search(name, nil, 0, home_team.id)
            player = Player.search(name, nil, 0) unless player

            player = Player.create(name: name, bathand: handedness) unless player
            player.update(team: home_team)
            batter = player.create_batter(season)
            batter.update(starter: true)
            game_batter = player.create_batter(season, home_team, game)
            game_batter.update(starter: true, position: position, lineup: lineup)
          end
        end
      end


      def remove_excess_starters(game_day)
        game_day.games.each do |game|
          game.lancers.where(starter: true).each do |game_lancer|
            unless game_lancer.player
              game_lancer.destroy
            end
            lancer = game_lancer.player.find_lancer(game_lancer.season)
            unless lancer.starter
              game_lancer.destroy
            end
          end
          game.batters.where(starter: true).each do |game_batter|
            unless game_batter.player
              game_batter.destroy
            end
            batter = game_batter.player.find_batter(game_batter.season)
            unless batter.starter
              game_batter.destroy
            end
          end
        end
      end

  end
end

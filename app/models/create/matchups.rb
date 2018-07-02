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
        url = "http://www.espn.com/mlb/schedule/_/date/%d%02d%02d" % [game_day.year, game_day.month, game_day.day]
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

      def element_type(element)
        element_class = element['class']
        case element_class
        when /game-time/
          type = 'time'
        when /no-lineup/
          type = 'no lineup'
        when /team-name/
          type = 'lineup'
        else
          if element.children.size == 3
            type = 'batter'
          else
            type = 'pitcher'
          end
        end
      end

      def find_team_from_pitcher_index(pitcher_index, away_team, home_team)
        if pitcher_index%2 == 0
          away_team
        else
          home_team
        end
      end

      def find_team_from_batter_index(batter_index, away_team, home_team, away_lineup, home_lineup)
        if away_lineup && home_lineup
          if batter_index/9 == 0
            away_team
          else
            home_team
          end
        elsif away_lineup
          away_team
        else
          home_team
        end
      end

      def pitcher_info(element)
        name = element.child.text
        identity = element.child['data-bref']
        fangraph_id = element.child['data-razz'].gsub!(/[^0-9]/, "").to_i
        handedness = element.children[1].text[2]
        return identity, fangraph_id, name, handedness
      end

      def batter_info(element)
        name = element.children[1].text
        lineup = element.child.to_s[0].to_i
        handedness = element.children[2].to_s[2]
        position = element.children[2].to_s.match(/\w*$/).to_s
        identity = element.children[1]['data-bref']
        fangraph_id = element.children[1]['data-razz'].gsub!(/[^0-9]/, "").to_i
        return identity, fangraph_id, name, handedness, lineup, position
      end

      def create_game_stats(game_day)
        url = "http://www.baseballpress.com/lineups/%d-%02d-%02d" % [game_day.year, game_day.month, game_day.day]
        doc = download_document(url)
        puts url
        games = game_day.games
        game_index = -1
        away_lineup = home_lineup = false
        away_team = home_team = nil
        team_index = pitcher_index = batter_index = 0
        elements = doc.css(".players div, .team-name+ div, .team-name, .game-time")
        season = game_day.season
        teams = Set.new
        elements.each_with_index do |element, index|
          type = element_type(element)
          case type
          when 'time'
            game_index += 1
            batter_index = 0
            teams << away_team if away_team
            next
          when 'lineup'
            if team_index%2 == 0
              away_team = Team.find_by_name(element.text)
              away_lineup = true
            else
              home_team = Team.find_by_name(element.text)
              home_lineup = true
            end
            team_index += 1
            next
          when 'no lineup'
            if team_index%2 == 0
              away_team = Team.find_by_name(element.text)
              away_lineup = false
            else
              home_team = Team.find_by_name(element.text)
              home_lineup = false
            end
            team_index += 1
            next
          when 'pitcher'
            if element.text == "TBD"
              pitcher_index += 1
              next
            else
              identity, fangraph_id, name, handedness = pitcher_info(element)
            end
            team = find_team_from_pitcher_index(pitcher_index, away_team, home_team)
            pitcher_index += 1
          when 'batter'
            identity, fangraph_id, name, handedness, lineup, position = batter_info(element)
            team = find_team_from_batter_index(batter_index, away_team, home_team, away_lineup, home_lineup)
            batter_index += 1
          end

          player = Player.search(name, nil, fangraph_id)

          # Make sure the player is in database, otherwise create him
          unless player
            if type == 'pitcher'
              player = Player.create(name: name, fangraph_id: fangraph_id, throwhand: handedness)
            else
              player = Player.create(name: name, fangraph_id: fangraph_id, bathand: handedness)
            end
            puts "Player " + player.name + " created"
          end


          player.update(team: team)
          game = find_game(games, away_team, teams)

          # Set the season player and the game player to true
          # This will help in determining whether or not to delete a player
          if type == 'pitcher'
            lancer = player.create_lancer(season)
            lancer.update_attributes(starter: true)
            game_lancer = player.create_lancer(season, team, game)
            game_lancer.update(starter: true)
          elsif type == 'batter'
            batter = player.create_batter(season)
            batter.update(starter: true)
            game_batter = player.create_batter(season, team, game)
            game_batter.update(starter: true, position: position, lineup: lineup)
          end
        end
      end

      def find_game(games, away_team, teams)
        games = games.where(away_team: away_team)
        size = games.size
        if size == 1
          return games.first
        elsif size == 2
          return teams.include?(away_team) ? games.second : games.first
        end
      end


      def remove_excess_starters(game_day)
        game_day.games.each do |game|
          game.lancers.where(starter: true).each do |game_lancer|
            lancer = game_lancer.player.find_lancer(game_lancer.season)
            unless lancer.starter
              game_lancer.destroy
            end
          end
          game.batters.where(starter: true).each do |game_batter|
            batter = game_batter.player.find_batter(game_batter.season)
            unless batter.starter
              game_batter.destroy
            end
          end
        end
      end

  end
end

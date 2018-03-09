module Create
  class Matchups

    include GetHtml
    
    def create(game_day)
      url = "http://www.espn.com/mlb/schedule/_/date/%d%02d%02d" % [game_day.year, game_day.month, game_day.day]
      doc = download_document(url)
      puts url
      create_games(doc, game_day)
      set_starters_false
      create_game_stats(doc, game_day)
      remove_excess_starters(game_day)
    end

    private

      def set_starters_false
        Batter.starters.update_all(starter: false)
        Lancer.starters.update_all(starter: false)
      end

      def create_games(doc, game_day)
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

          url = "http://www.espn.com/mlb/game?gameId=#{game_id}"
          doc = download_document(url)
          element = doc.css(".game-date-time").first
          game_date = element.children[1]['data-date']
          date = DateTime.parse(game_date) - 4.hours - home_team.timezone.hours
          game = Game.find_or_create_by(game_days_id: game_day.id, away_team: away_team, home_team: home_team, game_id: game_id)
          game.update(game_date: date)
        end
      end

      def create_game_stats(doc, game_day)
        games = game_day.games
        games.each do |game|
          url = "http://www.espn.com/mlb/boxscore?gameId=#{game.game_id}"
          puts url

          doc = download_document(url)
          next unless doc

          pitchers = doc.css('.stats-wrap')
          next if pitchers.size < 4
          away_pitcher = pitchers[1]
          home_pitcher = pitchers[3]
          away_batter = pitchers[0]
          home_batter = pitchers[2]

          team_pitchers(away_pitcher, game.away_team, game)
          team_pitchers(home_pitcher, game.home_team, game)

          team_batters(away_batter, game.away_team, game)
          team_batters(home_batter, game.home_team, game)
        end
      end

      def team_batters(batter, team, game)
        batter_size = batter.children.size
        return if batter_size == 3 && batter.children[1].children[0].children.size == 1
        lineup = 1
        (1...batter_size-1).each do |index|
          row = batter.children[index].children[0]
          next if row.children[0].children.size != 2
          name = row.children[0].child.text
          identify = parse_identity(row.children[0])
          position = row.children[0].children[1].text
          player = Player.find_by(identity: identity)
          unless player
            puts "Player #{name} not found" 
            next
          end
          if false
            player.update(team: team)
            batter = player.create_batter(game.game_days.season, team, game)
            batter.update(starter: true)
            game_batter = player.create_batter(game.game_days.season, team, game)
            game_batter.update(starter: true, position: position, lineup: lineup)
          end
          puts player.name
          lineup = lineup + 1
        end
        puts lineup
      end

      def team_pitchers(pitcher, team, game)
        pitcher_size = pitcher.children.size
        return if pitcher_size == 3 && pitcher.children[1].children[0].children.size == 1
        (1...batter_size-1).each do |index|
          row = pitcher.children[index].children[0]
          name = row.children[0].child.text
          identify = parse_identity(row.children[0])
          player = Player.find_by(identity: identity)
          unless player
            puts "Player #{name} not found"
            next
          end
          if false
            player.update(team: team)
            lancer = player.create_lancer(game.game_days.season, team, game)
            lancer.update(starter: true)
            game_lancer = player.create_lancer(game.game_days.season, team, game)
            game_lancer.update(starter: true)
          end
          puts player.name
          break
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

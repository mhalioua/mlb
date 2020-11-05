module Create
  class Games
    include GetHtml

    def create(season, team)
      create_games(season.year, team.espn_abbr)
      set_starters_false
      game_days = GameDay.where(season: season)
      game_days.each do |game_day|
        create_game_stats(game_day, team)
        remove_excess_starters(game_day)
      end
    end


    private

      def parse_identity(element)
        href = element.child['href']
        href[href.rindex("/")+1..-1] if href
      end

      def parse_name(element)
        if element.child['href']
          href = element.child['href']
          doc = download_document(href)
          doc.css("h1").first.text
        end
      end

      def set_starters_false
        Batter.starters.update_all(starter: false)
        Lancer.starters.update_all(starter: false)
      end

      def create_games(year, home_team_abbr)
        (1..2).each do |type|
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
              away_abbr = opposite_team_name.upcase
              home_abbr = home_team_abbr
            else
              home_abbr = opposite_team_name.upcase
              away_abbr = home_team_abbr
            end

            away_team = Team.find_by_espn_abbr(away_abbr)
            home_team = Team.find_by_espn_abbr(home_abbr)

            next unless element.children[4].children[0].children.size == 2
            game_link = element.children[4].children[0].children[1].children[0]['href']

            game_index_start = game_link.rindex('/')
            game_id = game_link[game_index_start+1..-1]

            url = "http://www.espn.com/mlb/game?gameId=#{game_id}"
            doc = download_document(url)
            element = doc.css(".game-date-time").first
            game_date = element.children[1]['data-date']
            date = DateTime.parse(game_date) - 5.hours + home_team.timezone.hours
            game_day = GameDay.find_or_create_by(season: Season.find_by_year(year), date: date)

            game = Game.find_or_create_by(game_id: game_id)
            game.update(game_day: game_day, away_team: away_team, home_team: home_team, game_date: date)
          end
        end
      end

      def create_game_stats(game_day, team)
        games = game_day.games
        games.each do |game|
          next if game.home_team != team && game.away_team != team
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

      def team_batters(batters, team, game)
        batter_size = batters.children.size
        return if batter_size == 3 && batters.children[1].children[0].children.size == 1
        lineup = 1
        (1...batter_size-1).each do |index|
          row = batters.children[index].children[0]
          next if row.children[0]['class'] == 'name bench'
          name = parse_name(row.children[0])
          identity = parse_identity(row.children[0])
          position = row.children[0].children[1].text
          player = Player.search(name, identity, 0)
          unless player
            player = Player.create(team: team, name: name, identity: identity)
            puts "Player " + player.name + " created"
          end
          player.update(team: team, identity: identity)
          batter = player.create_batter(game.game_day.season)
          batter.update(starter: true)
          game_batter = player.create_batter(game.game_day.season, team, game)
          game_batter.update(starter: true, position: position, lineup: lineup)
          lineup = lineup + 1
        end
        puts "-----------------#{lineup}-----------------"
      end

      def team_pitchers(pitchers, team, game)
        pitcher_size = pitchers.children.size
        return if pitcher_size == 3 && pitchers.children[1].children[0].children.size == 1
        (1...pitcher_size-1).each do |index|
          row = pitchers.children[index].children[0]
          name = parse_name(row.children[0])
          identity = parse_identity(row.children[0])
          player = Player.search(name, identity, 0)
          unless player
            player = Player.create(team: team, name: name, identity: identity)
            puts "Player " + player.name + " created"
          end
          player.update(team: team, identity: identity)
          lancer = player.create_lancer(game.game_day.season)
          lancer.update(starter: true)
          game_lancer = player.create_lancer(game.game_day.season, team, game)
          game_lancer.update(starter: true)
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
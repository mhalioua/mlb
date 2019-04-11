module Create
  class Bullpen

    include GetHtml

    def create(game_day)
      set_bullpen(game_day)
      update_bullpen(game_day)
      create_bullpen(game_day)
    end

    private

      @@bullpen_teams = [1, 2, 3, 4, 12, 13, 17, 21, 22, 23, 26, 27, 28, 29, 30, 5, 6, 7, 8, 9, 10, 11, 14, 15, 16, 18, 19, 20, 24, 25]

      def set_bullpen(game_day)
        url = "http://www.baseballpress.com/bullpen-usage"
        puts url
        doc = download_document(url)

        Lancer.bullpen.update_all(bullpen: false)
        player = nil
        var = one = two = three = four = five = 0
        team_index = -1
        season = game_day.season
        doc.css(".no-space tr").each do |element|
          if element.children.size < 3
            puts element.children[0].text
            next
          end
          text = element.text
          if text == "Pitcher"
            team_index += 1
            next
          end
          case var
          when 1
            one = get_pitches(text)
            var += 1
          when 2
            two = get_pitches(text)
            var += 1
          when 3
            three = get_pitches(text)
            var += 1
          when 4
            four = get_pitches(text)
            var += 1
          when 5
            five = get_pitches(text)
            update_bullpen_pitches(player, one, two, three, four, five, game_day.time)
            var = 0
          end

          name = element.child.text
          player = Player.search(name, nil, nil)
          unless player
            player = Player.create(name: name)
          end
          player.update(team_id: @@bullpen_teams[team_index])
          lancer = player.create_lancer(season)
          lancer.update(bullpen: true)
          var = 1
        end
      end

      def update_bullpen(game_day)
        Lancer.bullpen.update_all(bullpen: false)
        season = game_day.season
        games = game_day.games
        games.each do |game|
          pitchers = game.pitchers
          pitchers.each do |pitcher|
            player = Player.search(pitcher.name, pitcher.identity)
            player.update(team_id: pitcher.team_id)
            lancer = player.create_lancer(season)
            lancer.update(bullpen: true)
            lancer.update(pitches: pitcher.pc)
          end
        end
      end

      def create_bullpen(game_day)
        games = game_day.games
        Lancer.bullpen.each do |lancer|
          player = lancer.player
          team = player.team
          if team
            games.where("away_team_id = #{team.id} OR home_team_id = #{team.id}").each do |game|
              lancer = player.create_lancer(lancer.season, team, game)
              lancer.update(bullpen: true)
            end
          end
        end
      end

      def get_pitches(text)
        if text == "N/G"
          return 0
        else
          return text.to_i
        end
      end

      def update_bullpen_pitches(player, one, two, three, four, five, time)
        (1..5).each do |n|
          game_day = GameDay.search(time)
          time = time.yesterday
          case n
          when 1
            pitches = one
          when 2
            pitches = two
          when 3
            pitches = three
          when 4
            pitches = four
          when 5
            pitches = five
          end
          lancers = player.game_day_lancers(game_day)
          lancers.each do |lancer|
            lancer.update(pitches: pitches)
          end
        end
      end

  end
end
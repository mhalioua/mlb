module Create
  class Bullpen

    include GetHtml

    def create(game_day)
      set_bullpen(game_day)
      create_bullpen(game_day)
    end

    private

      def set_bullpen(game_day)
        url = "http://www.baseballpress.com/bullpen-usage"
        puts url
        doc = download_document(url)

        Lancer.bullpen.update_all(bullpen: false)
        season = game_day.season
        team = nil
        doc.css(".no-space tr").each do |element|
          if element.children.size < 3
            team = Team.find_by(name: element.children[0].text)
            puts element.children[0].text
            next
          end
          if element.children[0].text == "Pitcher"
            next
          end
          name = element.children[0].children[0].children[0].text
          player = Player.search(name, nil, 0, team.id)
          player = Player.search(name, nil, 0) unless player
          unless player
            puts "BullPen Player #{name} not found"
            player = Player.create(name: name)
          end
          player.update(team: team)
          lancer = player.create_lancer(season)
          lancer.update(bullpen: true)

          one = get_pitches(element.children[1].text)
          two = get_pitches(element.children[2].text)
          three = get_pitches(element.children[3].text)
          four = get_pitches(element.children[4].text)
          five = get_pitches(element.children[5].text)
          update_bullpen_pitches(player, one, two, three, four, five, game_day)
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
        if text == "x"
          return 0
        else
          return text.to_i
        end
      end

      def update_bullpen_pitches(player, one, two, three, four, five, game_day)
        (1..5).each do |n|
          gameDay = game_day.previous_days(n)
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
          lancers = player.game_day_lancers(gameDay)
          lancers.each do |lancer|
            lancer.update(pitches: pitches)
          end
        end
      end

  end
end
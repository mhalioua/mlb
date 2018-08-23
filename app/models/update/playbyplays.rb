module Update
  class Playbyplays

    include GetHtml

    def update(game_day)
      games = game_day.games
      games = Game.where(game_id: 380822111)
      games.each do |game|
        pitchers = game.pitchers.all.to_a
        batters = game.hitters.all.to_a
        url = "http://www.espn.com/mlb/playbyplay?gameId=#{game.game_id}"
        puts url

        doc = download_document(url)
        next unless doc

        lines = doc.css("#allPlays .headline")
        pitcher_flag = "L"
        batter_flag = "R"

        ab = 0
        h = 0
        bb = 0
        hr = 0
        k = 0

        lines.each_with_index do |line, index|
          line_string = line.text.squish
          line_string = line_string.gsub('á', 'a')
          line_string = line_string.gsub('í', 'i')
          line_string = line_string.gsub('é', 'e')
          next if line_string.length == 0
          name = line_string.split(' ')[0]
          check_pitcher = pitchers.select {|player| player.name.include?(name)}
          check_batter = batters.select {|player| player.name.include?(name)}
          if check_pitcher.length != 0
            pitcher_flag = check_pitcher[0].hand
          elsif check_batter.length != 0
            batter_flag = check_batter[0].hand
            puts index
            puts pitcher_flag
            puts batter_flag
            puts line_string

            if line_string.include?("homered to")
              puts "HR"
              puts "AB"
              puts "H"
              hr += 1
              ab += 1
              h += 1
            elsif line_string.include?("singled") || line_string.include?("bunt hit") ||line_string.include?("doubled") ||line_string.include?("tripled")
              puts "H"
              puts "AB"
              h += 1
              ab += 1
            elsif line_string.include?("struck out")
              puts "BB"
              puts "K"
              bb += 1
              k += 1
            elsif line_string.include?("out")
              puts "AB"
              ab += 1
            elsif line_string.include?("walked")
              puts "BB"
              bb += 1
            end
          else
            puts name + " does not exist"
          end
        end
        puts "AB " + ab.to_s
        puts "h " + h.to_s
        puts "bb " + bb.to_s
        puts "hr " + hr.to_s
        puts "k " + k.to_s
      end
    end

    private

  end
end

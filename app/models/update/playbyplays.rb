module Update
  class Playbyplays

    include GetHtml

    def update(game_day)
      games = game_day.games
      # games = Game.where(game_id: 380822111)
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

        lines.each_with_index do |line, index|
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
          check_pitcher = pitchers.select {|player| player.name.include?(name)}
          check_batter = batters.select {|player| player.name.include?(name)}
          if check_pitcher.length != 0
            pitcher_flag = check_pitcher[0].hand.downcase
            if pitcher_flag == ''
              if name == 'Michael Kopech'
                pitcher_flag = 'r'
              else
                puts "Pitcher" + name
              end
            end
          elsif check_batter.length != 0
            batter_flag = check_batter[0].hand.downcase
            if batter_flag == ''
              if name == 'Michael Kopech'
                batter_flag = 'r'
              else
                puts "Batter" + name
              end
            end
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
            else
              puts line_string
            end
          else
            puts name + " does not exist"
          end
        end
        playbyplay = Playbyplay.find_or_create_by(game_id: game.id)
        playbyplay.update(
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

    private

  end
end

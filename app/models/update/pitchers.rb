module Update
  class Pitchers

    include GetHtml

    def update(season, team)
      year = season.year
      puts "Update #{team.name} #{year} Pitchers"

      (1..1).each do |rost|
        url = "http://www.fangraphs.com/leaders.aspx?pos=all&stats=pit&lg=all&qual=0&type=1&season=#{year}&month=0&season1=#{year}&ind=0&team=#{team.fangraph_id}&rost=#{rost}&age=0&filter=&players=0&page=1_50"
        doc = download_document(url)
        puts url
        next unless doc
        index = {name: 1, fip: 11 + rost, siera: 15 + rost}
        doc.css(".grid_line_regular").each_slice(16 + rost) do |slice|
          name = slice[index[:name]].text
          fangraph_id = parse_fangraph_id(slice[index[:name]])
          player = Player.search(name, nil, fangraph_id)
          unless player
            puts "Player " + name + " not found"
            next
          end
          fip = slice[index[:fip]].text.to_f
          siera = slice[index[:siera]].text.to_f
          if player
            lancer = player.create_lancer(season)
            lancer.stats.each_with_index do |pitcher_stat|
              if pitcher_stat.handedness.size > 0
                pitcher_stat.update(fip: fip, siera: siera)
              end
            end
          end
        end


        url_l = "http://www.fangraphs.com/leaders.aspx?pos=all&stats=pit&lg=all&qual=0&type=c,36,31,4,14,11,5,38,43,27,47,37,7&season=#{year}&month=13&season1=#{year}&ind=0&team=#{team.fangraph_id}&rost=#{rost}&age=0&filter=&players=0&page=1_50"
        url_r = "http://www.fangraphs.com/leaders.aspx?pos=all&stats=pit&lg=all&qual=0&type=c,36,31,4,14,11,5,38,43,27,47,37,7&season=#{year}&month=14&season1=#{year}&ind=0&team=#{team.fangraph_id}&rost=#{rost}&age=0&filter=&players=0&page=1_50"
        urls = [url_l, url_r]
        player = name = ld = whip = ip = so = bb = era = fb = xfip = kbb = woba = gb = nil
        urls.each_with_index do |url, url_index|
          puts url
          doc = download_document(url)
          next unless doc
          index = {name: 1, ld: 2 + rost, whip: 3 + rost, ip: 4 + rost, so: 5 + rost, bb: 6 + rost, era: 7 + rost, fb: 8 + rost, xfip: 9 + rost,
                   kbb: 10 + rost, woba: 11 + rost, gb: 12 + rost, h: 13 + rost}
          doc.css(".grid_line_regular").each_slice(14 + rost) do |slice|
            name = slice[index[:name]].text
            fangraph_id = parse_fangraph_id(slice[index[:name]])
            player = Player.search(name, nil, fangraph_id)
            unless player
              puts "Player " + name + " not found"
              next
            end
            ld = slice[index[:ld]].text[0...-2].to_f
            whip = slice[index[:whip]].text.to_f
            ip = slice[index[:ip]].text.to_f
            so = slice[index[:so]].text.to_f
            bb = slice[index[:bb]].text.to_f
            era = slice[index[:era]].text.to_f
            fb = slice[index[:fb]].text[0...-2].to_f
            xfip = slice[index[:xfip]].text.to_f
            kbb = slice[index[:kbb]].text.to_f
            woba = (slice[index[:woba]].text.to_f * 1000).to_i
            gb = slice[index[:gb]].text[0...-2].to_f
            h = slice[index[:h]].text.to_i
            handedness = get_handedness(url_index)
            lancer = player.create_lancer(season)
            pitcher_stat = lancer.stats.where(handedness: handedness).first
            pitcher_stat.update_attributes(ld: ld, whip: whip, ip: ip, so: so, bb: bb, era: era, fb: fb, xfip: xfip, kbb: kbb, woba: woba, gb: gb, h: h)
          end
        end

        # No handedness
        url = "http://www.fangraphs.com/leaders.aspx?pos=all&stats=pit&lg=all&qual=0&type=c,47,42,13,24,19,122&season=#{year}&month=3&season1=#{year}&ind=0&team=#{team.fangraph_id}&rost=#{rost}&age=0&filter=&players=0&page=1_50"
        puts url
        doc = download_document(url)
        next unless doc
        name = ld = whip = ip = so = bb = siera = nil
        index = {name: 1, ld: 2 + rost, whip: 3 + rost, ip: 4 + rost, so: 5 + rost, bb: 6 + rost, siera: 7 + rost}
        doc.css(".grid_line_regular").each_slice(8 + rost) do |slice|
          name = slice[index[:name]].text
          fangraph_id = parse_fangraph_id(slice[index[:name]])
          player = Player.search(name, nil, fangraph_id)
          unless player
            puts "Player " + name + " not found"
            next
          end
          ld = slice[index[:ld]].text[0...-2].to_f
          whip = slice[index[:whip]].text.to_f
          ip = slice[index[:ip]].text.to_f
          so = slice[index[:so]].text.to_i
          bb = slice[index[:bb]].text.to_i
          siera = slice[index[:siera]].text.to_f
          lancer = player.create_lancer(season)
          pitcher_stat = lancer.stats.where(handedness: "").first
          pitcher_stat.update_attributes(ld: ld, whip: whip, ip: ip, so: so, bb: bb, siera: siera)
        end
      end

      team.players.each do |player|
        unless player.lancers.find_by(season: season)
          next
        end
        url = "http://www.espn.com/mlb/player/splits/_/id/#{player.identity}/year/#{year}"
        puts url
        doc = download_document(url)
        unless doc
          puts "#{player.name} not found"
          next
        end
        rows = doc.css("table tr")
        count = 0
        rows.each_with_index do |element, index|
          next unless element.children[1]
          if element.children[1].text == "vs. Left"
            player.create_lancer(season).stats.find_by(handedness: "L").update_attributes(ops: element.children[17].text)
            count = count + 1
          end
          if element.children[1].text == "vs. Right"
            player.create_lancer(season).stats.find_by(handedness: "R").update_attributes(ops: element.children[17].text)
            count = count + 1
          end
          break if count == 2
        end
      end
    end

    def scout(season, team)
      year = season.year
      puts "Update #{team.name} #{year} Pitchers Scout"

      (1..1).each do |rost|
        url = "http://www.fangraphs.com/leaders.aspx?pos=all&stats=pit&lg=all&qual=0&type=16&season=#{year}&month=0&season1=#{year}&ind=0&team=#{team.fangraph_id}&rost=#{rost}&age=0&filter=&players=0&page=1_50"
        doc = download_document(url)
        puts url
        next unless doc
        index = {name: 1, ip: 2 + rost, fa: 3 + rost, fc: 4 + rost, fs: 5 + rost, si: 6 + rost, ch: 7 + rost, sl: 8 + rost, cu: 9 + rost}
        doc.css(".grid_line_regular, .grid_line_break").each_slice(14 + rost) do |slice|
          name = slice[index[:name]].text
          fangraph_id = parse_fangraph_id(slice[index[:name]])
          player = Player.search(name, nil, fangraph_id)
          unless player
            puts "Player " + name + " not found"
            next
          end
          if player
            scout = PitcherScouting.find_or_create_by(player_id: player.id, team: team, season: season)
            scout.update(
                IP: slice[index[:ip]].text,
                FA: slice[index[:fa]].text,
                FC: slice[index[:fc]].text,
                FS: slice[index[:fs]].text,
                SI: slice[index[:si]].text,
                CH: slice[index[:ch]].text,
                SL: slice[index[:sl]].text,
                CU: slice[index[:cu]].text
            )
          end
        end
      end
    end


    def box_scores(game_day)
      game_day.games.each do |game|
        url = "http://www.espn.com/mlb/boxscore?gameId=#{game.game_id}"
        puts url

        doc = download_document(url)
        next unless doc

        pitchers = doc.css('.stats-wrap')
        next if pitchers.size < 4

        away_pitcher = pitchers[1]
        home_pitcher = pitchers[3]

        team_pitchers(game, game.away_team, away_pitcher)
        team_pitchers(game, game.home_team, home_pitcher)
      end
    end

    def prev(game_day)
      game_day.games.each do |game|
        Prevpitcher.where(game_id: game.id).destroy_all
        away_starting_lancer = game.lancers.where(team: game.away_team, starter: true, season_id: game_day.season.id)
        home_starting_lancer = game.lancers.where(team: game.home_team, starter: true, season_id: game_day.season.id)

        unless away_starting_lancer.empty?
          get_prev_pitchers(game, away_starting_lancer.first.prev_pitchers.limit(60), true)
        end

        unless home_starting_lancer.empty?
          get_prev_pitchers(game, home_starting_lancer.first.prev_pitchers.limit(60), false)
        end
      end
    end

    def information(game_day)
      game_day.games.each do |game|
        Pitcherinformation.where(game_id: game.id).destroy_all

        if game.away_pitcher
          get_pitcher_information(game, game.away_pitcher, true)
        end

        if game.home_pitcher
          get_pitcher_information(game, game.home_pitcher, false)
        end
      end
    end

    private

    def get_pitcher_information(game, pitcher, away)
      seasons = Season.greater_than(2020)
      stats = pitcher.view_stats(seasons)
      lefty, righty = pitcher.opposing_batters_handedness
      ip_two = mixed_statistic_ip(stats[1].first.ip, stats[1].second.ip)
      ip_three = mixed_statistic_ip(stats[0].first.ip, stats[0].second.ip)
      gb_two = mixed_statistic(stats[1].first.gb, stats[1].second.gb, lefty, righty)
      gb_three = mixed_statistic(stats[0].first.gb, stats[0].second.gb, lefty, righty)
      woba_two = mixed_statistic(stats[1].first.woba, stats[1].second.woba, lefty, righty).to_i
      woba_three = mixed_statistic(stats[0].first.woba, stats[0].second.woba, lefty, righty).to_i
      left_stat = stats[1].where(handedness: "L").first
      fip_two = left_stat.fip
      left_stat = stats[0].where(handedness: "L").first
      fip_three = left_stat.fip
      tld_two = mixed_statistic(stats[1].first.tld, stats[1].second.tld, lefty, righty)
      tld_three = mixed_statistic(stats[0].first.tld, stats[0].second.tld, lefty, righty)
	    prev_pitchers = pitcher.prev_pitchers
      game_one_ip = []
      game_one_bb = 0
      game_one_h = 0
      game_one_opp_ip = []
      game_one_opp_bb = 0
      game_one_opp_h = 0
      game_two_ip = []
      game_two_bb = 0
      game_two_h = 0
      game_two_opp_ip = []
      game_two_opp_bb = 0
      game_two_opp_h = 0
      game_three_ip = []
      game_three_bb = 0
      game_three_h = 0
      game_three_opp_ip = []
      game_three_opp_bb = 0
      game_three_opp_h = 0
      game_four_ip = []
      game_four_bb = 0
      game_four_h = 0
      game_four_opp_ip = []
      game_four_opp_bb = 0
      game_four_opp_h = 0
      game_five_ip = []
      game_five_bb = 0
      game_five_h = 0
      game_five_opp_ip = []
      game_five_opp_bb = 0
      game_five_opp_h = 0
      game_six_ip = []
      game_six_bb = 0
      game_six_h = 0
      game_six_opp_ip = []
      game_six_opp_bb = 0
      game_six_opp_h = 0
      game_seven_ip = []
      game_seven_bb = 0
      game_seven_h = 0
      game_seven_opp_ip = []
      game_seven_opp_bb = 0
      game_seven_opp_h = 0
      prev_pitchers.each_with_index do |prev_pitcher, index|
        opposite = prev_pitcher.game.lancers.find_by(starter: true, team_id: prev_pitcher.opp_team.id)
        if index < 15
          game_one_ip.push(prev_pitcher.ip)
          game_one_bb = game_one_bb + prev_pitcher.bb
          game_one_h = game_one_h + prev_pitcher.h
          if opposite
            game_one_opp_ip.push(opposite.ip)
            game_one_opp_bb = game_one_opp_bb + opposite.bb.to_i
            game_one_opp_h = game_one_opp_h + opposite.h.to_i
          end
        elsif index < 30
          game_two_ip.push(prev_pitcher.ip)
          game_two_bb = game_two_bb + prev_pitcher.bb
          game_two_h = game_two_h + prev_pitcher.h
          if opposite
            game_two_opp_ip.push(opposite.ip)
            game_two_opp_bb = game_two_opp_bb + opposite.bb.to_i
            game_two_opp_h = game_two_opp_h + opposite.h.to_i
          end
        end
        if index < 20
          game_three_ip.push(prev_pitcher.ip)
          game_three_bb = game_three_bb + prev_pitcher.bb
          game_three_h = game_three_h + prev_pitcher.h
          if opposite
            game_three_opp_ip.push(opposite.ip)
            game_three_opp_bb = game_three_opp_bb + opposite.bb.to_i
            game_three_opp_h = game_three_opp_h + opposite.h.to_i
          end
        elsif index < 40
          game_four_ip.push(prev_pitcher.ip)
          game_four_bb = game_four_bb + prev_pitcher.bb
          game_four_h = game_four_h + prev_pitcher.h
          if opposite
            game_four_opp_ip.push(opposite.ip)
            game_four_opp_bb = game_four_opp_bb + opposite.bb.to_i
            game_four_opp_h = game_four_opp_h + opposite.h.to_i
          end
        elsif index < 60
          game_five_ip.push(prev_pitcher.ip)
          game_five_bb = game_five_bb + prev_pitcher.bb
          game_five_h = game_five_h + prev_pitcher.h
          if opposite
            game_five_opp_ip.push(opposite.ip)
            game_five_opp_bb = game_five_opp_bb + opposite.bb.to_i
            game_five_opp_h = game_five_opp_h + opposite.h.to_i
          end
        end
        if index < 30
          game_six_ip.push(prev_pitcher.ip)
          game_six_bb = game_six_bb + prev_pitcher.bb
          game_six_h = game_six_h + prev_pitcher.h
          if opposite
            game_six_opp_ip.push(opposite.ip)
            game_six_opp_bb = game_six_opp_bb + opposite.bb.to_i
            game_six_opp_h = game_six_opp_h + opposite.h.to_i
          end
        end
        if index < 60
          game_seven_ip.push(prev_pitcher.ip)
          game_seven_bb = game_seven_bb + prev_pitcher.bb
          game_seven_h = game_seven_h + prev_pitcher.h
          if opposite
            game_seven_opp_ip.push(opposite.ip)
            game_seven_opp_bb = game_seven_opp_bb + opposite.bb.to_i
            game_seven_opp_h = game_seven_opp_h + opposite.h.to_i
          end
        end
      end
      game_one_blue = ((game_one_bb + game_one_h) / add_innings(game_one_ip).to_f).round(2)
      game_one_blue_opp = ((game_one_opp_bb + game_one_opp_h) / add_innings(game_one_opp_ip).to_f).round(2)
      game_two_blue = ((game_two_bb + game_two_h) / add_innings(game_two_ip).to_f).round(2)
      game_two_blue_opp = ((game_two_opp_bb + game_two_opp_h) / add_innings(game_two_opp_ip).to_f).round(2)
      game_six_blue = ((game_six_bb + game_six_h) / add_innings(game_six_ip).to_f).round(2)
      game_six_blue_opp = ((game_six_opp_bb + game_six_opp_h) / add_innings(game_six_opp_ip).to_f).round(2)
      game_three_blue = ((game_three_bb + game_three_h) / add_innings(game_three_ip).to_f).round(2)
      game_three_blue_opp = ((game_three_opp_bb + game_three_opp_h) / add_innings(game_three_opp_ip).to_f).round(2)
      game_four_blue = ((game_four_bb + game_four_h) / add_innings(game_four_ip).to_f).round(2)
      game_four_blue_opp = ((game_four_opp_bb + game_four_opp_h) / add_innings(game_four_opp_ip).to_f).round(2)
      game_five_blue = ((game_five_bb + game_five_h) / add_innings(game_five_ip).to_f).round(2)
      game_five_blue_opp = ((game_five_opp_bb + game_five_opp_h) / add_innings(game_five_opp_ip).to_f).round(2)
      game_seven_blue = ((game_seven_bb + game_seven_h) / add_innings(game_seven_ip).to_f).round(2)
      game_seven_blue_opp = ((game_seven_opp_bb + game_seven_opp_h) / add_innings(game_seven_opp_ip).to_f).round(2)
	    opposite = pitcher.game.lancers.find_by(starter: true, team_id: pitcher.opp_team.id)
      batters = Batter.none
      if opposite
        batters = opposite.opposing_lineup
        batters = opposite.predict_opposing_lineup if batters.empty?
      end
      batters = batters.select{ |batter| batter.player }
      season_one = Season.find_by(year: 2019)
      season_two = Season.find_by(year: 2020)
      stats_one = batters.map { |batter| batter.player.create_batter(season_one).stats(handedness(opposite.throwhand == "L")) }
      stats_two = batters.map { |batter| batter.player.create_batter(season_two).stats(handedness(opposite.throwhand == "L")) }
      stats_three = batters.map { |batter| batter.stats(handedness(opposite.throwhand == "L")) }
      ab_two = stats_two.map {|stat| stat.ab }.sum
      ab_three = stats_three.map {|stat| stat.ab }.sum
      wrc_qu_one = stats_one.map {|stat| stat.ab > 70 ? stat.wrc : 0 }.sum
      qu_one = stats_one.map {|stat| stat.ab > 70 ? 1 : 0 }.sum
      wrc_qu_two = stats_two.map {|stat| stat.ab > 70 ? stat.wrc : 0 }.sum
      qu_two = stats_two.map {|stat| stat.ab > 70 ? 1 : 0 }.sum
      wrc_qu_three = stats_three.map {|stat| stat.ab > 70 ? stat.wrc : 0 }.sum
      qu_three = stats_three.map {|stat| stat.ab > 70 ? 1 : 0 }.sum
      so_two = stats_two.map {|stat| stat.so }.sum
      so_three = stats_three.map {|stat| stat.so }.sum
      bb_two = stats_two.map {|stat| stat.bb }.sum
      bb_three = stats_three.map {|stat| stat.bb }.sum
      ab_bb_two = stats_two.map {|stat| stat.ab + stat.bb }.sum
      ab_bb_three = stats_three.map {|stat| stat.ab + stat.bb }.sum
      tld_qu_one = stats_one.map {|stat| stat.ab > 70 ? stat.tld : 0 }.sum
      tld_qu_two = stats_two.map {|stat| stat.ab > 70 ? stat.tld : 0 }.sum
      tld_qu_three = stats_three.map {|stat| stat.ab > 70 ? stat.tld : 0 }.sum
      sb_two = stats_two.map {|stat| stat.sb }.sum
      sb_three = stats_three.map {|stat| stat.sb }.sum

      game_wrc_qu_one = wrc_qu_one.to_s + " / " + qu_one.to_s + " = " + (qu_one != 0 ? (wrc_qu_one.to_f / qu_one).round(1) : 0).to_s
      game_wrc_qu_one_opp = qu_one != 0 ? (wrc_qu_one.to_f / qu_one).round(1) : 0
      game_wrc_qu_two = wrc_qu_two.to_s + " / " + qu_two.to_s + " = " + (qu_two != 0 ? (wrc_qu_two.to_f / qu_two).round(1) : 0).to_s
      game_wrc_qu_two_opp = qu_two != 0 ? (wrc_qu_two.to_f / qu_two).round(1) : 0
      game_wrc_qu_three = wrc_qu_three.to_s + " / " + qu_three.to_s + " = " + (qu_three != 0 ? (wrc_qu_three.to_f / qu_three).round(1) : 0).to_s
      game_wrc_qu_three_opp = qu_three != 0 ? (wrc_qu_three.to_f / qu_three).round(1) : 0

      so_ab_two = so_two.to_s + " / " + ab_two.to_s + " = " + (ab_two != 0 ? (100 * so_two.to_f / ab_two).round(1) : 0).to_s
      so_ab_two_opp = ab_two != 0 ? (100 * so_two.to_f / ab_two).round(1) : 0
      so_ab_three = so_three.to_s + " / " + ab_three.to_s + " = " + (ab_three != 0 ? (100 * so_three.to_f / ab_three).round(1) : 0).to_s
      so_ab_three_opp = ab_three != 0 ? (100 * so_three.to_f / ab_three).round(1) : 0

      ab_bb_two_db = bb_two.to_s + " / " + ab_bb_two.to_s + " = " + (ab_bb_two != 0 ? (100 * bb_two.to_f / ab_bb_two).round(1) : 0).to_s
      ab_bb_two_opp = ab_bb_two != 0 ? (100 * bb_two.to_f / ab_bb_two).round(1) : 0
      ab_bb_three_db = bb_three.to_s + " / " + ab_bb_three.to_s + " = " + (ab_bb_three != 0 ? (100 * bb_three.to_f / ab_bb_three).round(1) : 0).to_s
      ab_bb_three_opp = ab_bb_three != 0 ? (100 * bb_three.to_f / ab_bb_three).round(1) : 0

      tld_hitter_one = qu_one != 0 ? (tld_qu_one.to_f / qu_one).round(1) : 0
      tld_hitter_two = qu_two != 0 ? (tld_qu_two.to_f / qu_two).round(1) : 0
      tld_hitter_three = qu_three != 0 ? (tld_qu_three.to_f / qu_three).round(1) : 0
      Pitcherinformation.create(
        game_id: game.id,
        away: away,
        ip_two: ip_two,
        ip_three: ip_three,
        gb_two: gb_two,
        gb_three: gb_three,
        woba_two: woba_two,
        woba_three: woba_three,
        fip_two: fip_two,
        fip_three: fip_three,
        tld_two: tld_two,
        tld_three: tld_three,
        game_one_blue: game_one_blue,
        game_one_blue_opp: game_one_blue_opp,
        game_two_blue: game_two_blue,
        game_two_blue_opp: game_two_blue_opp,
        game_six_blue: game_six_blue,
        game_six_blue_opp: game_six_blue_opp,
        game_three_blue: game_three_blue,
        game_three_blue_opp: game_three_blue_opp,
        game_four_blue: game_four_blue,
        game_four_blue_opp: game_four_blue_opp,
        game_five_blue: game_five_blue,
        game_five_blue_opp: game_five_blue_opp,
        game_seven_blue: game_seven_blue,
        game_seven_blue_opp: game_seven_blue_opp,
        sb_two: sb_two,
        ab_two: ab_two,
        sb_three: sb_three,
        ab_three: ab_three,
        game_wrc_qu_one: game_wrc_qu_one,
        game_wrc_qu_one_opp: game_wrc_qu_one_opp,
        game_wrc_qu_two: game_wrc_qu_two,
        game_wrc_qu_two_opp: game_wrc_qu_two_opp,
        game_wrc_qu_three: game_wrc_qu_three,
        game_wrc_qu_three_opp: game_wrc_qu_three_opp,
        so_ab_two: so_ab_two,
        so_ab_two_opp: so_ab_two_opp,
        so_ab_three: so_ab_three,
        so_ab_three_opp: so_ab_three_opp,
        ab_bb_two: ab_bb_two_db,
        ab_bb_two_opp: ab_bb_two_opp,
        ab_bb_three: ab_bb_three_db,
        ab_bb_three_opp: ab_bb_three_opp,
        tld_hitter_one: tld_hitter_one,
        tld_hitter_two: tld_hitter_two,
        tld_hitter_three: tld_hitter_three
      )
    end

    def get_prev_pitchers(game, prev_pitchers, away)
      prev_pitchers.each_with_index do |pitcher, index|
        opposite = pitcher.game.lancers.find_by(starter: true, team_id: pitcher.opp_team.id)
        weather = pitcher.game.weathers.find_by(hour: 1, station: "Actual")
        start_index = index
        date = pitcher.game.game_day.date_string
        time = DateTime.parse(pitcher.game.game_date).strftime("%I:%M%p")
        opp_team_abbr = pitcher.opp_team.baseball_abbr if pitcher.opp_team
        ip = pitcher.ip
        bb = pitcher.bb
        h = pitcher.h
        r = pitcher.r
        home_team_abbr = pitcher.game.home_team.baseball_abbr

        if weather
          temp = weather.temp
          dp = weather.dp
          wind_speed = weather.wind_speed
          wind_dir = weather.wind_dir
          d2 = d2_calc(pitcher.game.home_team.baseball_abbr, weather.wind_dir)
          pressure = weather.pressure
          hum = weather.hum
          humid_max = weather.humid_num + 3
          humid_min = weather.humid_num - 3
          if DateTime.parse(pitcher.game.game_date).hour > 18
            humid_min = humid_min + 2
            humid_max = humid_max + 2
          end
          result = true_data_pitcher((weather.temp_num - 5).round(1), (weather.temp_num + 5).round(1), (weather.dew_num - 2).round, (weather.dew_num + 2).round, humid_min.round, humid_max.round, (weather.pressure_num - 0.04).round(2), (weather.pressure_num + 0.04).round(2), pitcher.game.home_team.name)
          total_count = result[:total_count]
          total_avg_1 = result[:total_avg_1]
          total_avg_2 = result[:total_avg_2]
          total_hits_avg = result[:total_hits_avg]
          home_runs_avg = result[:home_runs_avg]
          lower_one = result[:lower_one]
          lower_one_count = result[:lower_one_count]
          home_total_runs1_avg = result[:home_total_runs1_avg]
          home_total_runs2_avg = result[:home_total_runs2_avg]
          home_count = result[:home_count]
          home_one = result[:home_one]
          home_one_count = result[:home_one_count]
        end
        if opposite
          opposite_throwhand = opposite.throwhand
          opposite_name = opposite.name
          opposite_ip = opposite.ip
          opposite_bb = opposite.bb
          opposite_h = opposite.h
          opposite_r = opposite.r
        end
        Prevpitcher.create(
          game_id: game.id,
          away: away,
          start_index: start_index,
          date: date,
          time: time,
          opp_team_abbr: opp_team_abbr,
          ip: ip,
          bb: bb,
          h: h,
          r: r,
          home_team_abbr: home_team_abbr,
          temp: temp,
          dp: dp,
          wind_speed: wind_speed,
          wind_dir: wind_dir,
          d2: d2,
          pressure: pressure,
          hum: hum,
          total_count_count: total_count,
          total_avg_1_avg_1: total_avg_1,
          total_avg_2: total_avg_2,
          total_hits_avg: total_hits_avg,
          home_runs_avg: home_runs_avg,
          lower_one: lower_one,
          lower_one_count: lower_one_count,
          home_total_runs1_avg: home_total_runs1_avg,
          home_total_runs2_avg: home_total_runs2_avg,
          home_count: home_count,
          home_one: home_one,
          home_one_count: home_one_count,
          opposite_throwhand: opposite_throwhand,
          opposite_name: opposite_name,
          opposite_ip: opposite_ip,
          opposite_bb: opposite_bb,
          opposite_h: opposite_h,
          opposite_r: opposite_r
        )
      end
    end

    def parse_identity(element)
      href = element.children[0]['href']
      href = element.children[1]['href'] if href == nil
      href[href.rindex("/")+1..-1] if href
    end

    def parse_name(element)
      href = element.children[0]['href']
      href = element.children[1]['href'] if href == nil
      href = href.gsub('_', 'stats/_')
      puts href
      doc = download_document(href)
      names = doc.css('.PlayerHeader__Name span')
      names[0].text + ' ' + names[1].text
    end

    def parse_hand(element)
      href = element.children[0]['href']
      href = element.children[1]['href'] if href == nil
      doc = download_document(href)
      return unless doc
      info = doc.css('.PlayerHeader__Bio_List li:nth-child(3) .fw-medium div')[0].text
      # hand = ''
      # if info.children.size > 2
      #   info = info.children[1].text
      #   info_index = info.index('Throws: ')
      #   hand = info[info_index + 8]
      # end
      info.split('/')[1][0]
    end

    def team_pitchers(game, team, pitchers)
      pitcher_size = pitchers.children.size
      return if pitcher_size == 3 && pitchers.children[1].children[0].children.size == 1
      pitchers.children[1..-2].each_with_index do |pitcher, index|
        row = pitcher.children[0]
        hand = parse_hand(row.children[0])
        name = parse_name(row.children[0])
        identity = parse_identity(row.children[0])
        ip = row.children[1].text.to_f
        h = row.children[2].text.to_i
        r = row.children[3].text.to_i
        er = row.children[4].text.to_i
        bb = row.children[5].text.to_i
        k = row.children[6].text.to_i
        # pc = row.children[7].text.split('-')[0].to_i
        player = Player.search(name, identity, 0)
        unless player
          puts "Player #{name} not found"
          return
        end
        lancer = game.lancers.where(starter: true).find_by(player: player)
        unless lancer
          lancer = player.create_lancer(game.game_day.season, team, game)
          if index == 0
            lancer.update(starter: true)
          end
        end
        lancer.update(ip: ip, h: h, r: r, bb: bb)
        pitcher = game.pitchers.find_or_create_by(index: index, team: team)
        pitcher.update(name: name, hand: hand, identity: identity, ip: ip, h: h, r: r, bb: bb, er: er, k: k)
      end
    end

    def parse_fangraph_id(element)
      href = element.child['href']
      if href
        first = href.index('=') + 1
        last = href.index('&')
        return href[first...last]
      end
    end

    def get_handedness(url_index)
      handedness = nil
      case url_index
        when 0
          handedness = "L"
        when 1
          handedness = "R"
        when 2
          handedness = ""
      end
      return handedness
    end

    def mixed_statistic_ip(lefty_stat, righty_stat)
      decimal = ((lefty_stat - lefty_stat.to_i)*10).round() + ((righty_stat - righty_stat.to_i)* 10).round()
      sum = lefty_stat.to_i + righty_stat.to_i
      sum = sum * 3 + decimal
      return "#{(sum/3).to_i}.#{(sum%3).to_i}"
    end


    def mixed_statistic(lefty_stat, righty_stat, num_lefty, num_righty)
      if num_lefty + num_righty == 0
        0
      elsif lefty_stat == nil || righty_stat == nil
        0
      else
        ((lefty_stat * num_lefty + righty_stat * num_righty)/(num_lefty + num_righty)).round(2)
      end
    end
  end
end

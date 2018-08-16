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
        rows = doc.css("tr.oddrow, tr.evenrow")
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

    private

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
        result = {}
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
          total_count: total_count,
          total_avg_1: total_avg_1,
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
      href = element.child['href']
      href[36..href.rindex("/") - 1]
    end

    def parse_name(element)
      if element.child['href']
        href = element.child['href']
        doc = download_document(href)
        doc.css("h1").first.text
      end
    end

    def team_pitchers(game, team, pitcher)
      pitcher_size = pitcher.children.size
      return if pitcher_size == 3 && pitcher.children[1].children[0].children.size == 1
      row = pitcher.children[1].children[0]
      name = parse_name(row.children[0])
      identity = parse_identity(row.children[0])
      ip = row.children[1].text.to_f
      h = row.children[2].text.to_i
      r = row.children[3].text.to_i
      bb = row.children[5].text.to_i
      player = Player.search(name, identity)
      unless player
        puts "Player #{name} not found"
        return
      end
      lancer = game.lancers.where(starter: true).find_by(player: player)
      unless lancer
        lancer = player.create_lancer(game.game_day.season, team, game)
        lancer.update(starter: true)
      end
      lancer.update(ip: ip, h: h, r: r, bb: bb)
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

  end
end

module Update
  class Pitchers

    include GetHtml

    def update(season, team)
      year = season.year
      puts "Update #{team.name} #{year} Pitchers"

      (0..1).each do |rost|
        url = "http://www.fangraphs.com/leaders.aspx?pos=all&stats=pit&lg=all&qual=0&type=1&season=#{year}&month=0&season1=#{year}&ind=0&team=#{team.fangraph_id}&rost=#{rost}&age=0&filter=&players=0&page=1_50"
        doc = download_document(url)
        puts url
        index = { name: 1, fip: 11+rost, siera: 15+rost }
        doc.css(".grid_line_regular").each_slice(16+rost) do |slice|
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
          index = { name: 1, ld: 2 + rost, whip: 3 + rost, ip: 4 + rost, so: 5 + rost, bb: 6 + rost, era: 7 + rost, fb: 8 + rost, xfip: 9 + rost,
            kbb: 10 + rost, woba: 11 + rost, gb: 12 + rost, h: 13 + rost }
          doc.css(".grid_line_regular").each_slice(14+rost) do |slice|
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
            woba = (slice[index[:woba]].text.to_f*1000).to_i
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
        name = ld = whip = ip = so = bb = siera = nil
        index = { name: 1, ld: 2 + rost, whip: 3 + rost, ip: 4 + rost, so: 5 + rost, bb: 6 + rost, siera: 7 + rost }
        doc.css(".grid_line_regular").each_slice(8+rost) do |slice|
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

    private

      def parse_identity(element)
        href = element.child['href']
        href[36..href.rindex("/")-1]
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
        ip = row.children[1].text.to_i
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
          first = href.index('=')+1
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

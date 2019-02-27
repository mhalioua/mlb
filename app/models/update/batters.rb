module Update
  class Batters

    include GetHtml

    def update(season, team)
      year = season.year
      puts "Update #{team.name} #{year} Batters"
      url = "http://www.espn.com/mlb/team/stats/batting/_/name/#{team.espn_abbr}/year/#{year}"
      puts url

      doc = download_document(url)
      rows = doc.css("tr.oddrow, tr.evenrow")

      rows.each_with_index do |element, index|
        next if element.children.size == 1
        name = element.children[0].child.text
        identity = parse_identity(element.children[0])
        ops = element.children[16].text
        player = Player.search(name, identity)
        if player
          batter = player.create_batter(season)
          batter.stats.each do |stat|
            if stat.handedness.size > 0
              stat.update_attributes(ops: ops)
            end
          end
        end
      end

      (1..1).each do |rost|
        url_l = "http://www.fangraphs.com/leaders.aspx?pos=all&stats=bat&lg=all&qual=0&type=c,5,21,14,16,38,37,50,54,43,44,45&season=#{year}&month=13&season1=#{year}&ind=0&team=#{team.fangraph_id}&rost=#{rost}&age=0&filter=&players=0&page=1_50"
        url_r = "http://www.fangraphs.com/leaders.aspx?pos=all&stats=bat&lg=all&qual=0&type=c,5,21,14,16,38,37,50,54,43,44,45&season=#{year}&month=14&season1=#{year}&ind=0&team=#{team.fangraph_id}&rost=#{rost}&age=0&filter=&players=0&page=1_50"
        url_14 = "http://www.fangraphs.com/leaders.aspx?pos=all&stats=bat&lg=all&qual=0&type=c,5,21,14,16,38,37,50,61,43,44,45&season=#{year}&month=2&season1=#{year}&ind=0&team=#{team.fangraph_id}&rost=#{rost}&age=0&filter=&players=0&page=1_50"
        urls = [url_l, url_r, url_14]
        urls.each_with_index do |url, url_index|
          puts url
          doc = download_document(url)
          next unless doc
          index = { name: 1, ab: 2 + rost, sb: 3 + rost, bb: 4 + rost, so: 5 + rost, slg: 6 + rost, obp: 7 + rost, woba: 8 + rost,
            wrc: 9 + rost, ld: 10 + rost, gb: 11 + rost, fb: 12 + rost }

          doc.css(".grid_line_regular").each_slice(13+rost) do |slice|
            name = slice[index[:name]].text
            fangraph_id = parse_fangraph_id(slice[index[:name]])
            player = Player.search(name, nil, fangraph_id)
            unless player
              puts "Player #{name} not found" 
              next
            end
            ab = slice[index[:ab]].text.to_i
            sb = slice[index[:sb]].text.to_i
            bb = slice[index[:bb]].text.to_i
            so = slice[index[:so]].text.to_i
            slg = (slice[index[:slg]].text.to_f*1000).to_i
            obp = (slice[index[:obp]].text.to_f*1000).to_i
            woba = (slice[index[:woba]].text.to_f*1000).to_i
            wrc = slice[index[:wrc]].text.to_i
            ld = slice[index[:ld]].text[0...-2].to_f
            gb = slice[index[:gb]].text[0...-2].to_f
            fb = slice[index[:fb]].text[0...-2].to_f
            handedness = get_handedness(url_index)
            batter = player.create_batter(season)
            batter_stat = batter.stats.where(handedness: handedness).first
            batter_stat.update_attributes(ab: ab, sb: sb, bb: bb, so: so, slg: slg, obp: obp, woba: woba, wrc: wrc, ld: ld, gb: gb, fb: fb)
          end
        end
      end
    end

    def scout(season, team)
      year = season.year
      puts "Update #{team.name} #{year} Batters Scout"

      (1..1).each do |rost|
        url = "http://www.fangraphs.com/leaders.aspx?pos=all&stats=bat&lg=all&qual=0&type=21&season=#{year}&month=0&season1=#{year}&ind=0&team=#{team.fangraph_id}&rost=#{rost}&age=0&filter=&players=0&page=1_50"
        doc = download_document(url)
        puts url
        next unless doc
        index = { name: 1, pa: 2+rost, fa: 3+rost, fc: 4+rost, fs: 5+rost, si: 6+rost, ch: 7+rost, sl: 8+rost, cu: 9+rost }
        doc.css(".grid_line_regular, .grid_line_break").each_slice(13+rost) do |slice|
          name = slice[index[:name]].text
          fangraph_id = parse_fangraph_id(slice[index[:name]])
          player = Player.search(name, nil, fangraph_id)
          unless player
            puts "Player " + name + " not found" 
            next
          end
          if player
            scout = BatterScouting.find_or_create_by(player_id: player.id, team: team, season: season)
            scout.update(
              PA: slice[index[:pa]].text,
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

        batters = doc.css('.stats-wrap')
        next if batters.size < 4

        away_batter = batters[0]
        home_batter = batters[2]

        team_batters(game, game.away_team, away_batter)
        team_batters(game, game.home_team, home_batter)

        batters = doc.css('.team-stats-container')
        next if batters.size < 4
        next if batters[0].children[0].children.length == 0

        away_batter = batters[0].children[0].children[0].children[1..-1]
        home_batter = batters[2].children[0].children[0].children[1..-1]

        team_batter_hr(game, game.away_team, away_batter)
        team_batter_hr(game, game.home_team, home_batter)
      end
    end

    private

      def team_batter_hr(game, team, hitters)
        hitters.each do |hitter|
          if hitter.children[0].text == 'HR:'
            b = hitter.children[1].text
            b = b.gsub(/\((.*?)\)/, '')
            b = b.split('; ')
            b.each do |eachb|
              eachb_index = eachb.index(' ')
              sub_name = eachb[0..eachb_index-1].squish
              sub_name = sub_name.gsub('á', 'a')
              sub_name = sub_name.gsub('í', 'i')
              sub_name = sub_name.gsub('é', 'e')
              sub_name = sub_name.gsub('ñ', 'n')
              sub_name = sub_name.gsub('ó', 'o')
              sub_name = sub_name.gsub('ú', 'u')
              sub_name = sub_name.gsub(/(.*?)\'/, '')
              hitter = game.hitters.where("team_id = ? AND name LIKE '%" + sub_name + "%'", team.id).first
              hitter.update(hr: 1) if hitter
            end
            break
          end
        end
      end

      def team_batters(game, team, hitters)
        return if hitters.children[1].children[0].children.size == 1
        hitters.children[1..-1].each_with_index do |hitter, index|
          row = hitter.children[0]
          name = row.children[0].children[0].text.squish
          return if name == "TEAM"
          if name == 'a -' || name == 'b -' || name == 'c -' || name == 'd -' || name == 'e -' || name == 'f -'
            name = row.children[0].children[1].text.squish
            position = row.children[0].children[2].text.squish
            hand = parse_hand(row.children[0].children[1])
          else
            position = row.children[0].children[1].text.squish
            hand = parse_hand(row.children[0].children[0])
          end
          name = '  ' + name if row.children[0]['class'].include?('bench')
          ab = row.children[2].text.to_i
          r = row.children[3].text.to_i
          h = row.children[4].text.to_i
          rbi = row.children[5].text.to_i
          bb = row.children[6].text.to_i
          k = row.children[7].text.to_i
          avg = row.children[9].text
          hitter = game.hitters.find_or_create_by(index: index, team: team)
          hitter.update(name: name, position: position, hand: hand, ab: ab, h: h, r: r, rbi: rbi, bb: bb, avg: avg, hr: 0, k: k)
        end
      end

      def parse_identity(element)
        href = element.child['href']
        href[href.rindex("/")+1..-1] if href
      end

      def parse_hand(element)
        if element['href']
          href = element['href']
          doc = download_document(href)
          return unless doc
          info = doc.css('.general-info')
          hand = ''
          if info.children.size > 2
            info = info.children[1].text
            info_index = info.index('Bats: ')
            hand = info[info_index + 6]
          end
          return hand
        end
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

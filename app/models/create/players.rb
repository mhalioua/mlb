module Create
  class Players
    include GetHtml

    def create(team)
      puts "Create #{team.name} Players"
      url = "http://www.espn.com/mlb/team/roster/_/name/#{team.espn_abbr}"
      puts url

      doc = download_document(url)
      rows = doc.css("tbody tr")

      rows.each do |element|
        name = element.children[1].children[0].children[0].text
        identity = parse_identity(element.children[1].children[0].children[0])
        player_number = element.children[1].children[0].children[1].text
        puts player_number
        bathand = element.children[3].text
        throwhand = element.children[4].text
        age = element.children[5].text
        unless player = Player.search(name, identity, 0, team.id)
          player = Player.create(name: name, identity: identity)
          puts "Player " + player.name + " created"
        end
        player.update(team: team, bathand: bathand, throwhand: throwhand, age: age, player_number: player_number)
      end
    end

    def fangraphs(team)
      url = "http://www.fangraphs.com/depthcharts.aspx?position=ALL&teamid=#{team.fangraph_id}"
      doc = download_document(url)
      doc.css(".depth_chart:nth-child(58) td").each_with_index do |stat, index|
        case index%10
        when 0
          name = stat.child.child.to_s
          unless name.size == 0
            fangraph_id = parse_fangraph_id(stat)
            player = Player.search(name, nil, fangraph_id)
            unless player
              player = Player.create(name: name, fangraph_id: fangraph_id)
            end
            player.update_attributes(fangraph_id: fangraph_id, team: team)
          end
        end
      end

      doc.css(".depth_chart:nth-child(76) td").each_with_index do |stat, index|
        case index%10
        when 0
          name = stat.child.child.to_s
          unless name.size == 0
            fangraph_id = parse_fangraph_id(stat)
            player = Player.search(name, nil, fangraph_id)
            unless player
              player = Player.create(name: name, fangraph_id: fangraph_id)
            end
            player.update_attributes(fangraph_id: fangraph_id, team: team)
          end
        end
      end
    end

    def getPlayerNumber(team)
      puts "Get #{team.name} MLB Player Number"
      url = "https://www.mlb.com/#{team.mlb_abbr}/roster"
      puts url

      doc = download_document(url)
      rows = doc.css('tr')
      rows.each_with_index do |element, index|
        player_number = element.children[1].text.to_i
        next if player_number === 0
        player = Player.find_by(name: element.children[5].text.squish, team: team)
        player.update(player_number: player_number) if player
      end
    end

    def getMlbId(team)
      puts "Get #{team.name} MLB IDs"
      url = "http://m.#{team.mlb_abbr}.mlb.com/roster"
      puts url

      doc = download_document(url)
      rows = doc.css('td.dg-name_display_first_last a')
      rows.each_with_index do |element, index|
        indexes = element['href'].split('/')
        next if indexes.length < 2
        player = Player.find_by(name: element.text)
        if player
          mlb_id = indexes[indexes.length-1] + '-' + indexes[indexes.length-2]
          player.update(mlb_id: mlb_id)
          player_mlb_url = "https://baseballsavant.mlb.com/savant-player/#{mlb_id}?stats=career-r-pitching-mlb"
          puts player_mlb_url

          doc = download_document(player_mlb_url)
          next unless doc
          relies = doc.css('#player-award-items').first.text
          descriptions = doc.css('#div_career p')
          description = ''
          descriptions.each do |description_element|
            description = description + description_element.text
          end
          player_scout = PlayerScout.find_or_create_by(player: player)
          player_scout.update(relies: relies, description: description)

          scouts = doc.css("#statcast_pitching tbody tr")
          scouts.each_with_index do |scout, index|
            element = player_scout.scouts.find_or_create_by(row_index: index)
            element.update(season: scout.children[1].text,
              pitches: scout.children[3].text,
              batted_balls: scout.children[5].text,
              barrels: scout.children[7].text,
              barrel: scout.children[9].text,
              exit_velocity: scout.children[11].text,
              launch_angle: scout.children[13].text,
              xba: scout.children[15].text,
              xslg: scout.children[17].text,
              xwoba: scout.children[19].text,
              woba: scout.children[21].text,
              hard_hit: scout.children[23].text)
          end
        end
      end
    end

  private

    def parse_identity(element)
      href = element['href']
      href[href.rindex("/")+1..-1] if href
    end

    def parse_fangraph_id(element)
      href = element.child['href']
      if href
        first = href.index('=')+1
        last = href.index('&')
        return href[first...last]
      end
    end
  end
end

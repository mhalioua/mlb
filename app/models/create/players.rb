module Create
  class Players
    include GetHtml

    def create(team)
      puts "Create #{team.name} Players"
      url = "http://www.espn.com/mlb/team/roster/_/name/#{team.espn_abbr}"
      puts url

      doc = download_document(url)
      rows = doc.css("tr.oddrow, tr.evenrow")

      is_pitcher = true
      rows.each_with_index do |element, index|
        next if element.children.size == 1
        next unless element.children[1].child.child
        puts element.inspect
        name = element.children[1].child.text
        identity = parse_identity(element.children[1])
        bathand = element.children[3].text
        throwhand = element.children[4].text
        age = element.children[5].text
        puts name
        puts identity
        puts bathand
        puts throwhand
        if false
          player = Player.find_or_create_by(name: name, identity: identity)
          player.update(team: team, bathand: bathand, throwhand: throwhand, age: age)
        end
      end
    end

    def fangraphs(team)
      url = "http://www.fangraphs.com/depthcharts.aspx?position=ALL&teamid=#{team.fangraph_id}"
      doc = Nokogiri::HTML(open(url))
      doc.css(".depth_chart:nth-child(58) td").each_with_index do |stat, index|
        case index%10
        when 0
          name = stat.child.child.to_s
          unless name.size == 0
            fangraph_id = parse_fangraph_id(stat)
            player = Player.find_by(name: name)
            if player
              puts name if player.fangraph_id != nil
              player.update(fangraph_id: fangraph_id)
            else
              puts "Player " + name + " not found"
            end
          end
        end
      end

      doc.css(".depth_chart:nth-child(76) td").each_with_index do |stat, index|
        case index%10
        when 0
          name = stat.child.child.to_s
          unless name.size == 0
            fangraph_id = parse_fangraph_id(stat)
            player = Player.find_by(name: name)
            if player
              puts name if player.fangraph_id != nil
              player.update(fangraph_id: fangraph_id)
            else
              puts "Player " + name + " not found"
            end
          end
        end
      end
    end

  private

    def parse_identity(element)
      href = element.child['href']
      href[37..href.rindex("/")-1]
    end

    def parse_fangraph_id(element)
      href = element.child['href']
      if href
        first = href.index('=')+1
        last = href.index('&')
        return href[first...last].to_i
      end
    end
  end
end

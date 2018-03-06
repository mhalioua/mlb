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
        name = element.children[1].child.text
        identity = parse_identity(element.children[1])
        bathand = element.children[3].text
        throwhand = element.children[4].text
        age = element.children[5].text
        player = Player.find_or_create_by(name: name, identity: identity)
        player.update(team: team, bathand: bathand, throwhand: throwhand, age: age)
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

    def update
      @additional_fangraph_id.each do |key, index|
        player = Player.find_by(name: key, fangraph_id: nil)
        player.update(fangraph_id: index) if player
      end
    end

  private

    def parse_identity(element)
      href = element.child['href']
      href[36..href.rindex("/")-1]
    end

    def parse_fangraph_id(element)
      href = element.child['href']
      if href
        first = href.index('=')+1
        last = href.index('&')
        return href[first...last]
      end
    end

    @additional_fangraph_id = {
      "Eric Stout" => "sa829070",
      "Phillippe Aumont" => "5362",
      "Hector Mendoza" => "sa863882",
      "Daniel Poncedeleon" => "sa549749",
      "Jordan Schafer" => "9883",
      "Sam Tuivailala" => "13485",
      "Matthew Boyd" => "15440",
      "Jake Woodford" => "sa874753",
      "Dylan Baker" => "sa658002",
      "Jeremy Martinez" => "sa738674",
      "Dennis Ortega" => "sa828381",
      "Max Schrock" => "sa658670",
      "JT Riddle" => "17642",
      "Merandy Gonzalez" => "sa737381",
      "Jairo Labourt" => "14996",
      "Ian Clarkin" => "sa737534",
      "Seung-Hwan Oh" => "18719",
      "Cameron Perkins" => "13444",
      "Micker Adolfo" => "sa830303",
      "Luis Alexander Basabe" => "sa736915",
      "Nicky Delmonico" => "13157",
      "AJ Reed" => "16246",
      "Yuli Gurriel" => "19198",
      "Lance McCullers Jr." => "14120",
      "Daniel Vogelbach" => "14130",
      "Kazuhisa Makita" => "",
      "Anthony Gose" => "5097",
      "Javy Guerra" => "7407",
      "Nicholas Castellanos" => "11737",
      "Jeff Thompson" => "sa707780",
      "Chasen Bradford" => "12452",
      "Corban Joseph" => "5503",
      "Nic Perkins" => "sa3004610",
      "Kelvin Gutierrez" => "sa736855",
      "Michael A. Taylor" => "11489",
      "Pedro Araujo" => "sa597206",
      "Jefry Rodriguez" => "sa657760",
      "AJ Ramos" => "8350",
      "Marcos Molina" => "sa657917",
      "Greg Bird" => "14131",
      "Brent Honeywell" => "sa828706",
      "Ricky Rodriguez" => "sa977119",
      "Joe Palumbo" => "sa738453",
      "Adonis Rosa" => "sa828513",
      "Jonathan Loaisiga" => "sa737372",
      "Oscar De La Cruz" => "sa737037",
      "Dan Winkler" => "12237",
      "Lucas Sims" => "13470",
      "Josh Ravin" => "2951",
      "Grant Dayton" => "11203",
      "Jose Lopez" => "sa709715",
      "Jesus Reyes" => "sa877345",
      "Alex Meyer" => "12833",
      "Jose Ramirez" => "13510",
      "Yu-Cheng Chang" => "sa830276",
      "Yoshihisa Hirano" => "",
      "Domingo Leyba" => "sa736654",
      "Willi Castro" => "sa830274",
      "Ranger Suarez" => "sa659551",
      "Mark Leiter Jr." => "15551",
      "Chris Rabago" => "sa829062",
      "Aramis Garcia" => "sa599195",
      "Franklyn Kilome" => "sa830592",
      "Seranthony Dominguez" => "sa657573",
      "Yonathan Daza" => "sa597083",
      "Jake Junis" => "13619",
      "Nate Karns" => "12638"
    }
  end
end

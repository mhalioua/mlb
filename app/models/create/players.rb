module Create
  class Players
    include GetHtml

    def create(team)
      puts "Create #{team.name} Players"
      url = "http://www.espn.com/mlb/team/roster/_/name/#{team.espn_abbr}"
      puts url

      doc = download_document(url)
      rows = doc.css("tbody tr")
      puts row.length

      rows.each do |element|
        name = element.children[1].children[0].children[0].text
        identity = parse_identity(element.children[1].children[0].children[0])
        bathand = element.children[3].text
        throwhand = element.children[4].text
        age = element.children[5].text
        unless player = Player.search(name, identity)
          player = Player.create(name: name, identity: identity)
          puts "Player " + player.name + " created"
        end
        puts bathand
        puts throwhand
        puts age
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
            player = Player.search(name, nil, fangraph_id)
            if player
              player.update_attributes(fangraph_id: fangraph_id)
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
            player = Player.search(name, nil, fangraph_id)
            if player
              player.update_attributes(fangraph_id: fangraph_id)
            else
              puts "Player " + name + " not found"
            end
          end
        end
      end
    end

    def update_fangraphs
      urls = [
        'https://www.fangraphs.com/minorleaders.aspx?pos=all&stats=bat&lg=all&qual=0&type=0&season=2018&team=0&players=0&page=1_6000',
        'https://www.fangraphs.com/minorleaders.aspx?pos=all&stats=pit&lg=all&qual=0&type=0&season=2018&team=0&players=0&page=1_5000'
      ]
      count = 23
      urls.each do |url|
        puts url
        doc = download_document(url)
        doc.css(".grid_line_regular").each_slice(count) do |slice|
          name = slice[0].text
          fangraph_id = parse_fangraph_id(slice[0])
          puts name
          puts fangraph_id
          player = Player.search(name, nil, fangraph_id)
          if player
            player.update_attributes(fangraph_id: fangraph_id)
          else
            puts "Player " + name + " not found"
          end
        end
        count = 25
      end
    end

    def update
      @@additional_fangraph_id.each do |key, index|
        player = Player.find_by(name: key, fangraph_id: nil)
        player.update(fangraph_id: index) if player
      end
    end

    def getPlayerNumber(team)
      puts "Get #{team.name} MLB Player Number"
      url = "http://m.#{team.mlb_abbr}.mlb.com/roster"
      puts url

      doc = download_document(url)
      rows = doc.css('tr')
      rows.each_with_index do |element, index|
        player_number = element.children[1].text.to_i
        next if player_number === 0
        player = Player.find_by(name: element.children[5].text.squish)
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

    @@additional_fangraph_id = {
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
      "Nate Karns" => "12638",
      "Mike Ahmed" => "sa705802",
      "Mitchell Walding" => "sa597901",
      "Jeckson Flores" => "sa597007",
      "Xavier Fernandez" => "sa737922",
      "Wes Darvill" => "sa501490",
      "Jacob Faria" => "13699",
      "Thomas Eshelman" => "sa874778",
      "Nicholas Pivetta" => "15454",
      "Zach Coppola" => "sa875612",
      "Norichika Aoki" => "13075",
      "Harold Ramírez" => "sa660586",
      "Bryan Harper" => "sa549768",
      "Phil Pfeifer" => "sa602699",
      "CC Lee" => "5177",
      "TJ House" => "9121",
      "LJ Mazzilli" => "sa577753",
      "Casey Crosby" => "5261",
      "Robert Zarate" => "sa471754",
      "Miguel González" => "7024",
      "Dwight Smith Jr." => "13473",
      "Adolis Garcia" => "sa908695",
      "Jorge De La Rosa" => "2047",
      "John Mayberry Jr." => "3390",
      "Nicholas Ciuffo" => "sa737509",
      "Troy Stokes" => "sa828871",
      "Russell Wilson" => "sa548305",
      "Steven Geltz" => "8402",
      "Alexander De Goti" => "sa919320",
      "James Ramsey" => "sa599239",
      "Kris Negron" => "5306",
      "Jonathon Niese" => "4424",
      "Jonathan Singleton" => "10441",
      "Michael Snyder" => "sa658566",
      "Danny Dorn" => "1050",
      "Rickie Weeks" => "1849",
      "Jose Manuel Fernandez" => "sa724025",
      "Daniel Pinero" => "sa738204",
      "Matt Kent" => "sa875610",
      "Jonathan Harris" => "sa658929",
      "Fernando Rodriguez Jr." => "7558",
      "Gioskar Amaya" => "sa547898",
      "DJ Stewart" => "sa658672",
      "Stephen Perakslis" => "sa621679",
      "Jacob Robson" => "sa658804",
      "Bralin Jackson" => "sa658012",
      "Jack López" => "sa598270",
      "Donnie Dewees" => "sa858802",
      "Reymond Fuentes" => "10329",
      "José Fernández" => "11530",
      "Pat Cantwell" => "sa602546",
      "Alfredo Gutierrez" => "sa656043",
      "Bradin Hagens" => "7422",
      "Parker Markel" => "sa502751",
      "Colin Poché" => "sa657989",
      "Ed Easley" => "2487",
      "Elier Hernández" => "sa659238"
    }
  end
end

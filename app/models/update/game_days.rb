module Update
  require 'watir'

  class GameDays

    include GetHtml

    def get_roof(game_day)
      games = game_day.games
      url = "https://www.mlb.com/schedule/%d-%s-%02d" % [game_day.year, game_day.month, game_day.day]
      doc = download_document(url)
      puts url

      elements = doc.css(".gameinfo-gamedaylink")
      scores = []
      elements[0...games.length].each do |element|
        href = element['href']
        score = element.text
        score = score.gsub('CWS', 'CHW')
        scores.push({ :href => href, :score => score })
      end
      puts scores

      games.each do |game|
        next if game.postpone === true
        selected_score = scores.find { | score | score[:score].include?(game.home_team.espn_abbr) && score[:score].include?(game.away_team.espn_abbr)}
        puts game.game_id
        puts selected_score[:href]
        url = selected_score[:href]
        browser = Watir::Browser.new :phantomjs
        browser.goto url
        browser.div(css: ".box.game .info.gd-primary-regular").wait_until(&:present?).divs.each do |div|
          text = div.text
          if text.include?('Weather')
            game.update(roof: text.split(",")[0]) if text.include?('Roof')
            break
          end
        end
        browser.close
      end
    end
  end
end

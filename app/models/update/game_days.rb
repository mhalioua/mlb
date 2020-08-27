module Update
  class GameDays

    include GetHtml

    def get_roof(game_day)
      games = game_day.games
      url = "http://www.espn.com/mlb/schedule/_/date/%d-%s-%02d" % [game_day.year, game_day.month, game_day.day]
      doc = download_document(url)
      puts url

      elements = doc.css(".gameinfo-gamedaylink")
      elements = elements.slice(games.length)
      scores = []
      elements.each do |element|
        score = element.text
        score = score.gsub('CWS', 'CHW')
        scores.push({ :href => href, :score => score })
      end
      puts scores

      games.each do |game|
        selected_score = scores.find { | score | score[:score].include?(game.home_team.espn_abbr) && score[:score].include?(game.away_team.espn_abbr)}
        puts game.game_id
        puts selected_score.href
      end
    end
  end
end

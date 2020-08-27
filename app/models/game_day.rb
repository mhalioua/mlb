class GameDay < ApplicationRecord
  belongs_to :season
  has_many :games, dependent: :destroy

  def self.search(date)
    season = Season.find_by_year(date.year)
    return GameDay.find_or_create_by(season: season, date: date)
  end

  def year
    date.year
  end

  def month
    date.strftime("%m")
  end

  def day
    date.day
  end

  def self.yesterday
    GameDay.search(DateTime.now.in_time_zone('Eastern Time (US & Canada)').yesterday.to_date)
  end

  def self.today
    GameDay.search(DateTime.now.in_time_zone('Eastern Time (US & Canada)').to_date)
  end

  def self.tomorrow
    GameDay.search(DateTime.now.in_time_zone('Eastern Time (US & Canada)').tomorrow.to_date)
  end

  def create_matchups
    Create::Matchups.new.create(self)
  end

  def create_bullpen
    Create::Bullpen.new.create(self)
  end

  def prev_pitchers
    Update::Pitchers.new.prev(self)
  end

  def pitcher_informations
    Update::Pitchers.new.information(self)
  end

  def update_games
    Update::Games.new.update(self)
  end

  def pitcher_box_score
    Update::Pitchers.new.box_scores(self)
  end

  def batter_box_score
    Update::Batters.new.box_scores(self)
  end

  def play_by_play
    Update::Playbyplays.new.update(self)
  end

  def image_upload
    games.each do |game|
      #url = URI.parse("https://mlb-daemon.s3.amazonaws.com/images/#{game.id}.png")
      #http = Net::HTTP.new(url.host, url.port)
      #http.use_ssl = true if url.scheme == 'https'
      #unless http.request_head(url.path).code == "200"
      kit = IMGKit.new("https://mlb.herokuapp.com/game/new/#{game.id}/0/0/5", :quality => 50)
      file = kit.to_file("#{Rails.root}/tmp/game#{game.id}.png")
      obj = S3.object("images/#{game.id}.png")
      obj.upload_file(file, acl:'public-read')
      File.delete(file)
      puts "game #{game.id}"
      #end
    end
  end

  def get_roof
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

  def update_transactions
    Update::Transactions.new.update
  end

  def update_weather
    games.each { |game| game.update_weather }
  end

  def update_forecast
    games.each { |game| game.update_forecast }
  end

  def update_forecast_check
    games.each { |game| game.update_forecast_check }
  end

  def time
    Time.new(year, month, day)
  end

  def previous_days(num_days)
    prev_date = date.prev_day(num_days)
    GameDay.find_by_date(prev_date)
  end

  def next_days(num_days)
    next_day = date.next_day(num_days)
    GameDay.find_by_date(next_day)
  end

  def date_string
    "#{year}/#{month}/#{day}"
  end
end

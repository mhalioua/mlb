class GameDay < ApplicationRecord
  belongs_to :season
  has_many :games, dependent: :destroy

  def self.search(date)
    return GameDay.find_or_create_by(season: Season.find_by_year(date.year), date: date)
  end

  def year
    date.year
  end

  def month
    date.month
  end

  def day
    date.day
  end

  def self.yesterday
    GameDay.search(DateTime.now.yesterday.to_date)
  end

  def self.today
    GameDay.search(DateTime.now.to_date)
  end

  def self.tomorrow
    GameDay.search(DateTime.now.tomorrow.to_date)
  end

  def create_matchups
    Create::Matchups.new.create(self)
    Create::Bullpen.new.create(self)
  end

  def update_games
    Update::Games.new.update(self)
  end

  def pitcher_box_score
    Update::Pitchers.new.box_scores(self)
  end

  def time
    Time.new(year, month, day)
  end
end

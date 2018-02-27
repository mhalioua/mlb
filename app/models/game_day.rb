class GameDay < ApplicationRecord
  has_many :games, dependent: :destroy

  def self.search(date)
    return GameDay.find_or_create_by(season: Season.find_by_year(date.year), date: date)
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
end

class GameDay < ApplicationRecord
  belongs_to :season
  has_many :games, dependent: :destroy

  def self.search(date)
    return GameDay.find_or_create_by(date: date)
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
end

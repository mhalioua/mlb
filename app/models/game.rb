class Game < ApplicationRecord

  belongs_to :away_team, :class_name => 'Team'
  belongs_to :home_team, :class_name => 'Team'
  belongs_to :game_day
  has_many :weathers, dependent: :destroy
  has_many :lancers, dependent: :destroy
  has_many :batters, dependent: :destroy
  has_many :innings, dependent: :destroy
  has_many :pitcher_box_scores, dependent: :destroy
  has_many :hitter_box_scores, dependent: :destroy

  has_many :weathersources, dependent: :destroy

  def update_weather
    Update::Weathers.new.update(self)
  end

  def update_forecast
    Update::Forecasts.new.update(self)
  end

  def update_forecast_check
    Update::Forecasts.new.update_check(self)
  end

  def away_pitcher
    lancers.find_by(starter: true, team: away_team)
  end

  def home_pitcher
    lancers.find_by(starter: true, team: home_team)
  end
 
end

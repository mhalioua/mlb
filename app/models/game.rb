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
  
end

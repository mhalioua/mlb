class Team < ApplicationRecord
  has_many :players
  has_many :lancers
  has_many :batters
  has_many :pitcher_scoutings, dependent: :destroy
  has_many :batter_scoutings, dependent: :destroy

  def self.create_teams
    Create::Teams.create
  end
end

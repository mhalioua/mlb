class Team < ApplicationRecord
  has_many :players
  has_many :lancers
  has_many :batters
  has_many :pitcher_scoutings, dependent: :destroy
  has_many :batter_scoutings, dependent: :destroy

  def self.create_teams
    Create::Teams.create
  end

  def player_number
    player_creator = Create::Players.new
    player_creator.getPlayerNumber(self)
  end
end

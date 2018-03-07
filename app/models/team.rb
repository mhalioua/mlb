class Team < ApplicationRecord
  has_many :players
  has_many :lancers
  has_many :batters

  def self.create_teams
    Create::Teams.create
  end
end

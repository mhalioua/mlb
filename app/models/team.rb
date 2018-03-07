class Team < ApplicationRecord
  has_many :players
  has_many :lancers, dependent: :nullify
  has_many :batters, dependent: :nullify

  def self.create_teams
    Create::Teams.create
  end
end

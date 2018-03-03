class Team < ApplicationRecord
  has_many :players

  def self.create_teams
    Create::Teams.create
  end
end

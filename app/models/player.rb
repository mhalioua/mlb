class Player < ApplicationRecord
  belongs_to :team
  has_many :lancers, dependent: :destroy
  has_many :batters, dependent: :destroy

  def self.create_players
    player_creator = Create::Players.new
    teams = Team.all
    teams.each do |team|
      player_creator.create(team)
    end
  end

  def self.update_players
    player_creator = Create::Players.new
    teams = Team.all
    teams.each do |team|
      player_creator.fangraphs(team)
    end
  end
end

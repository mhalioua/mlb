class Season < ApplicationRecord
  has_many :game_days, dependent: :destroy
  has_many :lancers, dependent: :destroy
  has_many :batters, dependent: :destroy

  scope :greater_than, -> (year) { where("year >= ?", year).order("year DESC") }
  scope :less_than,    -> (year) { where("year <= ?", year).order("year DESC") }

  def self.create_seasons
  	Create::Seasons.new.create
  end

  def create_games
    game_creator = Create::Games.new
    teams = Team.all
    teams.each { |team| game_creator.create(self, team) }
  end

  def update_batters
    batter_updater = Update::Batters.new
    teams = Team.all
    teams.each { |team| batter_updater.update(self, team) }
  end

  def update_pitchers
    pitcher_updater = Update::Pitchers.new
    teams = Team.all
    teams.each { |team| pitcher_updater.update(self, team) }
  end

  def update_batters_scout
    batter_updater = Update::Batters.new
    teams = Team.all
    teams.each { |team| batter_updater.scout(self, team) }
  end

  def update_pitchers_scout
    pitcher_updater = Update::Pitchers.new
    teams = Team.all
    teams.each { |team| pitcher_updater.scout(self, team) }
  end
end

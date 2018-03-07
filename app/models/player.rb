class Player < ApplicationRecord
  belongs_to :team
  has_many :lancers, dependent: :destroy
  has_many :batters, dependent: :destroy

  def self.create_players
    player_creator = Create::Players.new
    teams = Team.all
    teams.each do |team|
      player_creator.create(team)
      player_creator.fangraphs(team)
    end
  end

  def self.update_players
    player_creator = Create::Players.new
    player_creator.update
  end

  def create_batter(season, team=nil, game=nil)
    if game
      unless batter = batters.find_by(season: season, team: team, game: game)
        batter = Batter.create(player: self, season: season, team: team, game: game)
        puts "#{self.name} batter created for #{game.url}"
        batter.create_game_stats
      end
    else
      unless batter = batters.find_by(season: season, team: nil, game: nil)
        batter = Batter.create(player: self, season: season)
      end
    end
    return batter
  end

  def create_lancer(season, team=nil, game=nil)
    if game
      unless lancer = lancers.find_by(season: season, team_id: team, game: game)
        lancer = Lancer.create(player: self, season: season, team: team, game: game)
        puts "#{self.name} lancer created for #{game.url}"
        lancer.create_game_stats
      end
    else
      unless lancer = lancers.find_by(season: season, team: nil, game: nil)
        lancer = Lancer.create(player: self, season: season)
      end
    end
    return lancer
  end
end

class Batter < ApplicationRecord
  belongs_to :team, optional: true
  belongs_to :player
  belongs_to :game, optional: true
  belongs_to :season
  has_many   :batter_stats, dependent: :destroy

  def bathand
    if player
      player.bathand
    end
  end

  def name
    player.name
  end

  def self.starters
    where(game_id: nil, starter: true)
  end

  def create_game_stats
    batter = self.player.create_batter(self.season)
    batter.stats.order("id").each do |stat|
      new_stat = stat.dup
      new_stat.batter_id = self.id
      new_stat.save
    end
  end

  def stats(handedness=nil)
    if self.batter_stats.size == 0
      batter_stats.create(batter_id: self.id, range: "Season", handedness: "L")
      batter_stats.create(batter_id: self.id, range: "Season", handedness: "R")
      batter_stats.create(batter_id: self.id, range: "14 Days", handedness: "")
    end
    unless handedness
      return batter_stats
    else
      return batter_stats.find_by(handedness: handedness)
    end
  end

  def view_stats(seasons, handedness)
    stat_array = Array.new
    stats = self.stats
    stat_array << stats.find_by(handedness: handedness)
    stat_array << stats.find_by(handedness: "")
    seasons.each do |season|
      unless season == self.season
        stat_array << player.create_batter(season).stats.find_by(handedness: handedness)
      end
    end
    return stat_array
  end
end

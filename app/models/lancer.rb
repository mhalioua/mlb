class Lancer < ApplicationRecord
  belongs_to :team
  belongs_to :player
  belongs_to :game
  belongs_to :season
  has_many   :pitcher_stats, dependent: :destroy

  def stats(handedness=nil)
    if pitcher_stats.size == 0
      PitcherStat.create(lancer: self, range: "Season", handedness: "L")
      PitcherStat.create(lancer: self, range: "Season", handedness: "R")
      PitcherStat.create(lancer: self, range: "30 Days", handedness: "")
    end
    unless handedness
      pitcher_stats
    else
      pitcher_stats.find_by(handedness: handedness)
    end
  end
end
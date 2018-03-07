class Batter < ApplicationRecord
  belongs_to :team, optional: true
  belongs_to :player
  belongs_to :game, optional: true
  belongs_to :season
  has_many   :batter_stats, dependent: :destroy

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
end

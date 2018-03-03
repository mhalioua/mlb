class Batter < ApplicationRecord
  belongs_to :player
  belongs_to :game
  has_many   :batter_stats, dependent: :destroy
end

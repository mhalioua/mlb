class Lancer < ApplicationRecord
  belongs_to :player
  belongs_to :game
  has_many   :pitcher_stats, dependent: :destroy
end

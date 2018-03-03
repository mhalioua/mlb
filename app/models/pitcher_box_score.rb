class PitcherBoxScore < ApplicationRecord
  belongs_to :game
  belongs_to :pitcher
end

class HitterBoxScore < ApplicationRecord
  belongs_to :game
  belongs_to :hitter
end

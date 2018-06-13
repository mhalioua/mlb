class BatterScouting < ApplicationRecord
  belongs_to :player
  belongs_to :season
  belongs_to :team
end

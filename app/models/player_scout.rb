class PlayerScout < ApplicationRecord
  belongs_to :player
  has_many :scouts, dependent: :destroy
end

class Player < ApplicationRecord
  belongs_to :team
  has_many :lancers, dependent: :destroy
  has_many :batters, dependent: :destroy
end

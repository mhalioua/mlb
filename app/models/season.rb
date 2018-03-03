class Season < ApplicationRecord
  has_many :game_days, dependent: :destroy

  def self.create_seasons
  	Create::Seasons.new.create
  end
end

class Weather < ApplicationRecord
  belongs_to :game
  def wind
  	wind_speed + " " + wind_dir
  end
end

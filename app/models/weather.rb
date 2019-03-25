class Weather < ApplicationRecord
  belongs_to :game

  def temp_num
    temp.to_f.round(1)
  end

  def dew_num
    dp.to_f.round(1)
  end

  def humid_num
    hum.to_i
  end

  def pressure_num
    pressure.to_f.round(2)
  end

  def wind
    wind_speed + " " + wind_dir
  end
end

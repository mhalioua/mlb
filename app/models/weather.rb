class Weather < ApplicationRecord
  belongs_to :game

  def temp_num
    return 0.0 if temp.size < 3
    temp.to_f.round(1)
  end

  def dew_num
    return 0.0 if dp.size < 3
    dp.to_f.round(1)
  end

  def humid_num
    return 0.0 if hum.size < 2
    hum.to_i
  end

  def pressure_num
    return 0.0 if pressure.size < 3
    pressure.to_f.round(2)
  end

  def wind
    wind_speed + " " + wind_dir
  end
end

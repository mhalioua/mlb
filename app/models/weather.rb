class Weather < ApplicationRecord
  belongs_to :game

  def temp_num
    return 0.0 if temp.size < 3
    temp[0..-3].to_f
  end

  def dew_num
    return 0.0 if dp.size < 3
    dp[0..-3].to_f
  end

  def humid_num
    return 0.0 if hum.size < 2
    hum[0..1].to_i
  end

  def pressure_num
    return 0.0 if pressure.size < 3
    pressure[0..-3].to_f
  end

  def wind
    wind_speed + " " + wind_dir
  end
end

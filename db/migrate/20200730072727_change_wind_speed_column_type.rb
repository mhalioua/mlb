class ChangeWindSpeedColumnType < ActiveRecord::Migration[5.1]
  def change
    change_column :weathers, :wind_speed, :float
  end
end
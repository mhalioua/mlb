class ChangeWeatherColumnType < ActiveRecord::Migration[5.1]
  def change
    change_column :weathers, :pressure, :float
    change_column :weathers, :dp, :float
    change_column :weathers, :hum, :float
  end
end
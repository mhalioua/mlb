class ChangeWeatherColumnType < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :postpone, :boolean
  end
end
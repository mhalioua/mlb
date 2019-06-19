class AddColumnsToWeather < ActiveRecord::Migration[5.1]
  def change
    add_column :weathers, :time, :string
    add_column :weathers, :conditions, :string
    add_column :weathers, :precip_percent, :string
    add_column :weathers, :cloud, :string
  end
end

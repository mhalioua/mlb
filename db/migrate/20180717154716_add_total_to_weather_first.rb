class AddTotalToWeatherFirst < ActiveRecord::Migration[5.1]
  def change
    add_column :weather_firsts, :t_HITS, :float
    add_column :weather_firsts, :t_HITS_SUM, :integer
    add_column :weather_firsts, :t_HRS, :float
    add_column :weather_firsts, :t_HRS_SUM, :integer
  end
end

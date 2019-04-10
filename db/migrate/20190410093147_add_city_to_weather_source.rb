class AddCityToWeatherSource < ActiveRecord::Migration[5.1]
  def change
    add_column :weathersources, :city1, :float
    add_column :weathersources, :city2, :float
    add_column :weathersources, :city3, :float
  end
end

class AddCityCountToWeatherSource < ActiveRecord::Migration[5.1]
  def change
    add_column :weathersources, :cityCount1, :integer
    add_column :weathersources, :cityCount2, :integer
    add_column :weathersources, :cityCount3, :integer
  end
end

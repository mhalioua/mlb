class AddOverToWeatherSource < ActiveRecord::Migration[5.1]
  def change
    add_column :weathersources, :over1, :integer
    add_column :weathersources, :under1, :integer
    add_column :weathersources, :over2, :integer
    add_column :weathersources, :under2, :integer
  end
end

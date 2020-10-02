class AddOverToWeatherSource < ActiveRecord::Migration[5.1]
  def change
    add_column :weathersources, :over1, :integer, default: 0
    add_column :weathersources, :under1, :integer, default: 0
    add_column :weathersources, :over2, :integer, default: 0
    add_column :weathersources, :under2, :integer, default: 0
  end
end

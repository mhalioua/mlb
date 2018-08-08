class AddCountToWeatherSouce < ActiveRecord::Migration[5.1]
  def change
    add_column :weathersources, :t_HITS_avg, :float
    add_column :weathersources, :t_HRS_avg, :float
    add_column :weathersources, :first_count, :integer
    add_column :weathersources, :second_count, :integer
    add_column :weathersources, :third_count, :integer
  end
end

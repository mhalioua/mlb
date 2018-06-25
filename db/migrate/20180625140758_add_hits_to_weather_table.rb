class AddHitsToWeatherTable < ActiveRecord::Migration[5.1]
  def change
    add_column :weather_firsts, :hits1, :integer
    add_column :weather_firsts, :home_runs1, :integer

    add_column :weather_firsts, :hits2, :integer
    add_column :weather_firsts, :home_runs2, :integer

    add_column :weather_firsts, :hits3, :integer
    add_column :weather_firsts, :home_runs3, :integer

    add_column :weather_firsts, :hits4, :integer
    add_column :weather_firsts, :home_runs4, :integer

    add_column :weather_firsts, :hits5, :integer
    add_column :weather_firsts, :home_runs5, :integer

    add_column :weather_firsts, :hits6, :integer
    add_column :weather_firsts, :home_runs6, :integer

    add_column :weather_firsts, :hits7, :integer
    add_column :weather_firsts, :home_runs7, :integer

    add_column :weather_firsts, :hits8, :integer
    add_column :weather_firsts, :home_runs8, :integer

    add_column :weather_firsts, :hits9, :integer
    add_column :weather_firsts, :home_runs9, :integer

    add_column :weather_firsts, :hits10, :integer
    add_column :weather_firsts, :home_runs10, :integer


    add_column :weather_seconds, :hits1, :integer
    add_column :weather_seconds, :home_runs1, :integer

    add_column :weather_seconds, :hits2, :integer
    add_column :weather_seconds, :home_runs2, :integer

    add_column :weather_seconds, :hits3, :integer
    add_column :weather_seconds, :home_runs3, :integer

    add_column :weather_seconds, :hits4, :integer
    add_column :weather_seconds, :home_runs4, :integer

    add_column :weather_seconds, :hits5, :integer
    add_column :weather_seconds, :home_runs5, :integer

    add_column :weather_seconds, :hits6, :integer
    add_column :weather_seconds, :home_runs6, :integer

    add_column :weather_seconds, :hits7, :integer
    add_column :weather_seconds, :home_runs7, :integer

    add_column :weather_seconds, :hits8, :integer
    add_column :weather_seconds, :home_runs8, :integer

    add_column :weather_seconds, :hits9, :integer
    add_column :weather_seconds, :home_runs9, :integer

    add_column :weather_seconds, :hits10, :integer
    add_column :weather_seconds, :home_runs10, :integer
  end
end

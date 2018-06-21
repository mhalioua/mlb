class CreateWeatherSeconds < ActiveRecord::Migration[5.1]
  def change
    create_table :weather_seconds do |t|
    	t.integer :day
    	t.string :month
    	t.integer :year
    	t.string :time
    	t.string :away_team
    	t.string :home_team
    	t.integer :away_ml
    	t.integer :home_ml
    	t.string :away_total
    	t.string :home_total
    	t.float :TEMP
    	t.float :DP
    	t.string :humid
    	t.float :BARO
    	t.string :wind
    	t.string :speed
    	t.string :a1
    	t.string :a2
    	t.string :a3
    	t.string :a4
    	t.string :h1
    	t.string :h2
    	t.string :h3
    	t.string :h4
    	t.integer :total_home_runs_both_team
    	t.integer :total_hits_both_team
    	t.string :away_starter_last_game
    	t.string :away_starter_first_name
    	t.string :away_starter_handedness
    	t.float :away_pitcher_game_first_blue
    	t.float :away_pitcher_game_opp_first_blue
    	t.float :away_pitcher_game_second_blue
    	t.float :away_pitcher_game_opp_second_blue
    	t.string :home_starter_last_name
    	t.string :home_starter_first_name
    	t.string :home_starter_handedness
    	t.float :home_pitcher_game_first_blue
    	t.float :home_pitcher_game_opp_first_blue
    	t.float :home_pitcher_game_second_blue
    	t.float :home_pitcher_game_opp_second_blue
    	t.integer :game_id
      t.timestamps
    end
  end
end

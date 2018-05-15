class CreatePrevgames < ActiveRecord::Migration[5.1]
  def change
    create_table :prevgames do |t|
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
    	t.float :TEMP,
    	t.float :DP
    	t.integer :humid
    	t.float :BARO
    	t.string :wind
    	t.string :speed
    	t.integer :a1
    	t.integer :a2
    	t.integer :a3
    	t.integer :a4
    	t.integer :h1
    	t.integer :h2
    	t.integer :h3
    	t.integer :h4
    	t.integer :away
    	t.integer :home
    	t.integer :total
    	t.integer :total_home_runs_both_team
    	t.integer :total_hits_both_team
    	t.string :away_starter_last_game
    	t.string :away_starter_first_name
    	t.string :away_starter_handedness
    	t.float :away_pitcher_game_first_blue
    	t.float :away_pitcher_game_opp_first_blue
    	t.float :away_difference
    	t.float :away_pitcher_game_second_blue
    	t.float :away_pitcher_game_opp_second_blue
    	t.string :home_starter_last_name
    	t.string :home_starter_first_name
    	t.string :home_starter_handedness
    	t.float :home_pitcher_game_first_blue
    	t.float :home_pitcher_game_opp_first_blue
    	t.float :home_difference
    	t.float :home_pitcher_game_second_blue
    	t.float :home_pitcher_game_opp_second_blue
    	t.float :total_line
      t.timestamps
    end
  end
end

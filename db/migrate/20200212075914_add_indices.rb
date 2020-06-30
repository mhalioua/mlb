class AddIndices < ActiveRecord::Migration[5.1]
  def change
  	add_index :results, :month
  	add_index :results, :year
  	add_index :results, :day
  	add_index :results, :home_score_first
  	add_index :results, :away_team
  	add_index :results, :home_team
  	add_index :results, :away_score_tenth
  	add_index :results, :home_score_tenth
  	add_index :results, :total_hits_both_team
  	add_index :results, :first_temp
  	add_index :results, :home_pitcher_name
  	add_index :results, :home_pitcher_game_first_ip
  	add_index :results, :away_pitcher_link
  	add_index :results, :home_pitcher_link
  	add_index :results, :game_date
  	add_index :totals, :DATE
  	add_index :totals, :AWAY
  end
end

class AddingIndices < ActiveRecord::Migration[5.1]
  def change
  	add_index :games, :id
  	add_index :transactions, :team_id
  	add_index :weather_firsts, :game_id
  	add_index :newworkbooks, :game_id

  	add_index :batters, :starter
  	add_index :lancers, :ip
  	add_index :seasons, :year
  	add_index :pitcherinformations, :away
  	add_index :games, :game_id
  	
  	add_index :newworkbooks, :Away_Team
  	add_index :newworkbooks, :hits1
  	add_index :newworkbooks, :link
  	add_index :newworkbooks, :Date
  	add_index :newworkbooks, :Time
  	add_index :workbooks, :hits1
  	add_index :workbooks, :t_HRS
  end
end

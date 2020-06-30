class AddIndicesToTables < ActiveRecord::Migration[5.1]
  def change
  	add_index :lancers, :starter
  	add_index :lancers, :bullpen

  	add_index :weathers, :station
  	add_index :weathers, :hour

  	add_index :weathersources, :table_number
  	add_index :weathersources, :date

  	add_index :prevpitchers, :away

  	add_index :umpires, :statfox
  	add_index :umpires, :count

  	add_index :game_days, :date

  	add_index :games, :game_date
  end
end

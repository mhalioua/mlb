class AddMoreIndicesToTables < ActiveRecord::Migration[5.1]
  def change
  	add_index :workbooks, :Home_Team
  	add_index :workbooks, :table
  	add_index :workbooks, :N
  	add_index :workbooks, :M
  	add_index :workbooks, :total_line
  	add_index :workbooks, :TEMP
  	add_index :workbooks, :DP
  	add_index :workbooks, :HUMID
  	add_index :workbooks, :BARo

  	add_index :prevgames, :TEMP
  	add_index :prevgames, :DP
  	add_index :prevgames, :HUMID
  	add_index :prevgames, :BARo
  	add_index :prevgames, :Home_Team
  	add_index :prevgames, :M
  	add_index :prevgames, :N
  	add_index :prevgames, :total_line

  	add_index :newworkbooks, :Home_Team
  	add_index :newworkbooks, :Direction
  	add_index :newworkbooks, :Speed

  end
end

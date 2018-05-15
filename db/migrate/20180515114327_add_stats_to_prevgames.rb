class AddStatsToPrevgames < ActiveRecord::Migration[5.1]
  def change
  	add_column :prevgames, :Home_Team, :string
  	add_column :prevgames, :N, :float
  	add_column :prevgames, :M, :string
  end
end

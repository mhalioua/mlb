class AddWalkToPrev < ActiveRecord::Migration[5.1]
  def change
  	add_column :prevgames, :total_walks_both_team, :integer
  end
end

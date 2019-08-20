class AddWalkedToGameStats < ActiveRecord::Migration[5.1]
  def change
    add_column :game_stats, :walked, :integer
  end
end

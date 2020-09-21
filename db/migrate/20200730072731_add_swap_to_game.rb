class AddSwapToGame < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :swap, :boolean, default: false
  end
end
class AddCloserToGame < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :away_money_line_closer, :string
    add_column :games, :home_money_line_closer, :string
    add_column :games, :away_total_closer, :string
    add_column :games, :home_total_closer, :string
  end
end

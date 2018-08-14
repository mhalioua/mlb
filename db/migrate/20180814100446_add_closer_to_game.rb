class AddCloserToGame < ActiveRecord::Migration[5.1]
  def change
    add_column :game, :away_money_line_closer, :string
    add_column :game, :home_money_line_closer, :string
    add_column :game, :away_total_closer, :string
    add_column :game, :home_total_closer, :string
  end
end

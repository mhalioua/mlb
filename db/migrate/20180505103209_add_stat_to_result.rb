class AddStatToResult < ActiveRecord::Migration[5.1]
  def change
  	add_column :results, :home_pitcher_name, :string
  	add_column :results, :home_pitcher_link, :string
  	add_column :results, :home_pitcher_ip, :float
  	add_column :results, :home_pitcher_h, :integer
  	add_column :results, :home_pitcher_r, :integer
  	add_column :results, :home_pitcher_bb, :integer

  	add_column :results, :away_pitcher_name, :string
  	add_column :results, :away_pitcher_link, :string
  	add_column :results, :away_pitcher_ip, :float
  	add_column :results, :away_pitcher_h, :integer
  	add_column :results, :away_pitcher_r, :integer
  	add_column :results, :away_pitcher_bb, :integer
  end
end

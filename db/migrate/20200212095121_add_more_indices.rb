class AddMoreIndices < ActiveRecord::Migration[5.1]
  def change
  	add_index :stadium_data, :team_id
  	add_index :stadium_data, :wind_dir
  	add_index :stadia, :stadium
  end
end

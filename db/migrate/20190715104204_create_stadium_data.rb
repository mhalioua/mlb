class CreateStadiumData < ActiveRecord::Migration[5.1]
  def change
    create_table :stadium_data do |t|
      t.integer :team_id
      t.string :wind_dir
      t.string :wind_speed
      t.string :result
      t.string :count
      t.timestamps
    end
  end
end

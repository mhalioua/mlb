class CreateScouts < ActiveRecord::Migration[5.1]
  def change
    create_table :scouts do |t|
      t.belongs_to :player_scout, index: true
      t.integer :row_index
      t.integer :season
      t.integer :pitches
      t.integer :batted_balls
      t.integer :barrels
      t.float :barrel
      t.float :exit_velocity
      t.float :launch_angle
      t.integer :xba
      t.integer :xslg
      t.integer :xwoba
      t.integer :woba
      t.float :hard_hit

      t.timestamps
    end
  end
end

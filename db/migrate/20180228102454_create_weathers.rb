class CreateWeathers < ActiveRecord::Migration[5.1]
  def change
    create_table :weathers do |t|
      t.belongs_to :game, index: true

      t.string :station
      t.integer :hour
      t.string :temp
      t.float :dp
      t.float :hum
      t.float :pressure
      t.string :wind_dir
      t.float :wind_speed
      t.string :precip

      t.timestamps
    end
  end
end

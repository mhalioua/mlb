class CreateWeathers < ActiveRecord::Migration[5.1]
  def change
    create_table :weathers do |t|
      t.belongs_to :game, index: true

      t.string :station
      t.integer :hour
      t.string :temp
      t.string :dp
      t.string :hum
      t.string :pressure
      t.string :wind_dir
      t.string :wind_speed
      t.string :precip

      t.timestamps
    end
  end
end

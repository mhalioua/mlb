class CreatePlayerScouts < ActiveRecord::Migration[5.1]
  def change
    create_table :player_scouts do |t|
      t.belongs_to :player, index: true
      t.string :relies
      t.string :description
      t.timestamps
    end
  end
end

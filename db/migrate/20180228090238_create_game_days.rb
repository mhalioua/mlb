class CreateGameDays < ActiveRecord::Migration[5.1]
  def change
    create_table :game_days do |t|
      t.belongs_to :season
      t.date    :date
      t.timestamps
    end
  end
end

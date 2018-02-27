class CreateGameDays < ActiveRecord::Migration[5.1]
  def change
    create_table :game_days do |t|
      t.integer    :year
      t.integer    :month
      t.integer    :day
      t.timestamps
    end
  end
end

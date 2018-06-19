class CreateGameStats < ActiveRecord::Migration[5.1]
  def change
    create_table :game_stats do |t|
      t.belongs_to :game, index: true
      t.integer :row_number
      t.integer :home_score
      t.integer :away_score
      t.integer :hits
      t.integer :home_runs
      t.timestamps
    end
  end
end

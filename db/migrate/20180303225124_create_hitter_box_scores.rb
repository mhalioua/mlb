class CreateHitterBoxScores < ActiveRecord::Migration[5.1]
  def change
    create_table :hitter_box_scores do |t|
      t.belongs_to :game
      t.belongs_to :hitter
      t.boolean :home
      t.string :name
      t.integer :BO
      t.integer :PA
      t.integer :H
      t.integer :HR
      t.integer :R
      t.integer :RBI
      t.integer :BB
      t.integer :SO
      t.integer :wOBA
      t.float :pLI
      t.float :WPA
      t.timestamps
    end
  end
end

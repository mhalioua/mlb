class CreatePitcherBoxScores < ActiveRecord::Migration[5.1]
  def change
    create_table :pitcher_box_scores do |t|
      t.belongs_to :game
      t.belongs_to :pitcher
      t.boolean :home
      t.string :name
      t.float :IP
      t.integer :TBF
      t.integer :H
      t.integer :HR
      t.integer :ER
      t.integer :BB
      t.integer :SO
      t.float :FIP
      t.float :pLI
      t.float :WPA
      t.timestamps
    end
  end
end

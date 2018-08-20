class CreateHitters < ActiveRecord::Migration[5.1]
  def change
    create_table :hitters do |t|
      t.belongs_to  :team
      t.belongs_to  :game

      t.string      :name
      t.integer     :index
      t.string      :position
      t.string      :hand
      t.integer     :ab
      t.integer     :h
      t.integer     :r
      t.integer     :rbi
      t.integer     :bb
      t.string      :avg
      t.integer     :hr

      t.timestamps
    end
  end
end

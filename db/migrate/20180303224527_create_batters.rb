class CreateBatters < ActiveRecord::Migration[5.1]
  def change
    create_table :batters do |t|
      t.belongs_to :team,        index: true
      t.belongs_to :game,        index: true
      t.belongs_to :player,      index: true
      t.belongs_to :season,      index: true
      t.boolean    :starter
      t.integer    :lineup
      t.string     :position
      t.timestamps
    end
  end
end

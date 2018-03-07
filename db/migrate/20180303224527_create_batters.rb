class CreateBatters < ActiveRecord::Migration[5.1]
  def change
    create_table :batters do |t|
      t.belongs_to :team
      t.belongs_to :game
      t.belongs_to :player
      t.belongs_to :season
      t.boolean    :starter
      t.integer    :lineup
      t.string     :position
      t.timestamps
    end
  end
end

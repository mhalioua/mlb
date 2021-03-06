class CreateLancers < ActiveRecord::Migration[5.1]
  def change
    create_table :lancers do |t|
      t.belongs_to :team,        index: true
      t.belongs_to :game,        index: true
      t.belongs_to :player,      index: true
      t.belongs_to :season,      index: true
      t.boolean    :starter
      t.boolean    :bullpen
      t.integer    :pitches
      t.float      :ip
      t.integer    :bb
      t.integer    :h
      t.integer    :r
      t.integer    :np
      t.integer    :s
      t.timestamps
    end
  end
end

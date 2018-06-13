class CreatePitcherScoutings < ActiveRecord::Migration[5.1]
  def change
    create_table :pitcher_scoutings do |t|
      t.belongs_to :team,        index: true
      t.belongs_to :player,      index: true
      t.belongs_to :season,      index: true

      t.float			:IP
      t.float			:FA
      t.float			:FC
      t.float			:FS
      t.float			:SI
      t.float			:CH
      t.float			:SL
      t.float			:CU

      t.timestamps
    end
  end
end

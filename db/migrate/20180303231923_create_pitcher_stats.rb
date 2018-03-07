class CreatePitcherStats < ActiveRecord::Migration[5.1]
  def change
    create_table :pitcher_stats do |t|
      t.belongs_to :lancer
      t.string     :handedness
      t.string     :range
      t.float      :whip
      t.float      :ip
      t.integer    :so
      t.integer    :bb
      t.integer    :fip
      t.float      :xfip
      t.float      :kbb
      t.integer    :woba
      t.string     :ops
      t.float      :era
      t.float      :fb
      t.float      :gb
      t.float      :ld
      t.integer    :h
      t.float      :siera
      t.timestamps
    end
  end
end

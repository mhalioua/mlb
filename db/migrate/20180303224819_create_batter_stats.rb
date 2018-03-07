class CreateBatterStats < ActiveRecord::Migration[5.1]
  def change
    create_table :batter_stats do |t|
      t.belongs_to :batter
      t.string   :handedness
      t.string   :range
      t.integer  :woba
      t.string   :ops
      t.integer  :ab
      t.integer  :so
      t.integer  :bb
      t.integer  :sb
      t.float 	 :fb
      t.float 	 :gb
      t.float    :ld
      t.integer  :wrc
      t.integer  :obp
      t.integer  :slg
      t.timestamps
    end
  end
end

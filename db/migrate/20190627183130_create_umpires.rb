class CreateUmpires < ActiveRecord::Migration[5.1]
  def change
    create_table :umpires do |t|
      t.string  :statfox
      t.string  :covers
      t.integer :year
      t.integer :count
      t.float   :so
      t.float   :bb
      t.float   :sw
      t.timestamps
    end
  end
end

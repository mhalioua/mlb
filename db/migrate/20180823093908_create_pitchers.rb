class CreatePitchers < ActiveRecord::Migration[5.1]
  def change
    create_table :pitchers do |t|
      t.belongs_to  :team
      t.belongs_to  :game

      t.string      :name
      t.integer     :index
      t.string      :hand
      t.string      :identity
      t.float       :ip
      t.integer     :h
      t.integer     :r
      t.integer     :bb
      t.integer      :er
      t.integer     :k

      t.timestamps
    end
  end
end
